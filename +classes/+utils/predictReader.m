classdef predictReader < classes.utils.edfReader
    % predictReader - Provides functions for reading and marking an edf 
    % file from a standard anti/pro experiment.
    
    properties (SetAccess=private, GetAccess=public)
        F=struct(); % The structure to hold all antipro variables
        
        trialstart=[];
        trialend=[];
    end
    
    properties (Constant, GetAccess=public)
        FIX_TIME=250;    % The amount of fixation (the number of ms of 
                        % fixation/2) to use as a baseline for calculating 
                        % saccade thresholds
        TRIAL_EXTRA=500  % Extra time to add to the end of each trial.
                        % Since trials are separated out, extra time is 
                        % necessary so that views can display past the end
                        % of the trial.
                        
        FIX_CUTOFF=30;  % degrees/s for defining non saccade periods of the trial for determining background noise.
%         SAC_CUTOFF=30;  % Degrees/s for defining non saccade periods of the trial for determining background noise.
        MIN_VEL=30;     % minimum allowed velocity
        MIN_DUR=10;     % minimum DURATION of saccade in ms
        MYFILT=3;       % filtfilt box kernal width for speed calculations
        
        % blink remover:
        BLINK_T=10000;  % Blink Threshold
        PUPIL_BLINK_LEN_T=5;   % This is the minimum length of loss of eye tracking data to be considered a blink
        %PA_SEARCHT=100;  % Number of sample points to look examine pupil area before and after blink
        PA_SEARCHT=25;  % Number of sample points to look examine pupil area before and after blink
        %PA_NPEAK_B=1;   % Number of peaks to go back before the loss of data
        %PA_NPEAK_A=2;   % Number of peaks to go forward after the loss of data
        %INTERP_SAMPS=5; % Number of sample points before and after loss of data to base the interpolation on
        SHRINK_BACKGROUND=50;% background variability level
        MIN_PEAK=2;      % minimum height of pa_dd peaks
    end
    
    methods
        % Constructor
        function aobj=predictReader(f)
            aobj=aobj@classes.utils.edfReader(f);
            
            initPredictStruct(aobj);
            
            if (getTrials(aobj))
                readPredictData(aobj);

                aobj.F=markTrials(aobj, aobj.F);
            end
        end
        
        % Initialize Predict structure
        function initPredictStruct(obj)
            obj.F.EXP=obj.M.preamble(strfind(obj.M.preamble, 'RECORDED BY')+12:strfind(obj.M.preamble, '** SREB')-2);  % Get the proper name out of the header
            obj.F.TMULT=2.5;    % The multiplier for the threshold (i.e.
            % number of standard deviations from the mean
            % to define a saccade.)
            
            obj.F.targeton=[];
            obj.F.targetloc=[];
            obj.F.fixoff=[];
            obj.F.fixtime=[];
            
            % TODO - Refactor this to move it out of this class and
            % into the class it belongs to.
            % Automarks
            
            % Now process the file
            obj.F.res=obj.getRes();
            
            % Sample rate
            obj.F.SAMPRATE=obj.F.res.rec_rate;
            % Sample interval
            obj.F.SAMP_INT=1000/obj.F.res.rec_rate;
            
            % Replicate the resolution field in constants for backward
            % compatibility
            obj.F.SCREENX=obj.F.res.pix_wide; % Screen dimensions
            obj.F.SCREENY=obj.F.res.pix_high;
            
            obj.F=obj.pixelinfo(obj.F);
            
             % Get the isis
            [isitimes isimessages]=obj.getELmes('!V TRIAL_VAR isi');        
            
            obj.F.isis=[];
            
            for i=1:size(isimessages,1)
               obj.F.isis(i)=str2num(isimessages(i,17:end));
            end    
            
            % Original trials
            obj.F.trials={};
        end
        
        % Extract the trial sample data from the edf data.  This is the x,
        % y, t, etc... data recorded by the eye tracker
        function trialsfound=getTrials(obj)
            % Find some markers for the start and end of trials:
            %   - The start of the trial is marked by the beginning of fixation.
            %   This gives us some baseline to calculate a saccade threshold.
            %   - The end of a trial is marked by the trial message, which
            %   occurs sometime after the last target times out.
            trialsfound=1;
            
            obj.trialstart=obj.getELmes('TRIALID');
            obj.trialend=obj.getELmes('TRIAL_RESULT');
            
            if isempty(obj.trialstart)||isempty(obj.trialend)
                disp('    This file contains no data');
                trialsfound=0;
                return;
            end
            
            if length(obj.trialstart)>length(obj.trialend)
                obj.trialstart=obj.trialstart(1:length(obj.trialend));
            end
            
%             obj.trialend(end)=obj.trialend(end)+obj.TRIAL_EXTRA;
            
            % Pull out each trial data from the sample data read in by
            % el2mat
            sampledata=obj.getSampleData();
            for i=1:length(obj.trialstart)
                obj.F.trials=[obj.F.trials sampledata(sampledata(:,1)>obj.trialstart(i)...
                    &sampledata(:,1)<obj.trialend(i), :)];
            end
        end
        
        % Read the trial information.  This is trial meta data such as the
        % task, paradigm, target locations, etc...
        function readPredictData(obj)
            % Find some more markers and meta data
            
             % Find some more markers and meta data
            % This is the end of the second fixation and the time from which
            % SRTs are measured
%             fixoff=obj.getELmes('fixation2off');
%             % The target events, which include location information
%             [targetevents, mtargetevents]=obj.getELmes({'target1on', 'target2on', 'target3on'});
%             % The second fixation timer, which includes the length of fixation
%             [fix2time, mfix2time]=obj.getELmes('fixation2timeron');
%             

            % Target locations
            [targloc, targlocmes]=obj.getELmes('TARGET_LOCATION');

            [target, targetmes]=obj.getELmes('target');   % Times that targets appeared
            [ttimeout, ttimeoutmes]=obj.getELmes('timer_timeout');        % Times that timers where activated
            targetmes=cellstr(targetmes);
            % Eccentricity if available
            [ECCevents ECCmessages]=obj.getELmes('ECC ');
            
            obj.F.ton={};
            obj.F.targetdir=[];
            obj.F.dircode={'left=1'};
            obj.F.tonind={};
            obj.F.ECC=[];
            
            % Get the number of stimuli
            obj.F.NSTIM=(length(targetmes)-length(ECCmessages))/2/length(ECCmessages);
            
            % Get the target locations
            if ~isempty(strfind(targlocmes(1, :), 'LEFT'))
                x=sscanf(targlocmes(1, :), '%*s %*s %*s %s %*s');
                y=sscanf(targlocmes(1, :), '%*s %*s %*s %*s %s');
                
                obj.F.targleftloc=[str2num(x(2:end-1))-obj.F.SCREENX/2 str2num(y(1:end-1))-obj.F.SCREENY/2]/obj.F.PPD;
                
                x=sscanf(targlocmes(2, :), '%*s %*s %*s %s %*s');
                y=sscanf(targlocmes(2, :), '%*s %*s %*s %*s %s');
                
                obj.F.targrightloc=[str2num(x(2:end-1))-obj.F.SCREENX/2 str2num(y(1:end-1))-obj.F.SCREENY/2]/obj.F.PPD;
            else
                x=sscanf(targlocmes(1, :), '%*s %*s %*s %s %*s');
                y=sscanf(targlocmes(1, :), '%*s %*s %*s %*s %s');
                
                obj.F.targrightloc=[str2num(x(2:end-1))-obj.F.SCREENX/2 str2num(y(1:end-1))-obj.F.SCREENY/2]/obj.F.PPD;
                
                x=sscanf(targlocmes(2, :), '%*s %*s %*s %s %*s');
                y=sscanf(targlocmes(2, :), '%*s %*s %*s %*s %s');
                
                obj.F.targleftloc=[str2num(x(2:end-1))-obj.F.SCREENX/2 str2num(y(1:end-1))-obj.F.SCREENY/2]/obj.F.PPD;
            end
            
            % Now process each trial to verify that it is valid and pull out
            % some meta data.
            i=1;
            while i <= length(obj.trialstart)
                    targon=find(target>=obj.trialstart(i)&target<=obj.trialend(i));

                    t_timeout=strcellmatch(targetmes(targon), 'timer_timeout');

                    ton=target([targon(1); t_timeout(1:end-1)+targon(1)]);
                    
                    tonind=[];
                    
                    assert(length(ton)==obj.F.NSTIM);  % If we don't find the correct number of stimuli, something is wrong
                    
                    for j=1:length(ton)
                        tonind=[tonind find(obj.F.trials{i}(:,1)>=ton(j), 1)];
                    end
                    
                    obj.F.ton{i}=ton;
                    obj.F.tonind{i}=tonind;
                    
                    targetdir=find(target>obj.trialstart(i));
                    obj.F.targetdir(i)=isempty(strfind(char(targetmes(targetdir(1), :)), 'right'));
                    
                    if ~isempty(ECCmessages)
                        obj.F.ECC=[obj.F.ECC sscanf(ECCmessages(i, :), '%*s %*s %*s %d')];
                    else
                        obj.F.ECC=[obj.F.ECC 8];    % A default eccentricity for old versions of the task
                    end
                    
                    i=i+1;
            end
            
        end
        
        % Automark the trial
        function F_ret=markTrials(obj, F)
            n=length(F.trials);
            
            % Switch to BCoe's structure to work with his algorithms
            F.trials_Don=F.trials;
            
            F.sac_Don={};
            
            n=length(F.trials_Don);
            
            F.trials=struct('x', [], 'y', [], 'a', [], 's', []);
            
            % Process each trial for automarking
            for i=1:n
                temp_trial=F.trials_Don{i};
                
                F.rawtrials{i}=single(temp_trial(:, 1:4));

                F.trials(i)=removeblinks(obj, i, F); % bcoe's blink removal
                F.speedFilt(i)=obj.MYFILT;
                F.trials(i)=FilterSpeed(obj,F.trials(i),F.res.rec_rate,F.speedFilt(i));
                
                F.trials_Don{i}=[F.trials_Don{i}(:,1) F.trials(i).x F.trials(i).y];

                fixtrialx=F.trials(i).x;
                fixtrialy=F.trials(i).y;

                F.fixtrials{i}=[fixtrialx fixtrialy];
                
                F.s{i}=F.trials(i).s;               
                
                [F.sac(i), F.sacthres(i)]=findsacs(obj, F, i, -1);
                
                F.t{i}=F.sacthres(i);

                F.sac_Don{i}=[F.sac(i).sIND F.sac(i).eIND F.sac(i).dX F.sac(i).dY F.sac(i).AMPL F.sac(i).pVel];                
                
                % Automark the trials by finding the first 2 saccades after the
                % second fixation turns off
                sacon=automark(F, i);
                
                F.sacons{i}=sacon;              
            end
            
            F.sac=F.sac_Don;
            F.trials=F.trials_Don;
            
            F_ret=F;
        end
        
           function trial = removeblinks(obj, i, F)
            % get default values from the Q.(right now in obj)
            % Q not full implemented yet. D order is important!
            D.BLINK_T=obj.BLINK_T;
            D.PUPIL_BLINK_LEN_T=obj.PUPIL_BLINK_LEN_T;
            D.PA_SEARCHT=obj.PA_SEARCHT;
            D.SHRINK_BACKGROUND=obj.SHRINK_BACKGROUND;
            D.MIN_PEAK=obj.MIN_PEAK;
            
            trial=EL1k_removeblinks_2015(F.rawtrials{i},F.res,D);
            if sum(isnan(trial.x))/length(trial.x)>.25% bcoe
                fprintf(' *** trial #%03d has %4.1f%% data loss!!\n',i,sum(isnan(trial.x))/length(trial.x)*100)
            end            
        end
        
        function trial=FilterSpeed(obj,trial,rec_rate,ff)
            vel_x=double(obj.calcDerivative(trial.x,rec_rate));
            vel_y=double(obj.calcDerivative(trial.y,rec_rate));
            %ff=F.speedFilt(tr);
            %filtfilt can't handle nan's or singles
            if sum(~isnan(vel_x))>length(vel_x)*.1 & ff > 1% at least 10% of real data
                vel_x(~isnan(vel_x))=filtfilt(ones(1,ff),ff,vel_x(~isnan(vel_x)));
                vel_y(~isnan(vel_y))=filtfilt(ones(1,ff),ff,vel_y(~isnan(vel_y)));
            end
            %figure(234243);clf;
            %plot( trial.s,'b');hold on
            %plot(single(sqrt(vel_x.^2+vel_y.^2)),'r');hold on
            trial.s=single(sqrt(vel_x.^2+vel_y.^2));
            
            %             [F.sac(tr), F.sacthres(tr)]=findsacs(obj, F, tr, F.sacthres(tr));
            %             F_ret=automark_trial(obj, F, tr);
            
        end
        
        function [sac, thres] = findsacs(obj, F, i, ct)
            % get default values from the Q.(right now in obj)
            %Q not full implemented yet. D order is important!
            
            D.FIX_CUTOFF=obj.FIX_CUTOFF;% 30
            D.MIN_VEL=obj.MIN_VEL;   % Minimum allowed velocity
            D.MIN_DUR=obj.MIN_DUR;   % has to last 10ms
            D.TOOLONG=300;	% a saccade can't last more than 300ms
            D.TOOCLOSE=10;  % speed has to stay below thres for 10ms to be independent
            D.TOOSLOW=150;  % don't combine close saccades if the eariler one is 100DPS slower than later one
            
            % D=EL1k_findsacs_2015 % will show what it wants
            
            [sac, thres] = EL1k_findsacs_2015(F.trials(i),F.res.SAMP_INT,F.TMULT,ct, D);
        end
        
        function F_ret=adj_sacthresh(obj,F,scroll,tr)
            ct=min(75,max(4,round(F.sacthres(tr)/2)*2- (scroll.VerticalScrollCount*2)));
            %APmarker=classes.utils.antiproMarker();
            [F.sac(tr), F.sacthres(tr)]=findsacs(obj, F, tr, ct);
            F_ret=automark_trial(obj, F, tr);
            
        end
        
        function d = calcDerivative(obj, pos, RATE)
            % Calculate the derivative (rate of change) at each sample in the trial using
            % the 2 points adjacent to it.
            % v         instantaneous derivative for this dimension
            % pos       position data from one dimension (i.e. x or y) for one trial
            N=length(pos);

            d = zeros(N,1);
            d(2:N-1,:) = RATE/2*[pos(3:end,:) - pos(1:end-2,:)];
            d(1)=d(2);
            d(N)=d(N-1); 
        end
    end
end
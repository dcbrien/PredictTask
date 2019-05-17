classdef trial < handle
    % A class to hold trial information.  This was created to remove trial
    % getting and setting from the view classes.
    
    properties (SetAccess=private, GetAccess=private)
        % Some parameters for the current trial
        model;
    end
    
    properties (SetAccess=private, GetAccess=public)
        trialnum;
        ftrialx;
        ftrialy;
        targonind;
        targetlocy;
        targetlocx;
        maxdeg;
        task;
        fc;
        tc;
        
        s;
        t;
        maxs;
    end
    
    methods
        % Constructor
        function tobj=trial(m, t)
        % INPUT:
        %   m: The model
        %   t: The trial number
            tobj.model=m;
        	tobj.trialnum=t;
            
            updateTrialNum(tobj, t);
        end
        
        % Change the trial number and calculate new values to be used
        % during drawing.
        function updateTrialNum(obj, tnum)
        % INPUT:
        %   tnum: the trial number  
            
            % the trial data
            if obj.trialnum >= 1
                obj.trialnum=tnum;
                obj.ftrialx=obj.model.F.fixtrials{obj.trialnum}(:,1)';
                obj.ftrialy=obj.model.F.fixtrials{obj.trialnum}(:,2)';

                for j=1:obj.model.F.NSTIM
                    obj.targonind(j)=getTargetOnIndex(obj, j);

                    obj.targetlocx(j)=getTargetLocationX(obj, j);
                    obj.targetlocy(j)=getTargetLocationY(obj, j);
                end
                
                obj.maxdeg=getMaximumXDegress(obj);

                [obj.task, obj.fc, obj.tc]=getTaskInformation(obj);

                getSpeedData(obj);
            end
        end
        
        % Extract the speed data for this trial
        function getSpeedData(obj)
            obj.s=obj.model.F.s{obj.trialnum};
            obj.t=obj.model.F.t{obj.trialnum};
                        
            % Going with an absolute magic number for this because saccades
            % are always to the same 2 targets and should not exceed this
            % number.  This avoids possibly rare issues with blink/eye loss
            % causing abnormally large values.
            obj.maxs=750;
            
%             obj.maxs=max(1, max(obj.s(obj.targonind-obj.model.MINTIME:obj.targonind+obj.model.MAXTIME)));
        end
        
        % Calculate the maximum degrees of the x eye data in a trial
        function maxdeg=getMaximumXDegress(obj)
            MAX_DEGREE_BUFFER=15; % amount of degrees to display beyond the maximum degrees
            
            % Define the range of the trial to look for maximum degrees.
            % Because we are interested in the saccades after target onset,
            % we define 1000ms after that point.
            range=obj.targonind:obj.targonind+1000/(1000/obj.model.F.SAMPRATE);

            maxdeg=max(abs(obj.ftrialx(range)))+MAX_DEGREE_BUFFER;
        end
        
        % Get the task information
        function [task, fc, tc]=getTaskInformation(obj)
        % OUTPUT:
        %   task: a string indicating the task as anti or pro
        %   fc: the fixation colour
        %   tc: the text colour
                        
            task=obj.model.F.EXP;
            fc=obj.model.c_pro;

            tc=max(fc,[0.8 0.7 0.8]);
        end
        
        % Get the x coordinate of the target in degrees
        function targetlocx=getTargetLocationX(obj, snum)
            % INPUT:
            %   obj.trialnum: the trial number
            %   snum: stimulus number
            % OUTPUT:
            %   targetlocx: the x coordinate of the target in degrees
            % Draw the stimulus position
            
            if obj.model.F.targetdir(obj.trialnum)==1
                if mod(snum, 2)==1 % left
                    targetlocx=obj.model.F.targleftloc(1);
                else % right
                    targetlocx=obj.model.F.targrightloc(1);
                end
            else
                if mod(snum, 2)==1 % right
                    targetlocx=obj.model.F.targrightloc(1);
                else % left
                    targetlocx=obj.model.F.targleftloc(1);
                end
            end   
        end
        
          % Get the x coordinate of the target in degrees
        function targetlocy=getTargetLocationY(obj, snum)
            % INPUT:
            %   obj.trialnum: the trial number
            %   snum: stimulus number
            % OUTPUT:
            %   targetlocx: the x coordinate of the target in degrees
            % Draw the stimulus position
            
            if obj.model.F.targetdir(obj.trialnum)==1
                if mod(snum, 2)==1 % left
                    targetlocy=obj.model.F.targleftloc(2);
                else % right
                    targetlocy=obj.model.F.targrightloc(2);
                end
            else
                if mod(snum, 2)==1 % right
                    targetlocy=obj.model.F.targrightloc(2);
                else % left
                    targetlocy=obj.model.F.targrightloc(2);
                end
            end      
        end
        
        % Get the index of the target in the trial array for a certain trial
        function targonind=getTargetOnIndex(obj, snum)
        % INPUT:
        %   tnum: the trial number
        %   snum: stimulus number
        % OUTPUT:
        %   targonind: The index of the target in the trial array
%             targon=obj.model.F.ton{obj.trialnum};
            targonind=obj.model.F.tonind{obj.trialnum}(snum); 
            %find(obj.model.F.trials{obj.trialnum}(:,1) >= targon, 1);    
        end
    end
end
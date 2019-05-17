classdef predict_model < handle
    %PREDICT MODEL This class holds all the information for a particular
    %marked data set.
    %   This is the model class for the predict marking GUI.  It keeps
    %   track of the experiment data for a particular block for a
    %   particular subject.  All views act and communicate with this model.
    
    properties (GetAccess=public, SetAccess=private)
        trialorder=[];
        MINTIME=0;  % The min and max time to show before and after target
        MAXTIME=0;  % presention, respecitively.
        marks={};  % A list of mark classes representing the marks to
                % be made on this data.
        current_mark_ind;
        current_mark='';
        current_mark_label='';
        
        % A list of reference objects that hold specific derived trial
        % information
        trials={};
        blanktrial;        
    end
    
    properties (GetAccess=public, SetAccess=public)
         F=[];   % The F structure from the automark file.
    end    
    
    properties (Constant, GetAccess=public)
        % TODO - Colours really aren't a model property - Should probably
        % be extracted to their own class if they are needed by multiple
        % views for consistency.
  
        c_pro  =[0  1 0]; % pro color
        c_anti =[1  0 0]; % anti color
        c_pos  =[.5 .5 .5]; % pos color on top plot
        c_sac  =[0  1 0]; % pos color on sac plot
        c_speed=[1 .5 0]; % pos color on speed plot
        
        c_stim_pretarg = [0 0 0]; % Pre stimulus color
        c_stim_posttarg = [1 0 0]; % Post stimulus color
        
        SORT_DIR=1;         % Sort by direction
        SORT_DIR_PLUS=2;
        NO_SORT=3;
    end    
    
    properties (SetAccess=private, GetAccess=private)
        deletemode=0;
    end
    
    events
        modelPropertyChange
    end
    
    methods
        % Constructor
        function mobj=predict_model(Fin, mint, maxt)
            mobj.F=Fin;
            mobj.MINTIME=mint;
            mobj.MAXTIME=maxt;
            
            setTrials(mobj);
            
            % These arrays are added for backwards compatibility mostly.
            ztemp=zeros(1, length(mobj.F.trials));
            
             % Add an array for ignoring trials
            if ~isfield(mobj.F, 'ignoretrial')
                mobj.F.ignoretrial=ztemp;
            end
            
            % Add an array for step saccades if it doesn not exist
            if ~isfield(mobj.F, 'stepsac')
                mobj.F.stepsac=ztemp;
            end            
        end
        
        % Get the experiment information structure
        function F=get.F(obj)
            F=obj.F;
        end   
        
        % Create the trial information
        function setTrials(obj)
            for i=1:length(obj.F.trials)
                obj.trials{i}=classes.model.trial(obj, i);
            end
            
            % Set a blank trial for showing nothing
            obj.blanktrial=classes.model.trial(obj, -1);
        end
        
        % Get a specific trial from the list
        function t=getTrial(obj, tnum)
        % INPUT:
        %   tnum: the trial to return
            if tnum >= 1
                t=obj.trials{tnum};
            else
               t=obj.blanktrial; 
            end
        end
        
        % Get all saccades for a particular trial
        function saccades=getSaccades(obj, tnum)
        % INPUT:
        %   tnum: the trial to return
            saccades={};
            for s=1:size(obj.F.sac{tnum}, 1)
                saccades{s}=classes.model.saccade(obj, s, tnum, [], [], []); 
            end
        end        
        
        % Add a new mark to the list of marks for this data.
        function addMark(obj, mark)
            obj.marks{length(obj.marks)+1}=mark;
            
            % Set this mark to bet the current mark
            [mark, label]=mark.getFirstMark();
            obj.current_mark_ind=length(obj.marks);
            obj.current_mark=mark;
            obj.current_mark_label=label;
        end
        
        % Order the trials by a giving type.
        % type can be: 'dir' for sort by direction (left or right saccade)
        % NUMTRIALS is the number of trials to be shown at a time in the
        % main display.
        function setTrialOrder(obj, type, NUMTRIALS)
            if ~ischar(type)
                warning('trial order must be a string');
            end
            
            switch type
                case 'dir'
                    left_trials=[];
                    right_trials=[];
                    
                    % Sort the trials by direction
                    for i=1:length(obj.F.trials)
                        anti_task=strfind(obj.F.task{i}, 'anti');
                        dir=strfind(obj.F.dir{i}, 'left');
                        
                        if (~isempty(dir) && isempty(anti_task)) || (isempty(dir) && ~isempty(anti_task))
                            left_trials=[left_trials i];
                        else
                            right_trials=[right_trials i];
                        end
                    end
                    
                    blanktrials=mod(length(left_trials), NUMTRIALS);
                    if blanktrials > 0
                        blanktrials=NUMTRIALS-blanktrials;
                    end
                    left_trials=[left_trials repmat(-1, 1, blanktrials)];
                    
                    blanktrials=mod(length(right_trials), NUMTRIALS);
                    if blanktrials > 0
                        blanktrials=NUMTRIALS-blanktrials;
                    end
                    right_trials=[right_trials repmat(-1, 1, blanktrials)];
                    
                    obj.trialorder=[left_trials right_trials];
                otherwise
                    % Default to no sorting
                    obj.trialorder=1:length(obj.F.trials);
            end
        end
        
        % If a new saccade is selected, update the current mark with this
        % new saccade.
        function saccadeSelected(obj, src, evt)
            if obj.deletemode
                for i=1:length(obj.marks)
                    obj.marks{i}.deleteMark(src.trialnum, src.stimnum, src.selectedSac);
                end
            else
                obj.marks{obj.current_mark_ind}.updateMark(obj.current_mark, src.trialnum, src.stimnum, src.selectedSac);
            end
            notify(obj, 'modelPropertyChange');
        end
        
        % Get all marked saccades for a given trial
        function sacs=getMarkedSaccades(obj, tnum, snum)
            % INPUT:
            %   tnum: the trial number
            % OUTPUT:
            %   sacs: A cell array of all marked saccades
            
            sacs={};
            for m=1:length(obj.marks)
                sacs=[sacs obj.marks{m}.getMarkedSaccades(tnum, snum)];
            end
        end
        
        % Set the current mark
        function setMark(obj, c)
            obj.deletemode=0;
            for i=1:length(obj.marks)
                [res label]=obj.marks{i}.compareMark(c);
                
                if res
                    obj.current_mark_ind=i;
                    obj.current_mark=c;
                    obj.current_mark_label=label;
                end
            end
            notify(obj, 'modelPropertyChange');
        end
        
        % Reset all the marks for a particular trial.  This generally
        % removes all marks, but can also leave some if it makes sense
        % (like the first saccade for instance).
        function resetMarks(obj, src)
            for i=1:length(obj.marks)
               obj.marks{i}.resetMark(src.trialnum, src.stimnum);
            end
            notify(obj, 'modelPropertyChange');
        end
        
        function setDeleteMode(obj, src)
            obj.deletemode=1;
            obj.current_mark_label='delete';
        end
        
        function setIgnore(obj, src)
            obj.F.ignoretrial(src.trialnum)=~obj.F.ignoretrial(src.trialnum);
            notify(obj, 'modelPropertyChange');
        end
    end
end


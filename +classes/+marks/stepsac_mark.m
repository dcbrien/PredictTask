classdef stepsac_mark < classes.marks.markbase
    % STEPSAC_MARK A mark for step saccades
    %   These are all small saccades that are used as corrective saccades
    %   after larger saccades are made.  They are labeled in order with
    %   numbers (e.g., 's1', 's2', etc...)
    % TODO: This is a mark with multiple saccades marked in it.  It may be
    % better to abstract this array behaviour away, or assume that all
    % saccades have the potential for more than one saccade.
    % TODO: Make saccades aware of one another, or possible refactor the
    % mark design to be more efficient.  There seems to be a lot of model
    % manipulating code going on in the marks.
    
    properties (SetAccess=public, GetAccess=public)
    end
    
    properties (Constant, GetAccess=private)
        MARK_COL='cyan';
    end
    
    methods
        % Constructor
        function robj=stepsac_mark(m)
            robj=robj@classes.marks.markbase(m, {'s'}, {'Step saccade'});
            
            % Add an array for error saccades if it does not exist or is
            % not of the correct type
            if ~isfield(m.F, 'stepsac') || ~isa(m.F.stepsac, 'cell')
                m.F.stepsac=cell(m.F.NSTIM, length(m.F.trials));
            end
        end
        
        % Update the saccade
        function updateMark(obj, mark, trialnum, stimnum, sac)
            res=strmatch(mark, obj.cmark);
            
            if res==1
                obj.model.F.stepsac{stimnum, trialnum}=sort([obj.model.F.stepsac{stimnum, trialnum} sac]);
            end
        end
        
        % Get properties about the mark of a particular trial
        %   Output:
        %       sac = saccade number
        %       col = Colour for the mark
        %       t = text for the mark
        function [sac col t, full_t]=getMark(obj, trialnum, stimnum)
            sac=obj.model.F.sacons{trialnum}(stimnum);
            
            col=obj.DEFAULT_COLOUR;
            t='s';
            
        end        
        
        % Get the marked saccades for a certain trial - can return one or
        % many saccade objects
        function sacs=getMarkedSaccades(obj, trialnum, stimnum)
         	% INPUT:
            %   tnum: the trial number
            % OUTPUT:
            %   sacs: a cell array of marked saccades
            
            all_sac=obj.model.F.stepsac{stimnum, trialnum};
            numsteps=length(all_sac);
            t=cellstr([repmat('s', numsteps, 1) num2str((1:numsteps)')]);
            
            sacs={};
            for s=1:numsteps
                sacs{s}=classes.model.saccade(obj.model, all_sac(s), trialnum, obj.MARK_COL, t(s), ['Step ' num2str(s)]);
            end
        end
        
        % Reset these marks back to default for a specific trial
        function resetMark(obj, trialnum, stimnum)
%             obj.model.F.stepsac{stimnum, trialnum}=[];
        end
        
        % Delete these marks from a specific trial
        function deleteMark(obj, trialnum, stimnum, sac)
            step_index=find(obj.model.F.stepsac{stimnum, trialnum}==sac);
            if ~isempty(step_index)
                 obj.model.F.stepsac{stimnum, trialnum}(step_index)=[];
            end
        end
    end
    
end


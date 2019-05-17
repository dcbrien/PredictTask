classdef regsac_mark < classes.marks.markbase
    %REGSAC_MARK A mark for a regular saccade
    %   This is the first saccade made after a stimulus and it is used to
    %   calculate the SRT
    
    properties (SetAccess=public, GetAccess=public)
    end
    
    properties (Constant, GetAccess=private)
        C_OK =[0 .8 0]; % correct pro/anti
    end
    
    methods
        % Constructor
        function robj=regsac_mark(m)
            robj=robj@classes.marks.markbase(m, {'c'}, {'Correct saccade'});
        end
        
        % Update the saccade
        function updateMark(obj, mark, trialnum, stimnum, sac)
            res=strmatch(mark, obj.cmark);
            
            if res==1
                obj.model.F.sacons{trialnum}(stimnum)=sac;
            end
        end
        
        % Get properties about the mark of a particular trial
        %   Output:
        %       sac = saccade number
        %       col = Colour for the mark
        %       t = text for the mark
        function [sac col t]=getMark(obj, trialnum, stimnum)
            sac=obj.model.F.sacons{trialnum}(stimnum);
            
            col=obj.DEFAULT_COLOUR;
            t='c';
        end
        
        % Get the marked saccades for a certain trial - can return one or
        % many saccade objects
        function sacs=getMarkedSaccades(obj, trialnum, stimnum)
         	% INPUT:
            %   tnum: the trial number
            % OUTPUT:
            %   sacs: a cell array of marked saccades
            
            sac=obj.model.F.sacons{trialnum};
%             if isempty(obj.model.F.errorsac{trialnum})
                col=obj.C_OK;
                t='c';
                full_t='Correct';
%             else
%                 col=obj.C_ERR;
%                 t='e';
%             end
            
            sacs{1}=classes.model.saccade(obj.model, sac(stimnum), trialnum, col, t, full_t);
        end
        
        % Reset these marks back to default for a specific trial
        function resetMark(obj, trialnum, stimnum)
        end
        
        % Delete these marks from a specific trial
        function deleteMark(obj, trialnum, stimnum, sac)
            if obj.model.F.sacons{trialnum}(stimnum)==sac
                obj.model.F.sacons{trialnum}(stimnum)=-9999;
            end
        end
    end
    
end


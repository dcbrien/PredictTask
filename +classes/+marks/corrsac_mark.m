classdef corrsac_mark < classes.marks.markbase
    %CORRSAC_MARK A mark for a corrective saccade
    %   This is a mark for correction of direction errors.
    
    properties (SetAccess=public, GetAccess=public)
    end
    
    methods
        % Constructor
        function cobj=corrsac_mark(m)
            cobj=cobj@classes.marks.markbase(m, {'r'}, {'Corrective saccade'});
            
            % Add an array for corrective saccades if it does not exist
            if ~isfield(m.F, 'correctivesac')
                m.F.correctivesac=cell(1, length(m.F.trials));
            end
        end
        
        % Update the saccade
        function updateMark(obj, mark, trialnum, sac)
            res=strmatch(mark, obj.cmark);
            
            if res==1
                obj.model.F.correctivesac{trialnum}=sac;
            end
        end
        
        % Get properties about the mark of a particular trial
        %   Output:
        %       sac = saccade number
        %       col = Colour for the mark
        %       t = text for the mark
        function [sac col t]=getMark(obj, trialnum)
            sac=obj.model.F.correctivesac{trialnum};
            col=obj.DEFAULT_COLOUR;
            t='R';
        end
        
        % Reset these marks back to default for a specific trial
        function resetMark(obj, trialnum)
            obj.model.F.correctivesac{trialnum}=[];
        end
        
        % Delete these marks from a specific trial
        function deleteMark(obj, trialnum, sac)
            if obj.model.F.correctivesac{trialnum}==sac
                obj.resetMark(trialnum);
            end
        end
        
    end
    
end


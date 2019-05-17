classdef markbase < handle
    %MARKBASE The base class for a saccade mark
    %   This class contains all the details on a saccade mark.  It keeps
    %   track of what saccade belongs to this mark for each trial in the
    %   model. It also has functions for saving the mark back to the model.
    
    properties (SetAccess=protected, GetAccess=protected)
        cmark={};   % The characters assigned to this mark
        labels={};  % The labels for each character
        model=[];   % The model containing the experimental data
        haxes=[];
    end
    
    properties
        DEFAULT_COLOUR=[0 0 0.9];
    end
    
    methods
        % Constructor
        function mobj=markbase(m, c, l, h)
            mobj.model=m;
            mobj.cmark=c;
            mobj.labels=l;
        end
        
        % Returns true if the character c matches one of the characters
        % assigned to this mark
        function [res label]=compareMark(obj, c)
            if ischar(c)
                res=strmatch(c, obj.cmark);
                if ~isempty(res)
                    label=obj.labels{res};
                else
                   res=0;
                   label=[];
                end
            else
                warning('argument must be of type char');
            end
        end
        
        % Just return the first mark
        function [mark label]=getFirstMark(obj)
            mark=obj.cmark{1};
            label=obj.labels{1};
        end
    end
    
    methods (Abstract)
        updateMark(obj, trialnum, sac);
        getMark(obj, trialnum);
        resetMark(obj, trialnum);
        deleteMark(obj, trialnum, sac);
        getMarkedSaccades(obj, trialnum);        
    end
end
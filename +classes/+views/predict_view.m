classdef predict_view < handle
    %ANTIPRO_VIEW This is the base class for all views in the antipro_mark
    %program
    %   This contains common functions for displaying and interacting with
    %   a view of antipro data.
    
    properties (SetAccess=protected, GetAccess=protected)
        hfig=[];
        haxes=[];
        model=[];
        pos=[];
    end
    
    properties
        trialnum=[];
        stimnum=[];
    end
    
    methods
        % Constructor
        function apobj=predict_view(h, m, p, t, s)
            apobj.hfig=h;
            apobj.model=m;
            apobj.pos=p;
            apobj.trialnum=t;
            apobj.stimnum=s;
        end
        
        function deleteAxes(obj)
            if ishandle(obj.haxes)
                delete(obj.haxes); 
            end
        end
    end
    
    methods (Abstract)
        draw(obj)  
        update(obj)
    end
    
end


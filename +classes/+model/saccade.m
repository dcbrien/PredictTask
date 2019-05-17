classdef saccade < handle
    % A class to hold saccade information.  This was created to abstract
    % away saccade information into its own container so that views can
    % avoid messing with model code.
    
    properties (SetAccess=private, GetAccess=private)
        % Some parameters for the current trial
        model;
    end
    
    properties (SetAccess=private, GetAccess=public)
        col=[];         % The suggested drawing colour
        sacon=[];       % The saccade onset
        sacoff=[];      % The saccade offset
        tdisplay=[];    % The text to display
        full_tdisplay=[]; % The long text name to display
        sacposition=[]; % The eye position data for this saccade
        
        srt=[];         % The saccadic reaction time for this saccade 
    end
    
    methods
        % Constructor
        function sobj=saccade(m, sacn, tnum, col, t, full_t)
        % INPUT:
        %   m: The model
        %   sacn: the saccade number
        %   tnum: The trial number
        %   col: The suggested colour
        %   t: the string to display along side this saccade
            sobj.model=m;
            sobj.col=col;
            
            if iscell(t)
                sobj.tdisplay=char(t);
            else
                sobj.tdisplay=t;
            end
            
            sobj.full_tdisplay=full_t;
            
            calcSaccade(sobj, m, sacn, tnum);
        end

        % Calculate saccade values
        function calcSaccade(obj, m, sacn, tnum)
        % INPUT:
        %   sacn: the saccade number
        %   tnum: the trial number
            if ~isempty(sacn) && sacn~=-9999 && sacn > 0
                sac=m.F.sac{tnum}(sacn,:);
                obj.sacon=max(1, sac(1));
                obj.sacoff=min(sac(2), length(obj.model.F.fixtrials{tnum}(:, 1)));
                obj.sacposition=obj.model.F.fixtrials{tnum}(obj.sacon:obj.sacoff, :);
                
                % Will now calculate this relative to a particular stimulus
                % number
                obj.srt=0;
                
%                 obj.srt=(obj.sacon-obj.model.getTrial(tnum).targonind)*obj.model.F.SAMP_INT;            
            end
        end
        
        % Calculate the saccadic reaction time relative to a particular
        % stimulus
        function srt=getSRT(obj, tnum, snum)
            obj.srt=(obj.sacon-obj.model.getTrial(tnum).targonind(snum))*obj.model.F.SAMP_INT;            
            
            srt=obj.srt;
        end
    end
end
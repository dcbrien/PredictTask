classdef saccade_view < classes.views.predict_view
    %SACCADE_VIEW This displays a view of the saccade in 2D
    %   This plots all of the saccades for a trial in x,y coordinates 
  
    properties (SetAccess=private, GetAccess=private)
        % The trial object
        trial;
        
        % Handles for graphics objects that are reused
        saccades;   % Marked saccades
        saccade_endpoints;  % The end of all saccades is drawn differently
        
        target;
        target_text;
    end    
    
    properties (Constant, GetAccess=private)
        MAXMARKS=15; % The maximum number of marks to display
        
        AXIS_COL='black';
        AXIS_LINE_COL='white';
        TARGET_COL='red';
        
        TARGRADIUS=1.5;
        AXES_XY_LIM=18;
    end
    
    methods
        % Constructor
        function sobj=saccade_view(h, m, p, t, s)
            sobj=sobj@classes.views.predict_view(h, m, p, t, s);
            
            updateTrialNum(sobj, t, s);
            initiateAxis(sobj);            
            
%             sobj.haxes=axes('parent', sobj.hfig, 'Position', sobj.pos);
            
            drawAxis(sobj);
            setAxis(sobj);

            draw(sobj);
        end
        
        % Change the trial number and calculate new values to be used
        % during drawing.
        function updateTrialNum(obj, tnum, snum)
            % INPUT:
            %   tnum: the trial number
            obj.trialnum=tnum;
            obj.stimnum=snum;
            obj.trial=obj.model.getTrial(tnum);
        end
        
        % Set up the axis.  These are parameters that do not change when
        % the trial number are changed.
        function initiateAxis(obj)
            obj.haxes=axes('parent', obj.hfig, 'Position', obj.pos, 'Color', obj.AXIS_COL);
            hold(obj.haxes, 'on');
        end        
        
        function draw(obj)
            drawTarget(obj);
            displayMarks(obj);
        end        
        
        function update(obj)
            draw(obj);
        end
        
        % Draw and annotate the axis
        function drawAxis(obj)
            % Plot the axes
            plot([-obj.AXES_XY_LIM obj.AXES_XY_LIM], [0 0], obj.AXIS_LINE_COL, 'LineStyle', ':');
            plot([0 0], [-obj.AXES_XY_LIM obj.AXES_XY_LIM], obj.AXIS_LINE_COL, 'LineStyle', ':');
        end
        
        % Draw the target
        function drawTarget(obj)
            if isempty(obj.target)
                % Plot the target locations
                obj.target=rectangle('Position', [obj.trial.targetlocx(obj.stimnum)-obj.TARGRADIUS obj.trial.targetlocy(obj.stimnum)-obj.TARGRADIUS...
                    obj.TARGRADIUS*2 obj.TARGRADIUS*2], 'Curvature', [1, 1], 'EdgeColor', obj.TARGET_COL, 'FaceColor', obj.TARGET_COL);
                obj.target_text=text(obj.trial.targetlocx(obj.stimnum), obj.trial.targetlocy(obj.stimnum), 'T', 'Color', 'w', 'Fontsize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'Center');
            else
                set(obj.target, 'Position', [obj.trial.targetlocx(obj.stimnum)-obj.TARGRADIUS obj.trial.targetlocy(obj.stimnum)-obj.TARGRADIUS obj.TARGRADIUS*2 obj.TARGRADIUS*2]);
                set(obj.target_text, 'Position', [obj.trial.targetlocx(obj.stimnum) obj.trial.targetlocy(obj.stimnum)]);
            end
        end
        
        % Sets parameters for the axis so that it displays and functions
        % properly.
        function setAxis(obj)
             set(gca, 'Box', 'off', 'Xlim', [-obj.AXES_XY_LIM obj.AXES_XY_LIM],...
                 'Ylim', [-obj.AXES_XY_LIM obj.AXES_XY_LIM]);
        end
        
        % Display all marked saccades in the axis
        function displayMarks(obj)
            if isempty(obj.saccades)
                for s=1:obj.MAXMARKS
                    obj.saccades{s}=plot([0 0], [0 0], '.-', 'Visible', 'off');
                    obj.saccade_endpoints{s}=plot([0 0], [0 0], 'o', 'markersize', 8);
                end
            end
            
            sacs=obj.model.getMarkedSaccades(obj.trialnum, obj.stimnum);
            
            for i=1:min(length(sacs), obj.MAXMARKS)
                % Now draw the saccade if it exists
                if ~isempty(sacs{i}.sacon)
                    set(obj.saccades{i}, 'xdata', sacs{i}.sacposition(1:2:end, 1), 'ydata', sacs{i}.sacposition(1:2:end, 2), 'Color', sacs{i}.col, 'Visible', 'on');
                    set(obj.saccade_endpoints{i}, 'xdata', sacs{i}.sacposition(end, 1), 'ydata', sacs{i}.sacposition(end, 2), 'Color', sacs{i}.col, 'Visible', 'on');
                else
                    set(obj.saccades{i}, 'Visible', 'off');
                    set(obj.saccade_endpoints{i}, 'Visible', 'off');
                end
            end
            
            % Erase any remaining marks
            for s=(i+1):obj.MAXMARKS
                set(obj.saccades{s}, 'Visible', 'off');
                set(obj.saccade_endpoints{s}, 'Visible', 'off');
            end
        end
        
        function delete(obj)
            if ishandle(obj.haxes)
                delete(obj.haxes); 
            end
        end
        
        function updateTrial(obj, src, evt)
            updateTrialNum(obj, src.trialnum, src.stimnum);
            draw(obj);
        end
        
        % The model has been updated
        function modelUpdate(obj, src, evt)
            draw(obj);
        end
    end
    
end


classdef speed_view < classes.views.predict_view
    %SPEED_VIEW Displays the speed trace and saccades of a particular trial
    %   Displays the speed trace and saccades of a particular trial and
    %   allows you select saccades.
    
    properties (SetAccess=private, GetAccess=private)
        % The trial object
        trial;
        
        % Some handles for the saccades
        sacpatch;
        sactext;
        sacsrt;
        
        % Some other handles for graphics objects
        htext=[];
        thresholdline=[];
        pre_speedx=[];
        post_speedx=[];
        targon;
        targontext;        
        
        % Handles for marks
        m_sacon;
        m_sacoff;
        m_sacpatch;
        m_sactext;
        
        hslider=[];
        
        % Flag for resetting slider
        resetSlider;
    end
    
    properties (Constant, GetAccess=private)
        MAXSACS=100; % The maximum number of saccades to display
        MAXMARKS=15; % The maximum number of marks to display
        
        TARG_LINE_COL=[1 0 0];        
        
        THRESHOLD_LINE_COL=[0.75 0.75 0.75];
    end    
    
    properties
       selectedSac=-1; 
    end
    
    events
        selectSaccade
    end
    
    methods
        % Constructor
        function sobj=speed_view(h, m, p, t, s)
            sobj=sobj@classes.views.predict_view(h, m, p, t, s);
            
            updateTrialNum(sobj, t, s);
            initiateAxis(sobj);
%             
%             sobj.haxes=axes('parent', sobj.hfig, 'Position', [sobj.pos(1) sobj.pos(2)+sobj.pos(4)/10 sobj.pos(3) 9*sobj.pos(4)/10], 'XTick', [], 'Box', 'on');
%             set(sobj.haxes, 'ButtonDownFcn', @sobj.buttondown);
            
            draw(sobj);
        end
        
        % Change the trial number and calculate new values to be used
        % during drawing. 
        % TODO - This code seems to be duplicated in all classes
        % and should probably go into the base class.
        function updateTrialNum(obj, tnum, snum)
        % INPUT:
        %   tnum: the trial number
            obj.trialnum=tnum;
            obj.stimnum=snum;
            obj.trial=obj.model.getTrial(tnum);
            
            obj.resetSlider=1;
        end
        
        % Set up the axis.  These are parameters that do not change when
        % the trial number are changed.
        function initiateAxis(obj)
            obj.haxes=axes('parent', obj.hfig, 'Position', obj.pos);
            set(obj.haxes, 'ButtonDownFcn', @obj.buttondown);
            obj.hslider=uicontrol(obj.hfig, 'Style', 'slider', 'units', 'normalized', 'Position', [obj.pos(1) obj.pos(2)-obj.pos(4)/12 obj.pos(3) obj.pos(4)/12], 'Callback', @obj.sliderupdate);

            hold(obj.haxes, 'on');
        end
        
        function draw(obj)
            set(obj.hfig, 'CurrentAxes', obj.haxes);
            
            setText(obj);
            
            drawSpeedTrace(obj);
            
            drawTargOnsets(obj)
            
            drawThreshold(obj);
            
            displaySaccades(obj);
            
            displayMarks(obj);
            
            setAxis(obj);
        end
        
        function delete(obj)
            if ishandle(obj.haxes)
                delete(obj.haxes); 
            end
        end
        
        function update(obj)
            draw(obj);
        end
        
                % Set the trial information text
        function setText(obj)
            if isempty(obj.htext)
                obj.htext=text(0.20, 0.7, [sprintf('%3.0d', obj.trial.trialnum) ':' obj.trial.task], 'HorizontalAlignment', 'center', 'Color', obj.trial.tc, 'FontWeight', 'bold', 'FontSize', 25, 'units', 'normalized', 'interpreter', 'none');
            else
                set(obj.htext, 'String', [sprintf('%3.0d', obj.trial.trialnum) ':' obj.trial.task], 'Color', obj.trial.tc);
            end
        end
        
        % Draw the speed trace
        function drawSpeedTrace(obj)
            if isempty(obj.pre_speedx)  
                obj.pre_speedx=plot(1:obj.trial.targonind(obj.stimnum), obj.trial.s(1:obj.trial.targonind(obj.stimnum)), 'Color', obj.model.c_stim_pretarg, 'Linewidth', 2);
                obj.post_speedx=plot(obj.trial.targonind(obj.stimnum):length(obj.trial.s), obj.trial.s(obj.trial.targonind(obj.stimnum):length(obj.trial.s)), 'Color', obj.model.c_stim_posttarg, 'Linewidth', 2);                
          else
                set(obj.pre_speedx, 'xdata', 1:obj.trial.targonind(obj.stimnum), 'ydata', obj.trial.s(1:obj.trial.targonind(obj.stimnum)));
                set(obj.post_speedx, 'xdata',obj.trial.targonind(obj.stimnum):length(obj.trial.s), 'ydata', obj.trial.s(obj.trial.targonind(obj.stimnum):length(obj.trial.s)));   
           end
        end
        
        % Draw the threshold for saccade onset and offset calculations
        function drawThreshold(obj)
            if isempty(obj.thresholdline)
                obj.thresholdline=line([1 length(obj.trial.s)], [obj.trial.t obj.trial.t], 'Color', obj.THRESHOLD_LINE_COL);
            else
                set(obj.thresholdline, 'xdata', [1 length(obj.trial.s)], 'ydata', [obj.trial.t obj.trial.t]);
            end
        end
        
        % Draw the target onsets
        function drawTargOnsets(obj)
            if isempty(obj.targon)
                obj.targon=line([obj.trial.targonind(obj.stimnum) obj.trial.targonind(obj.stimnum)], [-obj.trial.maxs obj.trial.maxs], 'Color', obj.TARG_LINE_COL, 'LineWidth', 2, 'Parent', obj.haxes);
                
                obj.targontext=text(obj.trial.targonind(obj.stimnum), obj.trial.maxs*0.5, 'TARGET', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'Bottom', 'Color', obj.TARG_LINE_COL, 'FontWeight', 'bold', 'FontSize', 12, 'Clipping', 'On', 'Parent', obj.haxes, 'Visible', 'on', 'Rotation', 90);                
            else
                set(obj.targon, 'xdata', [obj.trial.targonind(obj.stimnum) obj.trial.targonind(obj.stimnum)], 'ydata', [-obj.trial.maxs obj.trial.maxs]);
                
                set(obj.targontext, 'Position', [obj.trial.targonind(obj.stimnum) obj.trial.maxs*0.5], 'String', 'TARGET', 'Visible', 'on');                
            end
        end
        
        % Draw all saccades for this trial
        function displaySaccades(obj)
            % Create the handles if necessary
            if isempty(obj.sacpatch)
                for s=1:obj.MAXSACS
                    obj.sacpatch{s}=patch([1 1 1 1], [-1 -1 1 1], [0 0 0.9], 'FaceAlpha', 0.05, 'EdgeAlpha', 0.05, 'Parent', obj.haxes, 'Visible', 'off');
                    obj.sactext{s}=text(1, 0.3, '', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'Bottom', 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 9, 'Clipping', 'On', 'Parent', obj.haxes, 'Visible', 'off', 'Rotation', 90);
                end
            end
            
            sacs=obj.model.getSaccades(obj.trialnum);

            for i=1:min(length(sacs), obj.MAXSACS)       
                % Draw the saccade if it exists
                if ~isempty(sacs{i}.sacon)
                    sacon_ton=sacs{i}.sacon;
                    sacoff_ton=sacs{i}.sacoff;
                set(obj.sacpatch{i}, 'xdata', [sacon_ton sacoff_ton sacoff_ton sacon_ton], 'ydata', [0 0 obj.trial.maxs obj.trial.maxs], 'Visible', 'on');
                    set(obj.sactext{i}, 'String', num2str(sacs{i}.getSRT(obj.trialnum, obj.stimnum)), 'Visible', 'on');                    
                    set(obj.sactext{i}, 'Position', [sacon_ton obj.trial.maxs*0.9]);
                else
                    set(obj.sacpatch{i}, 'Visible', 'off');
                    set(obj.sactext{i}, 'Visible', 'off');
                end
            end
            
            % Erase any remaining marks
            for s=(i+1):obj.MAXSACS
                set(obj.sacpatch{s}, 'Visible', 'off');
                set(obj.sactext{s}, 'Visible', 'off');
            end
        end
        
        % Display all marked saccades in the axis
        function displayMarks(obj)
            % Create the handles if necessary
            
            if isempty(obj.m_sacpatch)
                for s=1:obj.MAXMARKS
                    obj.m_sacpatch{s}=patch([1 1 1 1], [-1 -1 1 1], [0 0 0.9], 'FaceAlpha', 0.1, 'EdgeAlpha', 0.1, 'Parent', obj.haxes, 'Visible', 'off');
                    obj.m_sacon{s}=line([1 1], [-1.0 1.0], 'Color', 'k', 'Parent', obj.haxes, 'Visible', 'off');
                    obj.m_sacoff{s}=line([1 1], [-1.0 1.0], 'Color', 'k', 'Parent', obj.haxes, 'Visible', 'off');
                    obj.m_sactext{s}=text(1, 0.3, '', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'Bottom', 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 12, 'Clipping', 'On', 'Parent', obj.haxes, 'Visible', 'off', 'Rotation', 90);
                end
            end
            
            sacs=obj.model.getMarkedSaccades(obj.trialnum, obj.stimnum);
            
            for i=1:min(length(sacs), obj.MAXMARKS)
                % Now draw the saccade if it exists
                if ~isempty(sacs{i}.sacon)
                    sacon_ton=sacs{i}.sacon;
                    sacoff_ton=sacs{i}.sacoff;
                    
                    set(obj.m_sacon{i}, 'xdata', [sacon_ton sacon_ton], 'ydata', [0 obj.trial.maxs], 'Visible', 'on');
                    set(obj.m_sacoff{i}, 'xdata', [sacoff_ton sacoff_ton], 'ydata', [0 obj.trial.maxs], 'Visible', 'on');
                    set(obj.m_sacpatch{i}, 'xdata', [sacon_ton sacoff_ton sacoff_ton sacon_ton], 'ydata', [0 0 obj.trial.maxs obj.trial.maxs], 'Visible', 'on', 'FaceColor', sacs{i}.col);
                    set(obj.m_sactext{i}, 'String', sacs{i}.full_tdisplay, 'Visible', 'on');
                    set(obj.m_sactext{i}, 'Position', [sacon_ton obj.trial.maxs*0.5], 'Color', sacs{i}.col);
                else
                    set(obj.m_sacon{i}, 'Visible', 'off');
                    set(obj.m_sacoff{i}, 'Visible', 'off');
                    set(obj.m_sacpatch{i}, 'Visible', 'off');
                    set(obj.m_sactext{i}, 'Visible', 'off');   
                end
            end
            
            % Erase any remaining marks
            for s=(i+1):obj.MAXMARKS
                set(obj.m_sacon{s}, 'Visible', 'off');
                set(obj.m_sacoff{s}, 'Visible', 'off');
                set(obj.m_sacpatch{s}, 'Visible', 'off');
                set(obj.m_sactext{s}, 'Visible', 'off');                
            end
        end
        
        % Sets parameters for the axis so that it displays and functions
        % properly.
        function setAxis(obj)
            if obj.resetSlider
                set(obj.hslider, 'Min', 1, 'Max', length(obj.trial.s), 'Value', obj.trial.targonind(obj.stimnum), 'SliderStep', [30/length(obj.trial.s) 50/length(obj.trial.s)]);
                set(gca, 'Xlim', [obj.trial.targonind(obj.stimnum)-obj.model.MINTIME obj.trial.targonind(obj.stimnum)+obj.model.MAXTIME], 'Ylim', [0 obj.trial.maxs], 'XTickLabel', []);   
                ylabel('speed (deg/s)');
                
                obj.resetSlider=0;
            end
            
            c=get(obj.haxes, 'children');
            set(c, 'Hittest', 'off');
            set(c, 'PickableParts', 'none');
        end
        
        function updateTrial(obj, src, evt)
            updateTrialNum(obj, src.trialnum, src.stimnum);
            draw(obj);
        end
        
        % TODO - this is logic code that deals with the internal workings
        % of the model.  This should be moved out of here into???
        % controller or model.  It should just pass on the time and the
        % model can work out the details.
        function buttondown(obj, src, evt)
            pos=get(gca, 'CurrentPoint');
            
            currtrial=obj.trialnum;
            snum=obj.stimnum;
            
            x=pos(1,1);
            
            if ~isempty(obj.model.F.sac{currtrial})
                sacs=obj.model.F.sac{currtrial};
                xind=x;
                sel=find(sacs(:,1)<=xind&sacs(:,2)>=xind);
                if ~isempty(sel) % a saccade was selected
                    obj.selectedSac=sel;
                    notify(obj, 'selectSaccade');
                end
                
                obj.resetSlider=0;  % Do not reset the slider
                draw(obj);
            end
        end
        
        function sliderupdate(obj, hObject, eventdata)
            val=get(hObject, 'Value');
            set(obj.haxes, 'Xlim', [val-obj.model.MINTIME, val+obj.model.MAXTIME]);
        end
    end
    
end


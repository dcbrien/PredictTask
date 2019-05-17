classdef paxes_view < classes.views.predict_view
    %PAXES_VIEW A view of the position trace and saccades for one trial
    %   This view handles drawing the position trace and saccades for one
    %   trial of the experiment
    
    properties (SetAccess=private, GetAccess=private)
        hslider=[];
        htext=[];
        
        % Some handles for graph items
        targetline;
        pretargety;
        posttargety;
        pretargetx;
        posttargetx;
        centerline;
        targon;
        targontext;
        
        % Some handles for the marks
        sacon;
        sacoff;
        sacpatch;
        sactext;
        
        % Some handles for the previous marks
        p_sacon;
        p_sacoff;
        p_sacpatch;
        p_sactext;
        
        % Some handles for the following marks
        f_sacon;
        f_sacoff;
        f_sacpatch;
        f_sactext;          
        
        % The trial object
        trial;
        
        % Flag for steps that only should be done on the first draw
        firstdraw=1;
        
        % Flag for resetting slider
        resetSlider;        
    end
    
    properties (Constant, GetAccess=private)
        MAXMARKS=15; % The maximum number of marks to display
        
        BIGSLIDERSTEP=30;
        SMALLSLIDERSTEP=50;
        
        % Some colours
        PRETARG_NOTRIAL_COL_Y=[0.85 0.95 1.0];
        POSTTARG_NOTRIAL_COL_Y=[1.0 0.9 0.9];
        PRETARG_NOTRIAL_COL_X=[0.5 0.8 1.0];
        POSTTARG_NOTRIAL_COL_X=[1.0 0.5 0.0];
        
        EYE_LINE_WIDTH=1.5;
        
        CENTERLINER_COL=[0.75 0.75 0.75];
        
        TARG_LINE_COL=[1 0 0];
        
        Y_COL=[.8 .8 .8]; % Colour of y eye traces that are usually displayed in the background
    end    
    
    events
        selectView
    end
    
    methods
        % Constructor
        function pobj=paxes_view(h, m, p, t, s)
            pobj=pobj@classes.views.predict_view(h, m, p, t, s);
            
            updateTrialNum(pobj, t, s);
            initiateAxis(pobj);
            
            draw(pobj);
        end
        
        % Change the trial number and calculate new values to be used
        % during drawing.
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
            obj.haxes=axes('parent', obj.hfig, 'Position', [obj.pos(1) obj.pos(2)+obj.pos(4)/10 obj.pos(3) 9*obj.pos(4)/10], 'XTick', [], 'YTick', []);
            set(obj.haxes, 'ButtonDownFcn', @obj.buttondown);
            hold(obj.haxes, 'on');
                        
            obj.hslider=uicontrol(obj.hfig, 'Style', 'slider', 'units', 'normalized', 'Position', [obj.pos(1) obj.pos(2) obj.pos(3) obj.pos(4)/9], 'Callback', @obj.sliderupdate);
        end    
        
        % Sets parameters for the axis so that it displays and functions
        % properly.
        function setAxis(obj)
            if obj.resetSlider
                set(obj.haxes, 'Xlim', [obj.trial.targonind(obj.stimnum)-obj.model.MINTIME obj.trial.targonind(obj.stimnum)+obj.model.MAXTIME], 'Ylim', [-1 1]);

                set(obj.hslider, 'Min', obj.model.MINTIME, 'Max', length(obj.trial.ftrialx)-obj.model.MAXTIME, 'Value', obj.trial.targonind(obj.stimnum),...
                    'SliderStep', [obj.BIGSLIDERSTEP/length(obj.trial.ftrialx) obj.SMALLSLIDERSTEP/length(obj.trial.ftrialx)]);
                
                obj.resetSlider=0;
            end
                
            if obj.firstdraw
                c=get(obj.haxes, 'children');
                set(c, 'Hittest', 'off');
                set(c, 'PickableParts', 'none');
            end   
        end        
        
        function draw(obj)
            drawLines(obj);
            
            setText(obj);            
            
            drawEyeTrace(obj);

            drawTargOnsets(obj);
            
            displayMarks(obj);
            
            setAxis(obj);            
        end
        
        function update(obj)
            draw(obj);
        end
        
        % Sets the text information for this trial.
        function setText(obj)
           if isempty(obj.htext)
               obj.htext=text(0.02, 0.9, '', 'HorizontalAlignment', 'left', 'Color', obj.model.c_stim_posttarg, 'FontWeight', 'bold', 'FontSize', 15, 'Tag', 'trialnum', 'Parent', obj.haxes, 'units', 'normalized', 'Position', [0.05 0.8]);
           end
           
           set(obj.htext, 'String', ['Stim: ' num2str(obj.stimnum)], 'color', obj.model.c_stim_posttarg);
        end        
        
        % Draw center and target lines for this trial
        % TODO: Hard code colours somewhere else to remove magic numbers
        % and code duplication and make it easier to change and maintain
        % later.
        function drawLines(obj)
            % Draw a center line
            if isempty(obj.centerline)
                obj.centerline=line([1 length(obj.trial.ftrialx)], [0 0], 'Color', obj.CENTERLINER_COL, 'Parent', obj.haxes);
            else
                set(obj.centerline, 'xdata', [1 length(obj.trial.ftrialx)]);
            end
            
            % Draw the stimulus position
            if isempty(obj.targetline)
                obj.targetline=line([1 length(obj.trial.ftrialx)], [obj.trial.targetlocx(obj.stimnum)/obj.trial.maxdeg obj.trial.targetlocx(obj.stimnum)/obj.trial.maxdeg], 'Color', [0.75 0.75 0.75], 'LineStyle', '--', 'Parent', obj.haxes);
            else
                set(obj.targetline, 'ydata', [obj.trial.targetlocx(obj.stimnum)/obj.trial.maxdeg obj.trial.targetlocx(obj.stimnum)/obj.trial.maxdeg]);
            end
        end
        
        % Draw the eye traces for one trial
        % TODO: Hard code colours somewhere else to remove magic numbers
        % and code duplication and make it easier to change and maintain
        % later.
        function drawEyeTrace(obj)
            % Create the objects for drawing if necessary
            if isempty(obj.pretargety)
                if obj.model.F.ignoretrial(obj.trial.trialnum)==0
                    obj.pretargety=plot(obj.haxes, 1:obj.trial.targonind(obj.stimnum), obj.trial.ftrialy(1:obj.trial.targonind(obj.stimnum))./obj.trial.maxdeg, 'Color', max(obj.trial.fc, obj.Y_COL)  , 'Linewidth', obj.EYE_LINE_WIDTH);
                    obj.posttargety=plot(obj.haxes, obj.trial.targonind(obj.stimnum):length(obj.trial.ftrialy), obj.trial.ftrialy(obj.trial.targonind(obj.stimnum):end)./obj.trial.maxdeg, 'Color', max(obj.model.c_pos, obj.Y_COL), 'Linewidth', obj.EYE_LINE_WIDTH);
                    obj.pretargetx=plot(obj.haxes, 1:obj.trial.targonind(obj.stimnum), obj.trial.ftrialx(1:obj.trial.targonind(obj.stimnum))./obj.trial.maxdeg, 'Color', obj.model.c_stim_pretarg, 'Linewidth', obj.EYE_LINE_WIDTH);
                    obj.posttargetx=plot(obj.haxes, obj.trial.targonind(obj.stimnum):length(obj.trial.ftrialx), obj.trial.ftrialx(obj.trial.targonind(obj.stimnum):end)./obj.trial.maxdeg, 'Color', obj.model.c_stim_posttarg, 'Linewidth', obj.EYE_LINE_WIDTH);
                else
                    obj.pretargety=plot(obj.haxes, 1:obj.trial.targonind(obj.stimnum), obj.trial.ftrialy(1:obj.trial.targonind(obj.stimnum))./obj.trial.maxdeg, 'Color', 'k', 'Linewidth', obj.EYE_LINE_WIDTH);
                    obj.posttargety=plot(obj.haxes, obj.trial.targonind(obj.stimnum):length(obj.trial.ftrialy), obj.trial.ftrialy(obj.trial.targonind(obj.stimnum):end)./obj.trial.maxdeg, 'Color', 'k', 'Linewidth', obj.EYE_LINE_WIDTH);
                    obj.pretargetx=plot(obj.haxes, 1:obj.trial.targonind(obj.stimnum), obj.trial.ftrialx(1:obj.trial.targonind(obj.stimnum))./obj.trial.maxdeg, 'Color', 'k', 'Linewidth', obj.EYE_LINE_WIDTH, 'Tag', 'pretargetx');
                    obj.posttargetx=plot(obj.haxes, obj.trial.targonind(obj.stimnum):length(obj.trial.ftrialx), obj.trial.ftrialx(obj.trial.targonind(obj.stimnum):end)./obj.trial.maxdeg, 'Color', 'k', 'Linewidth', obj.EYE_LINE_WIDTH);
                end
            else
                 if obj.model.F.ignoretrial(obj.trial.trialnum)==0
                    set(obj.pretargety, 'xdata', 1:obj.trial.targonind(obj.stimnum), 'ydata', obj.trial.ftrialy(1:obj.trial.targonind(obj.stimnum))./obj.trial.maxdeg, 'Color', max(obj.trial.fc, obj.Y_COL) );
                    set(obj.posttargety, 'xdata', obj.trial.targonind(obj.stimnum):length(obj.trial.ftrialx), 'ydata', obj.trial.ftrialy(obj.trial.targonind(obj.stimnum):end)./obj.trial.maxdeg, 'Color', max(obj.model.c_pos, obj.Y_COL));
                    set(obj.pretargetx, 'xdata', 1:obj.trial.targonind(obj.stimnum), 'ydata', obj.trial.ftrialx(1:obj.trial.targonind(obj.stimnum))./obj.trial.maxdeg, 'Color', obj.model.c_stim_pretarg);
                    set(obj.posttargetx, 'xdata', obj.trial.targonind(obj.stimnum):length(obj.trial.ftrialx), 'ydata', obj.trial.ftrialx(obj.trial.targonind(obj.stimnum):end)./obj.trial.maxdeg, 'Color', obj.model.c_stim_posttarg);
                else
                    set(obj.pretargety, 'xdata', 1:obj.trial.targonind(obj.stimnum), 'ydata', obj.trial.ftrialy(1:obj.trial.targonind(obj.stimnum))./obj.trial.maxdeg, 'Color', 'k');
                    set(obj.posttargety, 'xdata', obj.trial.targonind(obj.stimnum):length(obj.trial.ftrialx), 'ydata', obj.trial.ftrialy(obj.trial.targonind(obj.stimnum):end)./obj.trial.maxdeg, 'Color', 'k');
                    set(obj.pretargetx, 'xdata', 1:obj.trial.targonind(obj.stimnum), 'ydata', obj.trial.ftrialx(1:obj.trial.targonind(obj.stimnum))./obj.trial.maxdeg, 'Color', 'k');
                    set(obj.posttargetx, 'xdata', obj.trial.targonind(obj.stimnum):length(obj.trial.ftrialx), 'ydata', obj.trial.ftrialx(obj.trial.targonind(obj.stimnum):end)./obj.trial.maxdeg, 'Color', 'k');
                end    
            end    
        end
        
        % Draw the target onsets
        function drawTargOnsets(obj)
            if isempty(obj.targon)
                obj.targon=line([obj.trial.targonind(obj.stimnum) obj.trial.targonind(obj.stimnum)], [-obj.trial.maxdeg obj.trial.maxdeg], 'Color', obj.TARG_LINE_COL, 'LineWidth', 2, 'Parent', obj.haxes);
                
                obj.targontext=text(obj.trial.targonind(obj.stimnum)-10, 0, 'TARGET', 'HorizontalAlignment', 'center', 'Color', obj.TARG_LINE_COL, 'FontWeight', 'bold', 'FontSize', 7, 'Clipping', 'On', 'Parent', obj.haxes, 'Visible', 'on', 'Rotation', 90);
                
            else
                set(obj.targon, 'xdata', [obj.trial.targonind(obj.stimnum) obj.trial.targonind(obj.stimnum)], 'ydata', [-obj.trial.maxdeg obj.trial.maxdeg]);
                
                set(obj.targontext, 'Position', [obj.trial.targonind(obj.stimnum)-10 0], 'String', 'TARGET', 'Visible', 'on');
            end
        end
        
        % Display all marks for a trial
        % TODO - refactor this so that objects aren't created when they
        % aren't needed.  However, with Matlab I believe creating and
        % deleting handles is slow in itself so there may not be a much
        % better solution.
        function displayMarks(obj)
            % INPUT:
            %   obj.trial.trialnum: - the trial number to display
            
            % Create the handles if necessary 
            % TODO: - some code replication and magic numbers here, not the greatest
            if isempty(obj.sacpatch)
                for s=1:obj.MAXMARKS
                    obj.sacpatch{s}=patch([1 1 1 1], [-1 -1 1 1], [0 0 0.9], 'FaceAlpha', 0.1, 'EdgeAlpha', 0.1, 'Parent', obj.haxes, 'Visible', 'off');
                    obj.sacon{s}=line([1 1], [-1.0 1.0], 'Color', 'k', 'Parent', obj.haxes, 'Visible', 'off');
                    obj.sacoff{s}=line([1 1], [-1.0 1.0], 'Color', 'k', 'Parent', obj.haxes, 'Visible', 'off');
                    obj.sactext{s}=text(1, 0.3, '', 'HorizontalAlignment', 'left', 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 12, 'Parent', obj.haxes, 'Visible', 'off');
                end
                
                for s=1:obj.MAXMARKS
                    obj.p_sacpatch{s}=patch([1 1 1 1], [-1 -1 1 1], [0 0 0.9], 'FaceAlpha', 0.05, 'EdgeAlpha', 0.05, 'Parent', obj.haxes, 'Visible', 'off');
                    obj.p_sacon{s}=line([1 1], [-1.0 1.0], 'Color', [0.25 0.25 0.25], 'Parent', obj.haxes, 'Visible', 'off');
                    obj.p_sacoff{s}=line([1 1], [-1.0 1.0], 'Color', [0.25 0.25 0.25], 'Parent', obj.haxes, 'Visible', 'off');
                    obj.p_sactext{s}=text(1, 0.3, '', 'HorizontalAlignment', 'left', 'Color', [0.5 0.5 0.5], 'FontWeight', 'bold', 'FontSize', 10, 'Parent', obj.haxes, 'Visible', 'off');
                end  
                
                for s=1:obj.MAXMARKS
                    obj.f_sacpatch{s}=patch([1 1 1 1], [-1 -1 1 1], [0 0 0.9], 'FaceAlpha', 0.05, 'EdgeAlpha', 0.05, 'Parent', obj.haxes, 'Visible', 'off');
                    obj.f_sacon{s}=line([1 1], [-1.0 1.0], 'Color', [0.25 0.25 0.25], 'Parent', obj.haxes, 'Visible', 'off');
                    obj.f_sacoff{s}=line([1 1], [-1.0 1.0], 'Color', [0.25 0.25 0.25], 'Parent', obj.haxes, 'Visible', 'off');
                    obj.f_sactext{s}=text(1, 0.3, '', 'HorizontalAlignment', 'left', 'Color', [0.5 0.5 0.5], 'FontWeight', 'bold', 'FontSize', 10, 'Parent', obj.haxes, 'Visible', 'off');
                end                 
            end
            
            sacs=obj.model.getMarkedSaccades(obj.trialnum, obj.stimnum);
            
            % Display the marks
            for i=1:min(length(sacs), obj.MAXMARKS)       
                % Draw the saccade if it exists 
                if ~isempty(sacs{i}.sacon)
                    set(obj.sacon{i}, 'xdata', [sacs{i}.sacon sacs{i}.sacon], 'Visible', 'on');
                    set(obj.sacoff{i}, 'xdata', [sacs{i}.sacoff sacs{i}.sacoff], 'Visible', 'on');
                    set(obj.sacpatch{i}, 'xdata', [sacs{i}.sacon sacs{i}.sacoff sacs{i}.sacoff sacs{i}.sacon], 'FaceColor', sacs{i}.col, 'Visible', 'on');
                    set(obj.sactext{i}, 'String', sacs{i}.tdisplay, 'Visible', 'on', 'Clipping', 'On');
                    set(obj.sactext{i}, 'Position', [sacs{i}.sacon 0.3], 'Color', sacs{i}.col);
                else
                    set(obj.sacon{i}, 'Visible', 'off');
                    set(obj.sacoff{i}, 'Visible', 'off');
                    set(obj.sacpatch{i}, 'Visible', 'off');
                    set(obj.sactext{i}, 'Visible', 'off');
                end
            end
            
            % Erase any remaining marks
            for s=(i+1):obj.MAXMARKS
                set(obj.sacon{s}, 'Visible', 'off');
                set(obj.sacoff{s}, 'Visible', 'off');
                set(obj.sacpatch{s}, 'Visible', 'off');
                set(obj.sactext{s}, 'Visible', 'off');
            end
            
            % Display the previous trial marks if they exist
            if obj.stimnum > 1
                sacs=obj.model.getMarkedSaccades(obj.trialnum, obj.stimnum-1);

                % Display the marks
                for i=1:min(length(sacs), obj.MAXMARKS)       
                    % Draw the saccade if it exists 
                    if ~isempty(sacs{i}.sacon)
                        set(obj.p_sacon{i}, 'xdata', [sacs{i}.sacon sacs{i}.sacon], 'Visible', 'on');
                        set(obj.p_sacoff{i}, 'xdata', [sacs{i}.sacoff sacs{i}.sacoff], 'Visible', 'on');
                        set(obj.p_sacpatch{i}, 'xdata', [sacs{i}.sacon sacs{i}.sacoff sacs{i}.sacoff sacs{i}.sacon], 'FaceColor', 'k', 'Visible', 'on');
                        set(obj.p_sactext{i}, 'String', [sacs{i}.tdisplay '-' num2str(obj.stimnum-1)], 'Visible', 'on', 'Clipping', 'On');
                        set(obj.p_sactext{i}, 'Position', [sacs{i}.sacon 0.3], 'Color', [0.5 0.5 0.5]);
                    else
                        set(obj.p_sacon{i}, 'Visible', 'off');
                        set(obj.p_sacoff{i}, 'Visible', 'off');
                        set(obj.p_sacpatch{i}, 'Visible', 'off');
                        set(obj.p_sactext{i}, 'Visible', 'off');
                    end
                end

                % Erase any remaining marks
                for s=(i+1):obj.MAXMARKS
                    set(obj.p_sacon{s}, 'Visible', 'off');
                    set(obj.p_sacoff{s}, 'Visible', 'off');
                    set(obj.p_sacpatch{s}, 'Visible', 'off');
                    set(obj.p_sactext{s}, 'Visible', 'off');
                end
            end
            
            % Display the following trial marks if they exist
            if obj.stimnum < obj.model.F.NSTIM
                sacs=obj.model.getMarkedSaccades(obj.trialnum, obj.stimnum+1);

                % Display the marks
                for i=1:min(length(sacs), obj.MAXMARKS)       
                    % Draw the saccade if it exists 
                    if ~isempty(sacs{i}.sacon)
                        set(obj.f_sacon{i}, 'xdata', [sacs{i}.sacon sacs{i}.sacon], 'Visible', 'on');
                        set(obj.f_sacoff{i}, 'xdata', [sacs{i}.sacoff sacs{i}.sacoff], 'Visible', 'on');
                        set(obj.f_sacpatch{i}, 'xdata', [sacs{i}.sacon sacs{i}.sacoff sacs{i}.sacoff sacs{i}.sacon], 'FaceColor', 'k', 'Visible', 'on');
                        set(obj.f_sactext{i}, 'String', [sacs{i}.tdisplay '-' num2str(obj.stimnum+1)], 'Visible', 'on', 'Clipping', 'On');
                        set(obj.f_sactext{i}, 'Position', [sacs{i}.sacon 0.3], 'Color', [0.5 0.5 0.5]);
                    else
                        set(obj.f_sacon{i}, 'Visible', 'off');
                        set(obj.f_sacoff{i}, 'Visible', 'off');
                        set(obj.f_sacpatch{i}, 'Visible', 'off');
                        set(obj.f_sactext{i}, 'Visible', 'off');
                    end
                end

                % Erase any remaining marks
                for s=(i+1):obj.MAXMARKS
                    set(obj.f_sacon{s}, 'Visible', 'off');
                    set(obj.f_sacoff{s}, 'Visible', 'off');
                    set(obj.f_sacpatch{s}, 'Visible', 'off');
                    set(obj.f_sactext{s}, 'Visible', 'off');
                end
            end            
        end  
        
        function delete(obj)
            if ishandle(obj.haxes)
                delete(obj.haxes); 
            end
            
            if ishandle(obj.hslider)
                delete(obj.hslider);
            end
            
            if ishandle(obj.htext)
                delete(obj.htext);
            end
        end
        
        function sliderupdate(obj, hObject, eventdata)
            val=get(hObject, 'Value');
            set(obj.haxes, 'Xlim', [val-obj.model.MINTIME, val+obj.model.MAXTIME]);
        end
        
        function buttondown(obj, src, evt)
            notify(obj, 'selectView');
        end
        
        % The model has been updated
        function modelUpdate(obj, src, evt)
            update(obj); 
        end
    end
   
end


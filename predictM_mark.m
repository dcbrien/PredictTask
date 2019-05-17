function varargout = predictMmark(varargin)
% predictMMARK M-file for predictMmark.fig - VERSION 1.1 - 12:28 PM 8/21/2006
%      predictMMARK, by itself, creates a new predictMMARK or raises the existing
%      singleton*.
%
%      H = predictMMARK returns the handle to a new predictMMARK or the handle to
%      the existing singleton*.
%
%      predictMMARK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in predictMMARK.M with the given input arguments.
%
%      predictMMARK('Property','Value',...) creates a new predictMMARK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before predictMmark_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to predictMmark_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help predictMmark

% Last Modified by GUIDE v2.5 17-Feb-2010 14:27:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @predictMmark_OpeningFcn, ...
                   'gui_OutputFcn',  @predictMmark_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before predictMmark is made visible.
function predictMmark_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to predictMmark (see VARARGIN)

% Choose default command line output for predictMmark
handles.output = hObject;

% DECLARE PARADIGM CONSTANTS HERE
handles.buttondown=0;   % Flag to keep track if the button has been pressed

handles.MAXECC=15;      % The default maximum eccentricity

handles.PPDGUESS=40;    % A guess at the pixels per degree if one isn't specified

handles.options=options(hObject, @optionspropertyFcn);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes predictMmark wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = predictMmark_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function trialslider_Callback(hObject, eventdata, handles)
% hObject    handle to trialslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    val=round(get(hObject,'Value'));

    handles.SET=val;
    
    for i=1:length(handles.posaxes)
        handles.posaxes{i}.updateTrialNum(handles.model.trialorder(handles.SET), i);        
        handles.posaxes{i}.update();
    end
    
    handles.speedaxes.updateTrialNum(handles.model.trialorder(handles.SET), 1);
    handles.speedaxes.update();
    
    handles.saccadeaxes.updateTrialNum(handles.model.trialorder(handles.SET), 1);
    handles.saccadeaxes.update();

    displayTitle(handles, hObject);
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function trialslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function filemenu_Callback(hObject, eventdata, handles)
% hObject    handle to filemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    c=get(gcf, 'CurrentCharacter');

    if ~isempty(c)
        code=uint8(c);
        
        if code==8 % BACKSPACE
            handles.model.resetMarks(handles.speedaxes);    %% Currently does nothing.
        elseif c=='z'||c=='Z'
            handles.model.setIgnore(handles.speedaxes);
        elseif c=='d'
            handles.model.setDeleteMode();
        else
            handles.model.setMark(c);
        end
        set(findobj('tag', 'currmark'), 'String', handles.model.current_mark_label);
    end

    % Update handles structure
    guidata(hObject, handles);
   
% --------------------------------------------------------------------
function openmenu_Callback(hObject, eventdata, handles)
% Open a file for marking
% hObject    handle to openmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try 
        load 'predictMprops';
    catch
    end    

    if exist('PathName') && isa(PathName, 'char')
        try
            [FileName,PathName] = uigetfile([PathName '*.mat'],'Select the Eyelink file');
        catch exception
            warning(exception.identifier, 'Corrupted property file');
            % Probably somthing wrong with the PathName
            [FileName,PathName] = uigetfile('*.mat','Select the Eyelink file');
            
        end
    else
        [FileName,PathName] = uigetfile('*.mat','Select the Eyelink file');
    end
    
    % User pressed cancel in the get file gui 
    if PathName == 0
        disp('No file selected');
        return
    end
    
    handles.PathName=PathName;
    
    if exist('predictMprops.mat', 'file')
        save('predictMprops', 'PathName', '-append');
    else
        save('predictMprops', 'PathName');
    end
    
    file=[PathName FileName];
    handles.file=FileName;
    handles.path=PathName;
    
    % Delete old handles if we are opening a new file and one was already
    % open
    if isfield(handles, 'speedaxes')
        for i=1:length(handles.posaxes)
            delete(handles.posaxes{i});
        end
        
        delete(handles.speedaxes);
        delete(handles.saccadeaxes);
    end
    
    if exist('NUMTRIALS')
        handles.NUMTRIALS=NUMTRIALS;
    else
        handles.NUMTRIALS=4;      % The number of trials to display vertically
    end  
    
    % If a file was selected, read it in.
    if file(1)~=0
        F=load(file);
        tf = isfield(F, 'F');
        if tf==1
            F=F.F;
            
            % This is the model that contains all of the marked data
            model=classes.model.predict_model(F,...
                750/(1000/F.SAMPRATE), 500/(1000/F.SAMPRATE));
            
            % Add the marks we want for this data.
            model.addMark(classes.marks.stepsac_mark(model));            
            model.addMark(classes.marks.regsac_mark(model)); 
        else
            error('Not a valid memory guided .mat file');
        end
    else
        return;
    end
    
    model.setTrialOrder('none', handles.NUMTRIALS);
    
    setSlider(hObject, handles, model);
    
    handles.SET=model.trialorder(1);      % Current set of trials being marked

    % Create the axis objects
  
    % Create the speed axes
    speedaxes=classes.views.speed_view(gcf, model, [0.057 0.05 0.61 0.25], 1, 1); 
    
    % Create the saccade axes
    saccadeaxes=classes.views.saccade_view(gcf, model, [0.70 0.05 0.25 0.25], 1, 1);     
    
    % The model listens for saccade selection updates for its marks
    addlistener(speedaxes,'selectSaccade', @model.saccadeSelected);
    
    % Each saccade axes listens for changes to the model properties
    addlistener(model, 'modelPropertyChange', @saccadeaxes.modelUpdate);
    
    % Create the position axes
    handles.paxespos=[0.057 0.93 0.87 0.50];    % The figure position of the x,y position axis

    handles.posaxes=createPosAxis(hObject, handles, model, speedaxes, saccadeaxes);
  
    handles.model=model;
    handles.speedaxes=speedaxes;
    handles.saccadeaxes=saccadeaxes;
    
    set(findobj('tag', 'currmark'), 'String', model.current_mark_label);
    
    displayTitle(handles, hObject);
    
    % Update handles structure
    guidata(hObject, handles);
    
function setSlider(hObject, handles, model)
    % Set the slider steps to NUMTRIAL increments
    trialslider = findobj('tag', 'trialslider');
    set(trialslider, 'Val', 1);

    sliderlength=length(model.trialorder);
    set(trialslider, 'Min', 1, 'Max', sliderlength, 'SliderStep', [1/(sliderlength-1) 1/(sliderlength-1)]);
    
function posaxes = createPosAxis(hObject, handles, model, speedaxes, saccadeaxes)
    nstim=model.F.NSTIM;
    
    nrows=handles.NUMTRIALS;
    ncols=ceil(nstim/nrows);
    
    stimcount=0;
    
    EPS=0.001; % This is a small fudge factor to shrink the axes slightly if needed
    
    for i=1:nrows
        for j=0:ncols-1  
            % Sometimes not every column in the last row needs to be used
            % so check for that by checking against the total number of
            % stimuli.
            if stimcount == nstim
                break;
            else
                stimcount=stimcount+1;
            end
            
            % Calculate the x and y position as well as width and height of each axis
            x=handles.paxespos(1)+j*handles.paxespos(3)/ncols;
            y=handles.paxespos(2)-i*handles.paxespos(4)/nrows;

            tposaxes=classes.views.paxes_view(handles.figure1, model, ...
                [x+EPS y+EPS handles.paxespos(3)/ncols-2*EPS handles.paxespos(4)/nrows-2*EPS], model.trialorder(1), stimcount);

            % The speed axes listens for button presses on the position axes
            addlistener(tposaxes,'selectView', @speedaxes.updateTrial);

            % The saccade axes listens for button presses on the position axes
            addlistener(tposaxes,'selectView', @saccadeaxes.updateTrial);

            % Each position axes listens for changes to the model properties
            addlistener(model, 'modelPropertyChange', @tposaxes.modelUpdate);

            posaxes{stimcount}=tposaxes;
        end
    end        
        
    
% --------------------------------------------------------------------
function savefile(handles)
% Saves the current marked file
    if isfield(handles, 'posaxes')
        F=handles.model.F;   
        
        % If this file hasn't been hand marked before, save it as an Mm
        % file
        if isempty(strfind(handles.file, 'Mm.mat'))
            save([handles.path handles.file(1:end-4) 'm.mat'], 'F');
        else
            save([handles.path handles.file], 'F');
        end
    end
    
% --------------------------------------------------------------------
function exitmenu_Callback(hObject, eventdata, handles)
% hObject    handle to exitmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function displayTitle(handles, hObject)
    htitlebar=findobj(gcf, 'Tag', 'Titlebar');
    
    isis=handles.model.F.isis;
    
    if isempty(isis)
        set(htitlebar, 'String', [handles.file ' -  Trial: '...
            num2str(handles.model.trialorder(handles.SET)) ' - Interleaved']);
    else
        set(htitlebar, 'String', [handles.file ' -  Trial: '...
            num2str(handles.model.trialorder(handles.SET)) ' - ISI: ' num2str(handles.model.F.isis(handles.SET))]);
    end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
    button = questdlg('Do you want to save your data before you exit?','Save data?', 'Yes', 'No', 'Yes');
    if strcmp(button,'Yes')==1
        savefile(handles);
    end
    delete(hObject);

% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    savefile(handles);

% --- Executes on mouse press over axes background.
function paxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to paxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    pos=get(gca, 'CurrentPoint');
    but=get(gcf, 'SelectionType');
    x=pos(1,1);
    y=pos(1,2);
    
    curry=floor((y-1)/2)+1;
    currx=floor(x/450)+1;
    
    if curry>0&&currx>0
        % Right mouse button means display velocity profile in details axis
        if strcmp(but, 'alt')==1
            handles.VEL=1;
            handles.CURR=12-(curry*4-1)+(currx-1);
            displayvel(handles, hObject);
        end
    end
    guidata(hObject, handles);



% --- Executes on mouse press over axes background.
function saxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to saxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)    
    
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on trialslider and no controls selected.
function trialslider_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to trialslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over trialslider.
function trialslider_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to trialslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Options_Callback(hObject, eventdata, handles)
% hObject    handle to Options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    set(handles.options.figure1, 'Visible', 'on');
  
function optionspropertyFcn(hObject)
    handles=guidata(hObject);
    
    if isfield(handles, 'posaxes')
        newnumtrials=get(handles.options.numaxes, 'Value');
        if newnumtrials~=handles.NUMTRIALS
            for i=1:length(handles.posaxes)
                delete(handles.posaxes{i});
            end
            handles.NUMTRIALS=newnumtrials;
            NUMTRIALS=handles.NUMTRIALS;
            save('predictprops', 'NUMTRIALS', '-append');
            handles.posaxes=createPosAxis(handles.figure1, handles, handles.model, handles.speedaxes, handles.saccadeaxes);
            setSlider(handles.figure1, handles, handles.model);
        end
    end
   
    guidata(hObject, handles);
    

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if ishandle(handles.options.figure1)
        delete(handles.options.figure1);
    end

function varargout = options(varargin)
% OPTIONS M-file for options.fig
%      OPTIONS, by itself, creates a new OPTIONS or raises the existing
%      singleton*.
%
%      H = OPTIONS returns the handle to a new OPTIONS or the handle to
%      the existing singleton*.
%
%      OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTIONS.M with the given input arguments.
%
%      OPTIONS('Property','Value',...) creates a new OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help options

% Last Modified by GUIDE v2.5 19-Jan-2010 14:04:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @options_OpeningFcn, ...
                   'gui_OutputFcn',  @options_OutputFcn, ...
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


% --- Executes just before options is made visible.
function options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to options (see VARARGIN)

handles.phObject=varargin{1};
handles.applyFcn=varargin{2};

% Choose default command line output for options
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes options wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = options_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;


% --- Executes on button press in applybutton.
function applybutton_Callback(hObject, eventdata, handles)
% hObject    handle to applybutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.applyFcn(handles.phObject);

% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.figure1, 'Visible', 'off');

% --- Executes on button press in closebutton.
function closebutton_Callback(hObject, eventdata, handles)
% hObject    handle to closebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.applyFcn(handles.phObject);
    set(handles.figure1, 'Visible', 'off');


% --- Executes on selection change in numaxes.
function numaxes_Callback(hObject, eventdata, handles)
% hObject    handle to numaxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns numaxes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from numaxes

% --- Executes during object creation, after setting all properties.
function numaxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numaxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', 1:10);

function predict_automark(varargin)
    % PREDCIT_AUTOMARK - Mark Eyelink 1000 .edf files and output a M.mat
    % file.  This assumes the standard predict Experiment Builder task with
    % corresponding message codes.
    
    skip=0; % A flag indicating whether to skip marked files or not.
    
    if(nargin==0)
        % Get directory from gui, and assume that 
        folder_name=uigetdir('.', 'Choose the directory that contains all .edf files');
        
        % Load in the data
        % Get all files ending in .edf in the path given.
        x=rdir([folder_name '\**\*edf']);
    elseif(nargin==2&&ischar(varargin{1})&&isnumeric(varargin{2})&&(varargin{2}==0||varargin{2}==1))
        % Directory was input manually
        
        % Load in the data
        % Get all files ending in .edf in the path given.
        x=rdir([varargin{1} '\**\*edf']);
        skip=varargin{2};
    else
        % Print usage information
        error('automarkError:InvalidArguments',...
            ['Usage: \n\tantipro_automark() OR \n' ...
            '\tantipro_automark(folder_name, skip)\n']);
    end
    
    % For each file in the directory
    for f=1:size(x, 1)
        file=x(f).name;
        if skip && exist([file(1:end-4) 'M.mat'], 'file')
            continue;
        end
        
        disp(['Marking - ' file]);
        
        predictReader=classes.utils.predictReader(file);
        
        F=predictReader.F;
        
        save([file(1:end-4) 'M'], 'F');
    end
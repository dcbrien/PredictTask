classdef edfReader < handle
    % EDFREADER This class is responsible for opening and reading
    % information from an .edf file.
    
    properties (SetAccess=private, GetAccess=public)
        file;
        
        % A structure to hold the output of the el2mat mex program
        M;
    end
    
    methods
        % Constructor
        function eobj=edfReader(f)
            eobj.file=f;
            
            load_edf(eobj);
        end
        
        % Get the experiment information structure
        function M=get.M(obj)
            M=obj.M;
        end
        
        % Read in all trials through mex program.
        function load_edf(obj)
            obj.M=el2mat(obj.file);
            
            if isempty(obj.M)
                error(edfReader:emptyOutput, 'Output of edf read is empty');
            end
        end
        
        % Get the resolution data
        function res=getRes(obj)
            res=obj.M.res;
        end
        
        % Get the sample data
        function sampledata=getSampleData(obj)
           sampledata=obj.M.sampledata;
        end
        
        % Get the event data
        function [eventdata, codes]=getEventData(obj)
           eventdata=obj.M.eventdata;
           codes=obj.M.codes;
        end        
        
        % --------------------------------------------------------------------
        % Get the pixel information from the file
        function F=pixelinfo(obj, F)
            % F     structure with F and user data (see GUIDATA).  This function also
            % returns this structure after adding pixel information to it.
            
            % Calculate the degree per pixel information
            mpixelinfo=char(obj.M.messages(strcellmatch(obj.M.messages, 'disttoscreen'), :));
            
            if isempty(mpixelinfo)
                error('Missing pixel information');
            end
            pixelnum=sscanf(mpixelinfo, '%*s %f %*s %f %*s %f %*s %f %*s %f');
            if length(pixelnum) ~= 4
                error('Missing pixel information');
            end
            F.pixelinfo.disttoscreen=pixelnum(1);
            F.pixelinfo.sheightinches=pixelnum(2);
            F.pixelinfo.swidthinches=pixelnum(3);
            
            % Calculate the pixels per degree
            F.PPD=atan2(F.pixelinfo.swidthinches/2, F.pixelinfo.disttoscreen)*180/pi;
            F.PPD=F.SCREENX/2/F.PPD;
            
            F.res.PPD=F.PPD;  % Replicated to be compatible with bcoe's code
        end
        
        % --------------------------------------------------------------------
        % Get eyelink message and offset time
        function [mestimes, mes]=getELmes(obj, s)
            % s     a cell array of strings to search for in the messages
            % mestimes  an array of the times the messages occured (adjusted by offset if necessary).
            % mes an array of the actual messages
            searchstr=[];
            if ~iscell(s)
                s={s};
            end
            for i=1:length(s)
                searchstr=[searchstr; strcellmatch(obj.M.messages, s{i})];
            end
            
            mestimes=obj.M.mestimes(searchstr);
            mes=char(obj.M.messages(searchstr, :));
            
            % finds the offset times that must be subtracted from the mestimes
            for i=1:size(mes, 1)
                offset=sscanf(mes(i,:), '%f');
                if ~isempty(offset)
                    mestimes(i)=mestimes(i)-offset;
                end
            end
        end
        
        % --------------------------------------------------------------------
        % Get sample max time
        function maxtime=getMaxSampleTime(obj)
            maxtime=obj.M.sampledata(end,1);
        end
    end
end
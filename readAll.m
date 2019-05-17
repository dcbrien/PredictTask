function E = readAll(p, varargin) 
    % function readAll
    % Usage: E = readAll(path, 'r')
    % Usage: E = readAll(path, 'r', 'store')
    %
    % Updated
    %
    % This function reads in hand marked data in the path provided and organizes
    % it in a structure, which can then be analyzed to provide statistics
    % on the data.
    %
    % Example:  E = readAll('marked data', 'r') will read all files ending in
    % Mm in the path marked data.  Adding 'r' will have it recurse through
    % subdirectories.
    %
    % Example:  E = readAll('marked data', 'r', 'store') will read all files ending in
    % Mm in the path marked data.  Adding 'r' will have it recurse through
    % subdirectories.   Adding 'store' will store the original marked data as
    % well, creating a larger structure
    %

    % A structure to hold everything
    E=struct;
    E.bsrts={};
    E.isrts={};
    E.names={};
    E.subs=[];
    E.isis=[];
    E.amps={};
    E.vels={};
    E.iamps={};
    E.ivels={};
    E.dir={};
    E.idir={};
    
    E.task=[];
    
    % microsaccade stats
    E.microsac={};
    E.hasMicrosac=[];
    E.microsac_blink=[];    % Whether they blinked during the microsaccade period
    E.microsac_macro_interrupt=[];  % Whether a macro-saccade interrupts the fixation period
    
    MICROSACCADE_VEL=8; % velocity cutoff for microsaccade
    MICROSACCADE_MINDUR=7; % minimum duration (in sample points) of velocity above threshold to be considered a microsaccade - 5 = 5 samples or 10 ms at 500Hz
    MICROSACCADE_LIMIT=3; % the largest amplitude microsaccade.  Anything larger than this is classified as a macrosaccade
    
    rdirs=0;
    store=0;
    
    if nargin > 1
        for i=2:nargin
            if ischar(varargin{i-1})
                switch lower(varargin{i-1})
                    case 'r' % search directories recursively
                        rdirs=1;
                    case 'store' % Store original data as well.  This creates a large file.
                        store=1;
                    otherwise
                        warning(['Unknown argument: ' varargin{k}]);
                end
            end
        end
    end

    % Load in the data
    if rdirs
        files=rdir([p '\**\*Mm.mat']);    % All mat files
    else
        files=dir([p '\*Mm.mat']);
    end

    for f=1:size(files,1)    
        %file=[p files{i}];
        file=files(f).name;
        
        if ~rdirs
            file=[p '\' file];
        end
        
        [pathstr fname]=fileparts(file);
        sub=fname(3:6);
        % Check if this subject has already been added to the structure
        ind=strmatch(sub, E.names, 'exact');
        newind=0;
        if isempty(ind)
            newind=1;
            ind = length(E.names)+1;
            E.names{ind}=[sub ' '];
        end

        disp(['Reading ' file]);
        F=load(file, '-mat');
        F=F.F;
  
        F.sacons=cell2mat(F.sacons');
        F.tonind=cell2mat(F.tonind');        
        
        if ~isfield(F, 'ignoretrial')
           F.ignoretrial=zeros(1, size(F.sacons, 1));
        end
        
%         SAMP_INT=1000/F.SAMPRATE;
        
        srts=[];

        for i=1:length(F.trials)
            srt=[];
            for j=1:size(F.sacons, 2)
                if F.sacons(i, j) < 0
                    srt=[srt NaN];
                else
                    srt=[srt (F.sac{i}(F.sacons(i, j), 1)-F.tonind(i, j))*F.SAMP_INT];
                end
            end
            
            srts=[srts; srt];
            
            if ~F.ignoretrial(i)
                E.subs=[E.subs ind];
                E.task=[E.task ~isempty(F.isis)];
                
                targon1ind=F.tonind(i, 1);
                
                % Using the microsaccade detection algorithm developed by
                % Ralf Engbert and Reinhold Kliegl, 2003, 2006
                
                FIX_RANGE=[-500 400];       % The length of fixation (in samples) relative to targonind (which will be 0 in this scale) to include in microsaccade analy
                FIX_CLEAN_RANGE=[-400 0];  % The length (in samples) before targonind (which will be 0 in this scale) that must be clean of blinks and macrosaccades to be include in microsaccade analysis
                BLINK_THRESHOLD=2000;       % Raw saccades with a position over 2000 are impossible (screen is only 1280 wide) and very highly correlate with blinks.
                
                raw_trial=F.rawtrials{i}(targon1ind+FIX_CLEAN_RANGE(1):targon1ind+FIX_CLEAN_RANGE(2), 2);
                if nnz(raw_trial>BLINK_THRESHOLD)
                    E.microsac_blink=[E.microsac_blink 1];
                else
                    E.microsac_blink=[E.microsac_blink 0];
                end
                microsac=findMSj(F.fixtrials{i}(targon1ind+FIX_RANGE(1):targon1ind+FIX_RANGE(2), [1 2]), F.SAMPRATE, 5, MICROSACCADE_MINDUR);
                
                FIX_CLEAN_START_IND=abs(FIX_RANGE(1))-abs(FIX_CLEAN_RANGE);
                
                if ~isempty(microsac) && ~isempty(find(microsac((microsac(:,2)> FIX_CLEAN_START_IND(1) & microsac(:,2) < FIX_CLEAN_START_IND(2)) | (microsac(:,1) > FIX_CLEAN_START_IND(1) & microsac(:,1) < FIX_CLEAN_START_IND(2)), 8) > MICROSACCADE_LIMIT))
                    E.microsac_macro_interrupt=[E.microsac_macro_interrupt 1];
                else
                    E.microsac_macro_interrupt=[E.microsac_macro_interrupt 0];
                end
                
                if(~isempty(microsac))
                    E.hasMicrosac=[E.hasMicrosac 1];
                    E.microsac=[E.microsac microsac];
                else
                    E.hasMicrosac=[E.hasMicrosac 0];
                    E.microsac=[E.microsac -9999];
                end
            end
        end
        
        % Calculate SRTs
        % Throw away all trials where a saccade was missing or marked too
        % long
        [r2]=find(srts > 1000);
        srts(r2)=NaN;
        amps=[];
        vels=[];
        
        dirmask=[repmat([F.targetdir' ~F.targetdir'], 1, floor(size(F.sacons, 2)/2)) F.targetdir'];
        dirmask=dirmask==1; % Convert to logical array
        
        % Calculate saccade metrics
        % for each trial
        for t=1:size(F.sacons, 1)
           % for each saccade
           for s=1:size(F.sacons, 2)
               sac=F.sacons(t,s);
               if sac > 0 && ~isnan(sac) && ~isnan(srts(t,s))
                   sacon=F.sac{t}(sac,1);
                   sacoff=F.sac{t}(sac,2);

                   if ~isempty(sacoff) && sacoff>0 && sacoff<length(F.fixtrials{t})
                       % Calculate the amplitude
                       x=F.fixtrials{t}(sacon:sacoff, :);

                       if ~isempty(x)
                            sac_epoint=[x(1,1) x(end,1) x(1,2) x(end,2)]';

                            sac_vec=[sac_epoint(2)-sac_epoint(1) sac_epoint(4)-sac_epoint(3)];
                            amps(t,s)=sqrt(sac_vec(1)*sac_vec(1)+sac_vec(2)*sac_vec(2));

                            % Calculate the peak velocity
                            vx=F.s{t}(sacon:sacoff);
                            vels(t,s)=max(vx);
                       end
                   end
                else
                   amps(t,s)=NaN;
                   vels(t,s)=NaN;
               end
           end
        end

        if ~isempty(F.isis)
            % Store the original data
            if store
                if newind
                    E.F{ind}=F;
                    E.F_I{ind}=[];
                else
                    E.F{ind}=[E.F{ind} F];
                end
            end

            % Blocked srts
            isis=unique(F.isis);
            E.isis=isis;
            
            % This is just to make sure that there aren't more isis listed than trials, which can
            % sometimes happen if an experiment is manually aborted
            F.isis=F.isis(1:length(F.trials));

            for j=1:length(isis)
                E.dir{ind, j}=dirmask(~F.ignoretrial&F.isis==isis(j), :);
                
                if newind
                    E.idir{ind}=[];
                    
                    E.bsrts{ind,j}=srts(~F.ignoretrial&F.isis==isis(j), :);
                    E.isrts{ind}=[];
                    
                    E.amps{ind, j}=amps(~F.ignoretrial&F.isis==isis(j), :);
                    E.iamps{ind}=[];
                    E.vels{ind, j}=vels(~F.ignoretrial&F.isis==isis(j), :);
                    E.ivels{ind}=[];
                else
                    if j<=length(E.bsrts)
                        E.bsrts{ind,j}=[E.bsrts{ind,j}; srts(~F.ignoretrial&F.isis==isis(j), :)];

                        E.amps{ind, j}=[E.amps{ind,j}; amps(~F.ignoretrial&F.isis==isis(j), :)];
                        E.vels{ind, j}=[E.vels{ind,j}; vels(~F.ignoretrial&F.isis==isis(j), :)];
                    else
                        E.bsrts{ind,j}=srts(~F.ignoretrial&F.isis==isis(j), :);

                        E.amps{ind, j}=amps(~F.ignoretrial&F.isis==isis(j), :);
                        E.vels{ind, j}=vels(~F.ignoretrial&F.isis==isis(j), :);
                    end
                end
            end
        else
            % Store the original data
            if store
                if newind
                    E.F_I{ind}=F;
                    E.F{ind}=[];
                else
                    E.F_I{ind}=[E.F_I{ind} F];
                end
            end
            
            E.idir{ind}=dirmask(~F.ignoretrial, :);
            
            % Interleaved srts
            if newind
                E.dir{ind, 1}=[];
                
                E.isrts{ind}=srts(~F.ignoretrial, :);
                E.bsrts{ind, 1}=[];
                
                E.iamps{ind}=amps(~F.ignoretrial, :);
                E.amps{ind, 1}=[];
                E.ivels{ind}=vels(~F.ignoretrial, :);
                E.vels{ind, 1}=[];
            else
                E.isrts{ind}=[E.isrts{ind}; srts(~F.ignoretrial, :)];
                
                E.iamps{ind}=[E.iamps{ind}; amps(~F.ignoretrial, :)];
                E.ivels{ind}=[E.ivels{ind}; vels(~F.ignoretrial, :)];
            end
        end
    end
end
    
    function [sac, radius] = findMSj(x,rate,VFAC,MINDUR)
    %-------------------------------------------------------------------
    %  FUNCTION microsaccj.m
    %  Detection of monocular candidates for microsaccades;
    %
    %  INPUT:
    %   x(:,1:2)         xy position 
    %   rate             sampling rate (1000 for 1000 HZ)
    %   VFAC             relative velocity threshold
    %   5 equivalent to 6 msec at 500Hz sampling rate  (ref E&R 2006)
    %   MINDUR           minimal saccade duration (ms)
    %   i.e. [sac radius] = microsaccj(x,1000,5,10);
    %
    %  OUTPUT:
    %   radius         threshold velocity (x,y) used to distinguish microsaccs
    %   sac(1:num,1)   onset of saccade
    %   sac(1:num,2)   end of saccade
    %   sac(1:num,3)   peak velocity of saccade (vpeak)
    %   sac(1:num,4)   horizontal component     (dx)
    %   sac(1:num,5)   vertical component       (dy)
    %   sac(1:num,6)   horizontal amplitude     (dX)
    %   sac(1:num,7)   vertical amplitude       (dY)
    %---------------------------------------------------------------------

    % SDS... VFAC (relative velocity threshold) E&M 2006 use a value of VFAC=5
    
    %velocity
    N = length(x(:,1));            % length of the time series
    vel = zeros(N,2);
%     vel(2:N-1,:) = [x(3:end,:) - x(1:end-2,:)]*rate/2;

    % New 5 point window for velocity calculations - just more smoothing
    vel(3:N-2,:) = [x(5:end,:) + x(4:end-1,:) - x(2:end-3,:) - x(1:end-4,:)]*rate/6;
    vel(2,:)     = [x(3,:) - x(1,:)]*rate/2;
    vel(N-1,:)   = [x(end,:) - x(end-2,:)]*rate/2;

    % compute threshold
    % SDS... this is sqrt[median(x^2) - (median x)^2]
    msdx = sqrt( median(vel(:,1).^2) - (median(vel(:,1)))^2 );
    msdy = sqrt( median(vel(:,2).^2) - (median(vel(:,2)))^2 );
    if msdx<realmin
        msdx = sqrt( mean(vel(:,1).^2) - (mean(vel(:,1)))^2 );
        if msdx<realmin
            warning('msdx<realmin in microsacc.m');
        end
    end
    if msdy<realmin
        msdy = sqrt( mean(vel(:,2).^2) - (mean(vel(:,2)))^2 );
        if msdy<realmin
            warning('msdy<realmin in microsacc.m');
        end
    end
    radiusx = VFAC*msdx;
    radiusy = VFAC*msdy;
    radius = [radiusx radiusy];

    % compute test criterion: ellipse equation
    test = (vel(:,1)/radiusx).^2 + (vel(:,2)/radiusy).^2;
    indx = find(test>1);

    % determine saccades
    % SDS..  this loop reads through the index of above-threshold velocities,
    %        storing the beginning and end of each period (i.e. each saccade)
    %        as the position in the overall time series of data submitted
    %        to the analysis
    N = length(indx);
    sac = [];
    nsac = 0;
    dur = 1;
    a = 1;
    k = 1;
    while k<N
        if indx(k+1)-indx(k)==1     % looks 1 instant ahead of current instant
            dur = dur + 1;
        else
            if dur>=MINDUR
                nsac = nsac + 1;
                b = k;             % hence b is the last instant of the consecutive series constituting a microsaccade
                sac(nsac,:) = [indx(a) indx(b)];
            end
            a = k+1;
            dur = 1;
        end
        k = k + 1;
    end

    % check for minimum duration
    % SDS.. this just deals with the final set of above threshold
    %       velocities; adds it to the list if the duration is long enough
    if dur>=MINDUR
        nsac = nsac + 1;
        b = k;
        sac(nsac,:) = [indx(a) indx(b)];
    end

    % compute peak velocity, horizonal and vertical components
    for s=1:nsac
        % onset and offset
        a = sac(s,1);
        b = sac(s,2);
        % saccade peak velocity (vpeak)
        vpeak = max( sqrt( vel(a:b,1).^2 + vel(a:b,2).^2 ) );
        sac(s,3) = vpeak;
        % saccade vector (dx,dy)            SDS..  this is the difference between initial and final positions
        dx = x(b,1)-x(a,1);
        dy = x(b,2)-x(a,2);
        sac(s,4) = dx;
        sac(s,5) = dy;

        % saccade amplitude (dX,dY)         SDS.. this is the difference between max and min positions over the excursion of the msac
        i = sac(s,1):sac(s,2);
        [minx, ix1] = min(x(i,1));              %       dX > 0 signifies rightward  (if ix2 > ix1)
        [maxx, ix2] = max(x(i,1));              %       dX < 0 signifies  leftward  (if ix2 < ix1)
        [miny, iy1] = min(x(i,2));              %       dY > 0 signifies    upward  (if iy2 > iy1)
        [maxy, iy2] = max(x(i,2));              %       dY < 0 signifies  downward  (if iy2 < iy1)
        dX = sign(ix2-ix1)*(maxx-minx);
        dY = sign(iy2-iy1)*(maxy-miny);
        sac(s,6:7) = [dX dY];
        [t2 r2]=cart2pol(sac(s,6), sac(s,7)); %JOSH added 01212015
        sac(s,8:9)=[r2 t2]; %JOSH added 01212015
    end  
end
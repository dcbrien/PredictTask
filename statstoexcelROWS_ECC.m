function statstoexcelROWS_ECC(E, fname, varargin)
    % function statstoexcel
    % This version stores the data in rows instead of one column per subject
    % This function generates stats for the predict tasks and outputs them
    % to an excel file.  This generates all the srts for each stimulus and each ECC as well as some
    % metrics like amplitude and duration of the first saccade.
    %
    % Input:
    %   E - the structure containing all data, which is output from the readAll function
    %   fname - the name of the excel file to output

    dir=0;
    
    if nargin > 2 && ischar(varargin{1}) && strcmp(varargin(1), 'dir')
        dir=1;
    end
    
    NSTIM=12;
    NODATA=-1000;
    
    sheader={'Subject', 'Stimulus'};    % srt stats header
    mheader=sheader;        % metric header
    stats=[];
    mstats=stats;

    stimnums=repmat(1:NSTIM, 1, length(E.names))';
    subnames=reshape(repmat(E.names, 12, 1), 1, NSTIM*length(E.names))';

    % Build the header
    for i=1:length(E.eccs)
        sheader=[sheader ['ECC' num2str(E.eccs(i)) 'SRT']];
        mheader=[mheader ['ECC' num2str(E.eccs(i)) '_Amp']];
    end

    sheader=[sheader 'int_S_SRT'];
    mheader=[mheader 'int_S_Amp'];
    
    if dir
        sheader=[sheader(1:2) strcat(sheader(3:end), '_L')];
        mheader=[mheader(1:2) strcat(mheader(3:end), '_L')];
        
        for i=1:length(E.eccs)
            sheader=[sheader ['ECC' num2str(E.eccs(i)) 'SRT_R']];
            mheader=[mheader ['ECC' num2str(E.eccs(i)) '_Amp_R']];
        end
        
        sheader=[sheader 'int_S_SRT_R'];
        mheader=[mheader 'int_S_Amp_R'];
    end

    for i=1:length(E.eccs)
        mheader=[mheader ['ECC' num2str(E.eccs(i)) '_Vel']];
    end
    
    mheader=[mheader 'int_S_Vel'];

    if dir
        mheader=[mheader(1:end-length(E.eccs)-1) strcat(mheader(end-length(E.eccs):end), '_L')];

        for i=1:length(E.eccs)
            mheader=[mheader ['ECC' num2str(E.eccs(i)) '_Vel_R']];
        end
        
        mheader=[mheader 'int_S_Vel_R'];
    end
    
    for s=1:length(E.names)
        sstats=[];
        smstats=[];
        % The blocked srts
        for i=1:length(E.eccs)
            if dir
                dirmask=E.dir{s, i};
            else
                % Use all data
                dirmask=E.dir{s, i}|~E.dir{s, i};
            end
            
            if ~isempty(E.bsrts{s, i})
                sstats=[sstats meanmask(E.bsrts{s, i}, dirmask)'];
            else
                sstats=[sstats linspace(NODATA, NODATA, NSTIM)'];
            end
            
            if ~isempty(E.amps{s, i})
                smstats=[smstats (meanmask(E.amps{s, i}, dirmask)/E.PPD)'];
            else
                smstats=[smstats linspace(NODATA, NODATA, NSTIM)'];
            end
        end
        
        if dir
            idirmask=E.idir{s};
        else
            % Use all data
            idirmask=E.idir{s}|~E.idir{s};
        end
        
        % The interleaved srts and metrics
        if ~isempty(E.isrts{s})
            sstats=[sstats meanmask(E.isrts{s}, idirmask)'];
        else
            sstats=[sstats linspace(NODATA, NODATA, NSTIM)'];
        end
        
        if ~isempty(E.iamps{s})
            smstats=[smstats (meanmask(E.iamps{s}, idirmask)/E.PPD)'];
        else
            smstats=[smstats linspace(NODATA, NODATA, NSTIM)'];
        end        
        
        if dir
            % For right targets
            
            % The blocked srts
            for i=1:length(E.eccs)
                dirmask=~E.dir{s, i};

                if ~isempty(E.bsrts{s, i})
                    sstats=[sstats meanmask(E.bsrts{s, i}, dirmask)'];
                else
                    sstats=[sstats linspace(NODATA, NODATA, NSTIM)'];
                end

                if ~isempty(E.amps{s, i})
                    smstats=[smstats (meanmask(E.amps{s, i}, dirmask)/E.PPD)'];
                else
                    smstats=[smstats linspace(NODATA, NODATA, NSTIM)'];
                end
            end

            idirmask=~E.idir{s};
            % The interleaved srts and metrics
            if ~isempty(E.isrts{s})
                sstats=[sstats meanmask(E.isrts{s}, idirmask)'];
            else
                sstats=[sstats linspace(NODATA, NODATA, NSTIM)'];
            end

            if ~isempty(E.iamps{s})
                smstats=[smstats (meanmask(E.iamps{s}, idirmask)/E.PPD)'];
            else
                smstats=[smstats linspace(NODATA, NODATA, NSTIM)'];
            end
        end
               
        % The blocked velocities
        for i=1:length(E.eccs)
            if dir
                dirmask=E.dir{s, i};
            else
                % Use all data
                dirmask=E.dir{s, i}|~E.dir{s, i};
            end
            
            if ~isempty(E.vels{s, i})
                smstats=[smstats (meanmask(E.vels{s, i}, dirmask)/E.PPD)'];
            else
                smstats=[smstats linspace(NODATA, NODATA, NSTIM)'];
            end
        end
        
        if dir
            idirmask=E.idir{s};
        else
            % Use all data
            idirmask=E.idir{s}|~E.idir{s};
        end

        % The interleaved velocities
        if ~isempty(E.ivels{s})
            smstats=[smstats (meanmask(E.ivels{s}, idirmask)/E.PPD)'];
        else
            smstats=[smstats linspace(NODATA, NODATA, NSTIM)'];
        end
        
        if dir
            % For right targets

            % The blocked velocities
            for i=1:length(E.eccs)
                dirmask=~E.dir{s, i};

                if ~isempty(E.vels{s, i})
                    smstats=[smstats (meanmask(E.vels{s, i}, dirmask)/E.PPD)'];
                else
                    smstats=[smstats linspace(NODATA, NODATA, NSTIM)'];
                end
            end
            
            idirmask=~E.idir{s};
            % The interleaved velocities
            if ~isempty(E.ivels{s})
                smstats=[smstats (meanmask(E.ivels{s}, idirmask)/E.PPD)'];
            else
                smstats=[smstats linspace(NODATA, NODATA, NSTIM)'];
            end
        end

        stats=[stats; sstats];
        mstats=[mstats; smstats];
    end

    xlswrite(fname, sheader, 1, 'A1');
    xlswrite(fname, subnames, 1, 'A2');
    xlswrite(fname, stimnums, 1, 'B2');
    xlswrite(fname, stats, 1, 'C2');
    
    xlswrite(fname, mheader, 2, 'A1');
    xlswrite(fname, subnames, 2, 'A2');
    xlswrite(fname, stimnums, 2, 'B2');
    xlswrite(fname, mstats, 2, 'C2');
 
% Returns the m means of a nxm maxtrix where the columns are masked by a nxm logical array   
function m=meanmask(data, mask)
    m=[];
    
    % for each column
    for i=1:size(data, 2)
        m=[m mean(data(mask(:, i), i))];
    end
        
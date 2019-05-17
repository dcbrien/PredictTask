function statstoexcel(E, fname, varargin)
    % function statstoexcel
    % This function generates stats for the predict tasks and outputs them
    % to an excel file.  This generates all the srts for each stimulus and each isi as well as some
    % metrics like amplitude and duration of the first saccade.
    %
    % Input:
    %   E - the structure containing all data, which is output from the readAll function
    %   fname - the name of the excel file to output
    
    dpp=1;
    
    if nargin > 2
        if ~isnumeric(varargin(1))
            dpp=varargin{1};
        else
            error('Argument 3 must be a number for DPP');
        end
    end
    
    NSTIM=size(E.bsrts{1,1},2);
    NODATA=-1000;
    
    sheader={'Subject'};    % srt stats header
    mheader=sheader;        % metric header
    stats=[];
    mstats=stats;

    % Build the header
    for i=1:length(E.isis)
        for snum=1:NSTIM
            sheader=[sheader ['isi' num2str(E.isis(i)) '_S' num2str(snum) '_SRT']];
            mheader=[mheader ['isi' num2str(E.isis(i)) '_S' num2str(snum) '_Amp']];
        end
    end

    for snum=1:NSTIM
        sheader=[sheader ['int_S_SRT' num2str(snum) ]];
        mheader=[mheader ['int_S_Amp' num2str(snum) ]];
    end
    
    for i=1:length(E.isis)
        for snum=1:NSTIM
            mheader=[mheader ['isi' num2str(E.isis(i)) '_S' num2str(snum) '_Vel']];
        end
    end

    for snum=1:NSTIM
        mheader=[mheader ['int_S_Vel' num2str(snum) ]];
    end

    for s=1:length(E.names)
        
        sstats=[];
        smstats=[];
        % The blocked srts
        for i=1:length(E.isis)
            if ~isempty(E.bsrts{s})
                sstats=[sstats nanmean(E.bsrts{s, i}, 1)];
            else
                sstats=[sstats linspace(NODATA, NODATA, NSTIM)];
            end
            
            if ~isempty(E.amps{s})
                smstats=[smstats nanmean(E.amps{s, i}, 1)/dpp];
            else
                smstats=[smstats linspace(NODATA, NODATA, NSTIM)];
            end
        end
        
        % The interleaved srts and metrics
        if ~isempty(E.isrts{s})
            sstats=[sstats nanmean(E.isrts{s}, 1)];
        else
            sstats=[sstats linspace(NODATA, NODATA, NSTIM)];
        end
        
        if ~isempty(E.iamps{s})
            smstats=[smstats nanmean(E.iamps{s}, 1)/dpp];
        else
            smstats=[smstats linspace(NODATA, NODATA, NSTIM)];
        end
        
        % The blocked velocities
        for i=1:length(E.isis)
            if ~isempty(E.vels{s})
                smstats=[smstats nanmean(E.vels{s, i}, 1)/dpp];
            else
                smstats=[smstats linspace(NODATA, NODATA, NSTIM)];
            end
        end
        
        % The interleaved velocities
        if ~isempty(E.ivels{s})
            smstats=[smstats nanmean(E.ivels{s}, 1)/dpp];
        else
            smstats=[smstats linspace(NODATA, NODATA, NSTIM)];
        end
        
        stats=[stats; sstats];
        mstats=[mstats; smstats];
    end

    xlswrite(fname, sheader, 1, 'A1');
    xlswrite(fname, E.names', 1, 'A2');
    xlswrite(fname, stats, 1, 'B2');
    
    xlswrite(fname, mheader, 2, 'A1');
    xlswrite(fname, E.names', 2, 'A2');
    xlswrite(fname, mstats, 2, 'B2');
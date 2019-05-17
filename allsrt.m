function allsrt(E, fname, varargin)
    % function allsrt
    % This function generates all srts for every subject
    %
    % Input:
    %   E - the structure containing all data, which is output from the readAll function
    %   fname - the name of the excel file to output
    %   varargin - you can also give a ppd for the metrics
    
    ppd=1;
    
    if nargin > 2
        if ~isnumeric(varargin(1))
            ppd=varargin{1};
        else
            error('Argument 3 must be a number for PPD');
        end
    end
    
    NSTIM=size(E.bsrts{1,1},2);
    NODATA=-9999;
    
    header={'Subject', 'SRT', 'Amp', 'Vel'};
    sheader={};    % srt stats header
    stats=[];

    for s=1:length(E.names)
        sstats=[];
        % The blocked srts

        sheader=[sheader; E.names{s}];
        sstats=NODATA;
        ampstats=NODATA;
        velstats=NODATA;

        for i=1:length(E.isis)
            for snum=1:NSTIM
                for j=1:size(E.bsrts{s, i}, 1)
                    sheader=[sheader; ['isi' num2str(E.isis(i)) '_S' num2str(snum) '_SRT']];
                end
            end
            sstats=[sstats reshape(E.bsrts{s, i}, 1, numel(E.bsrts{s, i}))];
            ampstats=[ampstats reshape(E.amps{s, i}/ppd, 1, numel(E.amps{s, i}))];
            velstats=[velstats reshape(E.vels{s, i}/ppd, 1, numel(E.vels{s, i}))];
        end

        % The interleaved srts and metrics
        for snum=1:NSTIM
            for j=1:size(E.isrts{s}, 1)
                sheader=[sheader; ['int_S_SRT' num2str(snum)]];
            end
        end

        sstats=[sstats reshape(E.isrts{s}, 1, numel(E.isrts{s}))];
        ampstats=[ampstats reshape(E.iamps{s}/ppd, 1, numel(E.iamps{s}))];
        velstats=[velstats reshape(E.ivels{s}/ppd, 1, numel(E.ivels{s}))];
        stats=[stats [sstats; ampstats; velstats]];
    end

    xlswrite(fname, header, 1, 'A1');
    xlswrite(fname, sheader, 1, 'A2');
    xlswrite(fname, stats', 1, 'B2');
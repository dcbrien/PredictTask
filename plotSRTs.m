function plotSRTs(E, t)
% function plotSRTs(E, t, varargin)


%     group=[];
%     if nargin > 2
%         if ischar(varargin{1})
%             group=varargin{1};
%         end
%     end

    LTHRESHOLD=-1000;
    HTHRESHOLD=1000;

    nsub=length(E.names);
    nisis=length(E.isis);
    
    cols=colormap(lines(nisis+1));
    
    numtarg=size(E.isrts{1}, 2);
%     
%     if isempty(group)
        subs=1:nsub;
%     else
%         names=char(E.names');
%         subs=strmatch(group, names(:,1));
%     end
%     
    handles=[];

    line([1 numtarg], [0 0], 'Color', [0.9 0.9 0.9]);
    hold on;
    for i=1:nisis
        tempbsrts=[];
        for j=1:length(subs)
            
            tsrts=E.bsrts{subs(j), i};
            if size(tsrts, 1) > 0
                [r c v]=find(tsrts<LTHRESHOLD|tsrts>HTHRESHOLD);       
                tsrts(r,:)=[];
    
                if ~isempty(tsrts)
                    tempbsrts=[tempbsrts; nanmean(tsrts, 1)];
                end
            end
        end
        
        if size(tempbsrts, 1) > 1
            % Standard error
            stderr=std(tempbsrts, 1)/sqrt(size(tempbsrts, 1));

            msrt=nanmean(tempbsrts, 1);
            posms=msrt+stderr;
            negms=msrt-stderr;

            patch([1:numtarg numtarg:-1:1], [posms negms(end:-1:1)],...
                cols(i,:), 'EdgeColor',...
                cols(i,:), 'FaceAlpha', 0.1,...
                'EdgeAlpha', 0.1);
        end
        
        handles=[handles plot(nanmean(tempbsrts, 1), 'Color', cols(i,:), 'Linewidth', 1.5)];
    end
    
    tempisrts=[];
    for j=1:length(subs)          
        tsrts=E.isrts{subs(j)};
        if size(tsrts, 1) > 0
            [r c v]=find(tsrts<LTHRESHOLD|tsrts>HTHRESHOLD);
            tsrts(r,:)=[];
            
            if ~isempty(tsrts)
                tempisrts=[tempisrts; nanmean(tsrts, 1)];
            end
        end
    end

    if size(tempisrts, 1) > 1
        % Standard error - TODO - Second argument to std?? Shouldn't be 1
        stderr=std(tempisrts)/sqrt(size(tempisrts, 1));

        msrt=nanmean(tempisrts, 1);
        posms=msrt+stderr;
        negms=msrt-stderr;

        patch([1:numtarg numtarg:-1:1], [posms negms(end:-1:1)],...
            cols(nisis+1,:), 'EdgeColor',...
            cols(nisis+1,:), 'FaceAlpha', 0.1,...
            'EdgeAlpha', 0.1);
    end
    
    handles=[handles plot(nanmean(tempisrts, 1), 'Color', cols(nisis+1,:), 'Linewidth', 1.5)];
    
    legend(handles, strvcat([num2str(E.isis')], 'interleaved'));

    set(gcf, 'Color', 'white');
    set(gca, 'Xlim', [1 numtarg], 'Ylim', [-250 400]);
    xlabel('Stimulus number');
    ylabel('SRT (ms)');
    title(t);
    
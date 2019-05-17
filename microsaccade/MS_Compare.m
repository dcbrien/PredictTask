function MS_Compare(leg_labels, task, varargin)
% Function MS_Compare - Plots microsaccades during fixation.  This assumes
% that the E structure has microsaccade data calculated during readAll
    %   input:  leg_labels = labels for the legends
    %           task: 0=Interleaved, 1=Predictive
    %           E structures from the predict readAll
    
    TASK=task; % 0=Interleaved, 1=Predictive
    
    SMOOTHING=50;  % Window amount to smooth the individual microsaccade rate data by
    
    RATE=500;   % Sample rate
    
    % TODO: These should be hard coded into the structure so this is not
    % repeated in multiple functions    
    MICROSACCADE_MIN_AMP=0.1; % the smallest amplitude microsaccade.
    MICROSACCADE_LIMIT=1.5; % the largest amplitude microsaccade.  Anything larger than this is classified as a macrosaccade
        
    FIX_WINDOW=500; % The window of fixation time sampled during fixation, ending with fixation off (in sample points)
    POST_FIX_WINDOW=400;    % The window of fixation time sampled after fixation off (in sample points)
    
    TOT_WINDOW=FIX_WINDOW+POST_FIX_WINDOW+1; % Total window of time sampled for microsaccades (in sample points)
    
    if(nargin > 2)
        numE=nargin-2;
        cols=lines(numE);
    else
        % Print usage information
        error('sactrace:InvalidArguments',...
            'Usage: \n\MS_Compare(leg_labels, E1, E2, E3...)\n');
    end

    h=[];   % The handles to figure lines
    h2=[];  % The handles for main sequence dots
    
    % For each structure
    for e=1:numE
        E=varargin{e};
       
        microsac_task_mask=E.task==TASK;
        
        microsac_mask=microsac_task_mask&~E.microsac_blink&~E.microsac_macro_interrupt;
    
        num_subs=length(E.names);
        
        freqs_all={};
        
        xlims=-FIX_WINDOW*1000/RATE+100:1000/RATE:POST_FIX_WINDOW*1000/RATE;
        figure(1);
        hold on;
        
        %   Pull out the microsaccades for each subject
        for i=1:num_subs
            % sub_mask: These are all potential trials that could go into the analysis - i.e., all trials for this particular subject that match the task conditions
            % but also do not contain a blink and are not interrupted by a
            % macrosaccade.  The length of this is the total number of
            % trials to normalize microsaccade rates by.
            sub_mask=E.subs==i&microsac_mask;
            
            % sub_microsac: These are all sub_mask trials that actually
            % contain a potential microsaccade (we define useable microsaccades
            % later by whatever limits we like).  This is used to iterate
            % through microsaccades and place in an array defining the
            % window of fixation around the target on.
            sub_microsac=cell2mat(E.microsac(E.hasMicrosac==1&sub_mask)');
            
            freqs=zeros(TOT_WINDOW,1);
            
            % Create an array of microsaccades counts for all microsaccades
            for j=1:size(sub_microsac, 1)
                % Now we refine our definition of microsaccade to whatever
                % amplitudes we choose.  Only those go into the rate
                % calculation
                if sub_microsac(j, 8) < MICROSACCADE_LIMIT && sub_microsac(j, 8) > MICROSACCADE_MIN_AMP
                    freqs(sub_microsac(j,1))=freqs(sub_microsac(j,1))+1;
                end
            end

            freqs=freqs/nnz(sub_mask)*RATE; % Convert to rate (1/s) - Divide by number of trials in condition and then convert to seconds (1000ms/s / 2 samples/ms)
            freqs=filtfilt(ones(1, SMOOTHING)/SMOOTHING, 1, freqs); % Smooth with a box filter 'SMOOTHING' wide
            
            freqs_all{i}=freqs;
        end 
        
        freqs_all_2mat=cell2mat(freqs_all);
        
        % We avoid the first 100ms because the filtering does strange
        % things at the ends of the time period
        h(e)=plot(xlims, nanmean(freqs_all_2mat(51:end,:),2), 'LineWidth', 4, 'Linestyle', ':', 'Color', cols(e, :));
        
        % Plot standard error around the average
        stderr_freq=std(freqs_all_2mat')/sqrt(size(freqs_all_2mat, 2));

        mfreq=nanmean(freqs_all_2mat, 2);
        posms=mfreq+stderr_freq';
        negms=mfreq-stderr_freq';

        patch([xlims fliplr(xlims)], [posms(51:end)' negms(end:-1:51)'],...
            cols(e,:), 'EdgeColor',...
            cols(e,:), 'FaceAlpha', 0.1,...
            'EdgeAlpha', 0.1);
        
        figure(2);
        % Plot main sequence to check validity of microsaccade detection
        allms=cell2mat(E.microsac(microsac_mask&E.hasMicrosac==1)');
        h2(e)=loglog(allms(:,8), allms(:,3), '.', 'Color', cols(e, :), 'MarkerSize', 1);
        hold on;
        
        % Print some quality control statistics to the console
        disp([leg_labels{e} ' - % Trials lost to blinks: ' num2str(nnz(E.microsac_blink(microsac_task_mask))/size(E.microsac_blink(microsac_task_mask), 2)*100) '%']);
        disp([leg_labels{e} ' - % Trials lost to macro saccades: ' num2str(nnz(E.microsac_macro_interrupt(microsac_task_mask))/size(E.microsac_macro_interrupt(microsac_task_mask), 2)*100) '%']);
        disp([leg_labels{e} ' - % Trials lost total: ' num2str(nnz(E.microsac_blink(microsac_task_mask) | E.microsac_macro_interrupt(microsac_task_mask))/size(E.microsac_macro_interrupt(microsac_task_mask), 2)*100) '%']);        
    end
    
    figure(1);
    ylims=get(gca, 'ylim');
   
    
    xlabel('Time relative to target (ms)');
    ylabel('MS rate (1/s)');
    
    % Avoid the first 100ms again so don't plot that.  Also only plot 100ms
    % after targeton (usually collect 400ms+ after target to avoid strange
    % end point smoothing again.  Not really interseted in the time after
    % targeton though due to macrosaccade differences mixing in with
    % microsaccades
    set(gca, 'xlim', [-FIX_WINDOW*1000/RATE+100 100]);
    
    legend(h, leg_labels);
    
    set(gcf, 'Color', 'White');

    if TASK==0
        title('Interleaved');
    else
        title('Predictive');
    end

    
    figure(2);
    
    xlabel('Amplitude (deg)');
    ylabel('Peak Vel (deg/s)');
    
    set(gca, 'xlim', [MICROSACCADE_MIN_AMP MICROSACCADE_LIMIT]);
    set(gca, 'ylim', [0 250]);
    
    legend(h2, leg_labels);
    
    set(gcf, 'Color', 'White');

    title('Main Sequence for all Microsaccades During Fixation');
    
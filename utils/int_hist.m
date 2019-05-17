function [val, cnt, h] =int_hist(x,samplerate,plot_it)
% function [val, cnt, h] =int_hist(x,[samplerate],[plot_it])
% or function cnt =int_hist(X,samplerate,[plot_it])
% returns the values and the counts of X for histogram plotting
% this is for use with large amounts of data with integer values.
% plot_it>1 for a simple plot: h=bar(val,cnt,'histc');
% the class of [samplerate] determines the class of val & cnt, defaults to 'single.'
%
% X = data
% samplerate = binsize, or what to round it off to (can be less that 1)
%   samplerate is a scaler so this will only return counts for actual values (with no cut offs)
% 	to fill gaps, use built-in (and slower) hist function or:
%   val2=min(val):samplerate:max(val);
% 	cnt2((val-val(1))/samplerate+1)=cnt;
%   h=bar(val2,cnt2,'histc');
%
% Other use:
%    [val cnt]=int_hist(x(:));clear val;
%    PDFx = single(cnt) / single(sum(cnt)); clear cnt
%    shannon_entropy = -sum( PDFx.*log(PDFx) );clear PDFx
%
% coe@queensu.ca


% 2007-11-28: added samplerate
% 2008-04-18: added plot_it & h (the graphics handle)
% 2013-02-15: added class specifier to samplerate. class out will match
%             class in, but we will boost them to singles for calculation
% bcoe


if nargin==0
    help(mfilename);
    return
end
if nargin<2
    eval(sprintf('samplerate=%s(1);',class(x)));
end
samplerate=single(samplerate);
xType =class(samplerate);
if length(samplerate)>1
    my_range=single(samplerate);
    samplerate=single(mean(diff(my_range))); % must be monotonically increasing
    x(x<my_range(1))=[];
    x(x>my_range(end))=[];
else
    my_range=0;
end
if nargin<3
    plot_it=false;
end
if nargout==0 && plot_it==false
    plot_it=1;
end
x(isnan(x))=[];
if isempty(x)
    val=my_range;
    cnt=my_range*0;
else
    x=single(x(:))-min(my_range);
    warning('off','MATLAB:intConvertNonIntVal')
    %% actual calculations
    %val=sort( floor(single(X(:))/single(samplerate)) ); %clear X
    val=sort(floor(x/samplerate)); %clear X
    loc=uint32([0;find((diff(val))>0)]+1);
    cnt=diff([loc-1; numel(val)]);
    val=(val(loc));clear loc;
    val=val*samplerate+min(my_range);
    %
    warning('on' ,'MATLAB:intConvertNonIntVal')
    if length(my_range)>1
        cnt2=my_range*0;
        cnt2(fix((val-my_range(1))/samplerate)+1)=cnt;
        %floor((val-my_range(1))/samplerate)+1
        val=my_range;
        cnt=cnt2;
    end
    
end % isempty X
if plot_it
    val2=min(val):samplerate:max(val);
    cnt2(round((val-val(1))/samplerate+1))=cnt;
    h=bar(val2,cnt2,'histc');
    set(gca,'UserData',h);
    set(h,'TAG','int_hist');
end

eval(sprintf('cnt=%s(cnt);',xType))
eval(sprintf('val=%s(val);',xType))

if nargout <2
    val=cnt;
    clear cnt
end

%% see mine's quicker ... and more accurate (check the first and last bin counts)
%t=rand(10000000,1)*1000;
%tic;[val  cnt ]=int_hist(t,5);toc
%tic;[cnt1 val1]=    hist(t,0:5:1000);toc


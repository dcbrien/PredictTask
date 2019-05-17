function h=vline(x,color,tag)
% function h=vline(x,[color],[tag])
% vline(x), where x can be a scaler or a vector
% draws a vertical line using the current axis as lims
%
% color has 3 options
% 1)  'b' '--' '--b'    % a string
% 2) [.5 0 .5]          % a vector
% 3) {'--',[.5 0 .5]}   % a 2 item cell, string then color vector
%
% see also hline, vfill, hfill
% 2000-jan-20
% bcoe@med.juntendo.ac.jp
% coe@queensu.ca
%

if nargin==0
    help(mfilename);
    return
end
if nargin <3
    tag='vline';
end
if ~ischar(tag)
    tag=num2str(tag);
end

temp=get(gca,'ylim');
%right=temp(2);
%left=temp(1);
top=temp(2);
bottom=temp(1);
x=x(:);
hh=zeros(length(x),1);
hold on
for i=1:length(x)
    if nargin<2
        hh(i)=plot([x(i) x(i)],[bottom top],'color',[.8 .8 .8],'tag',tag);
    else
        switch 1
            case ischar(color)
                if isempty(regexp(color,'[rgbcymkw]', 'once'))
                    hh(i)=plot([x(i) x(i)],[bottom top],color,'tag',tag,'color',[.8 .8 .8]);
                else
                    hh(i)=plot([x(i) x(i)],[bottom top],color,'tag',tag);
                end
            case isnumeric(color)
                hh(i)=plot([x(i) x(i)],[bottom top],'color',color,'tag',tag);
            case iscell(color) & length(color)==2 % {'--',[.5 .5 .5]}
                hh(i)=plot([x(i) x(i)],[bottom top],color{1},'color',color{2},'tag',tag);
            otherwise
                error(['bad color argument in ' mfilename])
        end % switch 1
    end
end
if nargout>0
    h=hh;
end
return

function h=vfill(left,right,color,alpha,tag)
% function h=vfill(left,right,color,alpha,tag)
% fills a vertical area using the current axis as lims
% right & left can be a scalar or a vector
% color is a 3 item vector. default = [.8 .8 .8]
% alpha is for opacity (0-[1])
% tag is for tag property for all objects (must be text)
%
% see also hfill, vline, hline
% 2000-jan-20
% bcoe@med.juntendo.ac.jp
% coe@queensu.ca
%

if nargin<2
    help(mfilename);
    return
end
if left==right
    h=0;
    return;
end
temp=get(gca,'ylim');
%right=temp(2);
%left=temp(1);
top=temp(2);
bottom=temp(1);
hh=zeros(length(top),1);
if nargin <3
    color=[.8 .8 .8];
end
if isempty(color)
    color=[.8 .8 .8];
end
if nargin <4
    alpha=1;
end
if nargin <5
    tag='vfill';
end
if ~ischar(tag)
    tag=num2str(tag);
end
hold on;
for i=1:length(left)
    hh(i)=fill([left(i) left(i) right(i) right(i)],[bottom top top bottom],color,'EdgeColor','none','FaceAlpha',alpha,'Tag',tag);
end
if nargout>0
    h=hh;
end
return
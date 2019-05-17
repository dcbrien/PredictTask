function [cell_loc, char_loc] =findincell(thecell,pattern,exact,not)
% function [cell_loc char_loc] = findincell(thecell,pattern,[exact],[not])
% thecell=	{'january';'february';'march';'april';'may';'june';'july';'august';'september';'october';'november';'december'};
% pattern='ar';
% exact =   truly exact match
% not  =   the cells that DON'T have the pattern. (cell_loc will not match char_loc as char_loc will still show which chars were matched)
% cell_loc = % which cell (a nice, useful vector)
%      1
%      2
%      3
% char_loc = % which character (alas, it must be an evil cell)
%     [5]
%     [6]
%     [2]
%
%SEE ALSO: strcellmatch
% ~bcoe

if nargin<2
    help(mfilename);
    return
end
if nargin<3
    exact=0;
end
if nargin<4
    not=0;
end
if iscell(pattern)
    pattern=pattern{:};
end
char_loc=strfind(thecell,pattern);
cell_loc=find(cellfun(@(x) ~isempty(x), char_loc));
if exact>0
    cell_lng=cellfun(@(x) length(x), thecell(cell_loc));
    cell_loc(cell_lng~=length(pattern))=[];    
end
char_loc=char_loc(cell_loc);
if not
    cell_loc=setxor(cell_loc,1:length(thecell))';
end

% if nargout==0
%     eval([pattern '_was_found_in =  thecell(cell_loc)'])
% end

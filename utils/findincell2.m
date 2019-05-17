function [cell_loc, char_loc] =findincell(thecell,patterns,exact,not)
% function [cell_loc char_loc] = findincell(thecell,patterns,[exact],[not])
% thecell=	{'january';'february';'march';'april';'may';'june';'july';'august';'september';'october';'november';'december'};
% patterns={'ar', 'ju'};
% exact =   truly exact match
% not  =   the cell sthat DON'T have the pattern. (cell_loc will not match char_loc as char_loc will still show which chars were matched)
% cell_loc = % which cell (a nice, useful vector)
%      1
%      2
%      3
%      6
%      7
% char_loc = % which character (alas, it must be an evil cell)
%     [5]
%     [6]
%     [2]
%     [1]
%     [1]
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
if ~iscell(patterns)
    patterns={patterns};
end
for ii = 1:length(patterns)
    tchar_loc=strfind(thecell,patterns{ii});
    cell_loc{ii}=find(cellfun(@(x) ~isempty(x), tchar_loc));
    if exact>0
        cell_lng=cellfun(@(x) length(x), thecell(cell_loc{ii}));
        cell_loc{ii}(cell_lng~=length(patterns{ii}))=[];        
    end
    char_loc{ii}=tchar_loc(cell_loc{ii});
    if not
        cell_loc{ii}=setxor(cell_loc(ii),1:length(thecell))';
    end
end
cell_loc=vertcat(cell_loc{:});
char_loc=vertcat(char_loc{:});

% if nargout==0
%     eval([pattern '_was_found_in =  thecell(cell_loc)'])
% end

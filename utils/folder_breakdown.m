function flist=folder_breakdown(fname,delim)
% function flist=folder_breakdown(fname)
% switch class(fname)
%     case 'char'
%         fname(fname==filesep)=char(165);
%         flist=textscan(fname,'%s','delimiter',char(165));
%         flist=flist{1};
%     case 'cell'
%         flist='';
%         for i = 1:length(fname)
%             flist=[flist fname{i} filesep]; %#ok<AGROW>
%         end
%         flist(end)=[]; % to match matlab standard
% end
% % bcoe
if nargin==0
    help (mfilename)
    return
end
switch class(fname)
    case 'char'
        if nargin<2
            delim=filesep;
        end
        fname(fname==delim)=char(165); % necessary because textscan can't except filesep (ID10T error)
        flist=textscan(fname,'%s','delimiter',char(165));
        flist=flist{1};
    case 'cell'
        flist='';
        for i = 1:length(fname)
            flist=[flist fname{i} filesep]; %#ok<AGROW>
        end
        %flist(end)=[]; % to match matlab standard
end
function b=rrdir(namefilter, startpath,type)
%FUNCTION rrdir(namefilter,[startpath],[type])
% namefilter = *?* filename filter
% startpath   = if not specified: pwd
% type         0= all; 1= folders only; 2= files only;
%
% ~bcoe coe@queensu.ca 2010

if nargin<1
    help(mfilename)
    return
end
if nargin==1
    startpath=pwd;
end
if isempty(startpath)
    startpath=pwd;
end
if nargin<3
    type=0;
end

if startpath(end)~=filesep
    startpath=[startpath filesep];
end
if exist(startpath,'dir')~=7
    error(' FUNCTION %s.m could not find ''%s'' \n',mfilename, startpath)
    %fprintf
    %startpath=pwd;
end


subfolders = textscan(find_all_folders(startpath), '%s', 'delimiter', pathsep);subfolders=subfolders{:};
%char_loc=strfind(subfolders,[ filesep '.']); % remove '\.' folders that start with .
%cell_loc=cellfun(@(x) ~isempty(x), char_loc);
%subfolders(cell_loc)=[];

b=[];
for i = 1:length(subfolders)
    if subfolders{i}(end)~=filesep
        subfolders{i}(end+1)=filesep;
    end
    a=dir([subfolders{i}  namefilter]);
    switch type
        case 1% folders only
            a(~[a.isdir])=[];
        case 2% files only
            a([a.isdir])=[];
        otherwise
    end
    if ~isempty(a)
        %c=strcat(repmat([subfolders{i} filesep],size(a),1), {a.name}');
        %[a.name]=deal(c{:});
        [a(:).parentfolder]=deal([subfolders{i}  ]);
        b=[b;a]; %#ok<AGROW>
    end % if ~isempty(a)
end % for i = 1:length(subfolders)

end % function
function l = strcellmatch(c, s)
% Given a cell array of strings, this function finds all instances of
% target string and returns a logical array indicating indicies in the cell
% contatining that string
% c the cell array
% s the target string
    l=find(cellfun(@(x) ~isempty(x), strfind(cellstr(c), s)));
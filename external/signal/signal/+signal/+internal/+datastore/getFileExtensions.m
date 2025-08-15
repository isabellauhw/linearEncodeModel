function [exts,areExtsUniform, uniqueList] = getFileExtensions(files)
%GETFILEEXTENSIONS Get a list of file extensions from input files
%For internal use only. It may be removed.
%   EXTS = getFileExtensions(FILES) returns a string wirh file extensions
%   for each file in string FILES.

validateattributes(files,"string",{'nonempty'});
exts = arrayfun(@(str)getExtension(str),files,'UniformOutput', true);

if nargout > 1    
    uniqueList = unique(exts);
    areExtsUniform = numel(uniqueList) == 1;
end

end

function ext = getExtension(str)
[~,~,ext] = fileparts(str);
ext = string(ext);
end
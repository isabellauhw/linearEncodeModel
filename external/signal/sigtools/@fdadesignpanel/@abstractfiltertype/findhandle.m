function hout = findhandle(h,arrayh,tag)
%FINDHANDLE Find handle to specified object from array.

%   Author(s): R. Losada & J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% If only a tag was passed in, search the stored array of handles.
if nargin < 3
    if ~isrendered(h)
        error(message('signal:fdadesignpanel:abstractfiltertype:findhandle:objectNotRendered'));
    end
    tag = arrayh;
    arrayh = allchild(h);
end

if ~isempty(arrayh)
    if ~all(ishandle(arrayh))
        error(message('signal:fdadesignpanel:abstractfiltertype:findhandle:invalidInputs'));
    end
    if ~iscell(tag), tag = {tag}; end
    
    searchString = {};
    for indx = 1:length(tag)
        searchString = {searchString{:}, 'Tag', tag{indx}, '-or'};
    end
    searchString(end) = [];
    
    hout = find(arrayh, searchString{:}, '-depth', 0);
else
    hout = [];
end

% [EOF]

function rmdynprop(h, varargin)
%RMDYNPROP   Remove a dynamic property.
%   RMDYNPROP(H, PROP) removes the dynamic property with the name PROP.
%
%   RMDYNPROP(H, PROP1, PROP2, etc) removes both PROP1 and PROP2, etc.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Define the storage property name
spname = 'DynamicPropListeners';

% Handle the not added yet case.
if ~isprop(h, spname) 
    for indx = 1:length(varargin)
        delete(findprop(h, varargin{indx}));
    end
    return;
end

listen = get(h, spname);

for indx = 1:length(varargin)

    % Find the property to remove.
    p = findprop(h, varargin{indx});
    if ~isempty(listen)
        
        % Remove the property listener for this property from our list.
        listen = setdiff(listen, find(listen, 'SourceObject', p));
    end
    delete(p);
    delete(findprop(h, sprintf('geck%s', varargin{indx})));
end

set(h, spname, listen);

% [EOF]

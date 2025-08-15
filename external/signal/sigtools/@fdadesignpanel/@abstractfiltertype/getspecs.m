function specs = getspecs(hObj)
%GETSPECS Returns the specs

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

props = find(hObj.classhandle.properties, 'Description', 'spec');
specs = get(props, 'Name');

% [EOF]

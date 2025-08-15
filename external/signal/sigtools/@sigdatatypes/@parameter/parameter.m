function this = parameter(name, tag, validValues, value)
%PARAMETER Create a parameter object
%   PARAMETER(NAME, TAG, VALIDVALUES, VALUE)

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(3,4);

if nargin < 4
    if iscell(validValues),    value = validValues{1}; end
    if isnumeric(validValues), value = validValues(1); end
end

% Instantiate the object
this = sigdatatypes.parameter;

set(this, 'ValidValues', validValues);
if iscell(validValues)
    if ~iscellstr(validValues)
        error(message('signal:sigdatatypes:parameter:parameter:MustBeCellOfStrings', '''ValidValues'''));
    end
    set(this, 'AllOptions', validValues);
end
set(this, 'Name', name);
set(this, 'Tag', tag);

createvalue(this);

% Set the parameters
setvalue(this, value);
if iscellstr(validValues) & ischar(value) 
    value = find(strcmpi(value, validValues)); 
end

set(this, 'DefaultValue', value);

% [EOF]

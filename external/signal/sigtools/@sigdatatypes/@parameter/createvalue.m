function createvalue(this)
%CREATEVALUE Create the value property.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

valid = get(this, 'ValidValues');

if iscell(valid)
    createvaluefromcell(this);
elseif isa(valid, 'function_handle')
    createValueFromFcn(this);
elseif isnumeric(valid)
    createValueFromVector(this);
elseif ischar(valid)
    % If valid is a string, it must be a predefined data type
    createValueFromType(this);
end

% -----------------------------------------------------------------------
function createValueFromType(this)

schema.prop(this, 'Value', this.ValidValues);

% -----------------------------------------------------------------------
function createValueFromFcn(this)

valid    = get(this, 'ValidValues');
typename = getuniquetype(this, valid);

schema.prop(this, 'Value', typename);

% -----------------------------------------------------------------------
function createValueFromVector(this)

vv = this.ValidValues;

if length(vv) ~= 2 && length(vv) ~= 3
    error(message('signal:sigdatatypes:parameter:createvalue:MustBeVector', '''ValidValues'''));
end

if vv(end) < vv(1)
    error(message('signal:sigdatatypes:parameter:createvalue:InvalidLastInputArg', '''ValidValues'''));
end

schema.prop(this, 'Value', 'double');

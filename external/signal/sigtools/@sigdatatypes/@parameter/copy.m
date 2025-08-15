function Hcopy = copy(this)
%COPY   Copy this object.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

for indx = 1:length(this)

    Hcopy(indx) = sigdatatypes.parameter;

    set(Hcopy(indx), ...
        'AllOptions', this(indx).AllOptions, ...
        'ValidValues', this(indx).ValidValues, ...
        'DisabledOptions', this(indx).DisabledOptions, ...
        'Name', this(indx).Name, ...
        'Tag',  this(indx).Tag, ...
        'DefaultValue', this(indx).DefaultValue);
    
    createvalue(Hcopy(indx));
    set(Hcopy(indx), 'Value', this(indx).Value);
end

% [EOF]

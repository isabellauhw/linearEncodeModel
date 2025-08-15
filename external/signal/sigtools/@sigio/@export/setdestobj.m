function setdestobj(this, construct)
%SETDESTOBJ Utility function to create a destination object.

% This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

hD = getcomponent(this, '-class', construct);

if isempty(hD)
    hD = feval(construct,this.Data);
    set(hD, 'Toolbox', this.Toolbox);
    addcomponent(this, hD);
    if isa(hD, 'sigio.abstractxpdestwvars')
        set(hD, 'DefaultLabels', this.DefaultLabels);
    end
else
    set(hD,'Data',this.data);
end

set(this,'Destination',hD);

% [EOF]

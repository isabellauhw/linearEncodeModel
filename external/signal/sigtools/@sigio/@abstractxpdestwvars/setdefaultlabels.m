function deflabels = setdefaultlabels(this, deflabels)
%SETDEFAULTLABELS   

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

this.privDefaultLabels = deflabels;

deflabels = [];

if isprop(this, 'ExportAs') & isdynpropenab(this,'ExportAs') & strcmpi(this.ExportAs,'Objects')
    parse4obj(this);
else
    parse4vec(this);
end

% [EOF]

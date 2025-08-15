function varargout = abstract_genmcode(h, d)
%ABSTRACT_GENMCODE

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Set up design params
[Fpass, Dpass] = getdesignspecs(h, d);

params = {'Fpass', 'Dpass'};
values = {getmcode(d, Fpass), getmcode(d, Dpass)};

if nargout > 1
    varargout = {params, values, cell(size(params))};
else
    b = sigcodegen.mcodebuffer;

    b.addcr(b.formatparams(params, values));
    
    varargout = {b};
end

% [EOF]

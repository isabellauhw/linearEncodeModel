function loadreferencecoefficients(this, s)
%LOADREFERENCECOEFFICIENTS   Load the reference coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.

% Necessary to load the States properly
if isfield(s,'privnstates')||isprop(s,'privnstates')
    this.privnstates = s.privnstates;
end
% [EOF]

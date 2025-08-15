function loadreferencecoefficients(this, s)
%LOADREFERENCECOEFFICIENTS

%   Author(s): V. Pellissier
%   Copyright 2005-2006 The MathWorks, Inc.

if isfield(s,'reffracdelay')|| isprop(s,'reffracdelay')
    this.FracDelay =  s.reffracdelay;
end

% [EOF]

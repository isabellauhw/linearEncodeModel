function loadreferencecoefficients(this,s)
%LOADREFERENCECOEFFICIENTS   

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.

if isfield(s,'refallpasscoeffs')||isprop(s,'refallpasscoeffs')
    this.refallpasscoeffs = s.refallpasscoeffs;
end

% [EOF]

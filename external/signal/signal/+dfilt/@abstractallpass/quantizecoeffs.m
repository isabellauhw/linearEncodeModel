function quantizecoeffs(this,eventData)
%QUANTIZECOEFFS   

%   Author(s): R. Losada
%   Copyright 2005-2017 The MathWorks, Inc.

% Quantize the coefficients
this.privallpasscoeffs = quantizecoeffs(this.filterquantizer,this.refallpasscoeffs);

% [EOF]

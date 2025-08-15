function s = setsosmatrix(this,s)
%SETSOSMATRIX Set the SOS matrix.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

% Set the reference and check datatype
this.refsosMatrix = s;

% Set the new number of sections
oldnsections = this.nsections;
nsections = size(s,1);
this.nsections = nsections;

set_ncoeffs(this.filterquantizer, 6*nsections);

% Quantize the coefficients
quantizecoeffs(this);

if nsections~=oldnsections
    % Reset the filter
    reset(this);
    this.ScaleValues = this.ScaleValues(1:end-this.NumAddedSV);
end

% Don't duplicate storage
s = []; 

clearmetadata(this);

% [EOF]

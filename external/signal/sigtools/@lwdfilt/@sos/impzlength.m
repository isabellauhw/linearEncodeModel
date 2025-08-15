function len = impzlength(this, varargin)
%IMPZLENGTH Length of the impulse response for a digital filter.

%   Copyright 1988-2012 The MathWorks, Inc.

% Get SOS matrix, set embedScaleValues falg to false
sosMatrix = getsosmatrix(this,false);

len = impzlength(sosMatrix,varargin{:});


function len = impzlength(this, varargin)
%IMPZLENGTH Length of the impulse response for a digital filter.

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.

len = impzlength(this.Numerator,this.Denominator,varargin{:});

% [EOF]

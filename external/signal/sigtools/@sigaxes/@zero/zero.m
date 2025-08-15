function hObj = zero(varargin)
%ZERO Construct a zero object
%   ZERO(NUM) Construct a zero object using the double NUM.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

hObj = sigaxes.zero;

construct_root(hObj, varargin{:});

% [EOF]

function hObj = pole(varargin)
%POLE Construct a pole object
%   POLE(NUM) Construct a pole object using the double NUM.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

hObj = sigaxes.pole;

construct_root(hObj, varargin{:});

% [EOF]

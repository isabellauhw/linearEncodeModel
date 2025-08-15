function realizemdl(H,varargin)
%REALIZEMDL Filter realization (Simulink diagram).
%     REALIZEMDL(Hd) automatically generates architecture model of filter
%     Hd in a Simulink subsystem block using individual sum, gain, and
%     delay blocks, according to user-defined specifications.
%
%     REALIZEMDL(Hd, PARAMETER1, VALUE1, PARAMETER2, VALUE2, ...) generates
%     the model with parameter/value pairs.
%
%     See also DFILT/REALIZEMDL

%   Copyright 2006-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

super_realizemdl_composite(H,varargin{:});

% [EOF]

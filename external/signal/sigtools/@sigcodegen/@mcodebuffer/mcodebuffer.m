function hObj = mcodebuffer(varargin)
%MCODEBUFFER Construct a MCODEBUFFER object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

hObj = sigcodegen.mcodebuffer;

if nargin > 0
    hObj.add(varargin);
end

% [EOF]

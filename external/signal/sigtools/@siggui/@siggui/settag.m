function settag(h, tag)
%SETTAG Set up the base elements of the object
%   SETTAG(H, TAG)
%
%   Inputs:
%       TAG     - The tag of the object
%
%   If no input is given <package>.<class> is used.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

if nargin < 2, tag = class(h); end
set(h, 'Tag', tag);

% [EOF]

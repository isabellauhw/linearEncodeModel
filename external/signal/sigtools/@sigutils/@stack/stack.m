function hStack = stack(limit)
%STACK Construct a stack
%   STACK(LIMIT) Construct a stack whose maximum length is LIMIT.  If not
%   entered, the stack will default to 20.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

if nargin == 0, limit = 20; end

hStack = sigutils.stack;

set(hStack,'StackLimit',limit);

% [EOF]

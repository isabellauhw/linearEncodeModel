function OP = copy(op)
% copy method to force a deep copy.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.

narginchk(1,1);

OP = feval(str2func(class(op)));

OP.selfIndex = op.selfIndex;
OP.nodeIndex = op.nodeIndex;

if ~isempty(op.to)
    OP.to = copy(op.to);
end 

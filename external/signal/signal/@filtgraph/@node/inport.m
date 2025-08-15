function inp = inport(Node,index)

%   Author(s): Roshan R Rammohan

%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,2);

N = Node;

if nargin > 1
    inp = N.block.inport(index);
else
    if ~isempty(N.block.inport)
        inp = N.block.inport(1);
    else
        error(message('signal:filtgraph:node:inport:InternalError'));
    end
end

function op = outport(Nindex,Sindex,NodesAndPorts)
%outport Constructor for this class.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.

narginchk(0,3);

op = filtgraph.outport;

if nargin > 1
    op.nodeIndex = Nindex;
    op.selfIndex = Sindex;
end

if nargin > 2
    op.setto(NodesAndPorts);
end



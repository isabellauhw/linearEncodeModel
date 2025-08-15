function op = addto(Op,newnodeports)
%outport sets the input ports that accept output from this output port

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.

narginchk(1,2);

if nargin > 0
    op=Op;
end

if nargin > 1
    op.setto([op.to(:); newnodeports(:)]);
end

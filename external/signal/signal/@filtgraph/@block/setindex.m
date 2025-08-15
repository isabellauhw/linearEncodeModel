function B = setindex(Bi,index)

%   Author(s): Roshan R Rammohan

%   Copyright 1988-2004 The MathWorks, Inc.

narginchk(2,2);
B=Bi;

B.nodeIndex = index;

for I = 1:length(B.outport)
    B.outport(I).setindex(index);
end

for I = 1:length(B.inport)
    B.inport(I).setindex(index);
end


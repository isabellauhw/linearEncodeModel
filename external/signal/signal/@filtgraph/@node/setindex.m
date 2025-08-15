function N = setindex(Ni,index)
%SETINDEX

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.

narginchk(2,2);

N = Ni;
N.index = index;

if ~(N.block.nodeIndex == index)
    N.block.setindex(index);
end

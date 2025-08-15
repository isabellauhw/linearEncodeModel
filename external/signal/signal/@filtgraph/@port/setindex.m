function P = setindex(Pi,index)

%   Author(s): Roshan R Rammohan

%   Copyright 1988-2004 The MathWorks, Inc.

narginchk(2,2);
P = Pi;

P.nodeIndex = index;

function indparm = qindexparam(index,paramlist)
%ASSOC Constructor for this class.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.

narginchk(2,2);

indparm = filtgraph.qindexparam;

indparm.index = index;

indparm.params = paramlist;

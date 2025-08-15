function L = length(NodeList)
%LENGTH of NodeList

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.

narginchk(1,1);

NL = NodeList;
L = length(NL.nodes);

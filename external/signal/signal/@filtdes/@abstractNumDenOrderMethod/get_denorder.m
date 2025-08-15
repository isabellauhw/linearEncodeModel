function M = get_denorder(h,dummy)
%GET_DENORDER Get the denominator order property.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.

narginchk(2,2);

% Get handle to num den filter order object
g = get(h,'numDenFilterOrderObj');

% Get value
M = get(g,'denOrder');


function update_variables(this)
%UPDATE_VARIABLES Update the variables frame

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Switch on the filterstructure to determine field of the structure.
% We need two lists for qfilts & dfilts
fClass = classname(this.Filter);
fClass(1:6) = [];
switch fClass
    case {'df1','df1t','df2','df2t','df1sos','df1tsos','df2sos','df2tsos'}
        field = 'tf';
    case {'dffir','dfsymfir','dfasymfir','dffirt'}
        field = 'fir';
    case {'latticema','latticear','latticeallpass', 'calattice', ...
            'calatticepc', 'latticemamax', 'latticemamin'}
        field = 'lattice';
    case 'latticearma'
        field = 'latticearma';
    case 'statespace'
        field = 'statespace';
end

hv = getcomponent(this, '-class', 'siggui.varsinheader');

% Set the CurrentStructure according to the structure of the filter
set(hv, 'CurrentStructure', field);

% [EOF]

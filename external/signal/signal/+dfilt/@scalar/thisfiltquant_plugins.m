function constr = thisfiltquant_plugins(h,arith)
%FILTQUANT_PLUGINS Table of filterquantizer plugins

%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

switch arith
    case 'fixed'
        %#function quantum.fixedscalarfilterq
        constr = 'quantum.fixedscalarfilterq';
end

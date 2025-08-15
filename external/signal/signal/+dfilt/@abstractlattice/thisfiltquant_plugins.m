function constr = thisfiltquant_plugins(h,arith)
%FILTQUANT_PLUGINS Table of filterquantizer plugins

%   Author(s): V. Pellissier
%   Copyright 1999-2017 The MathWorks, Inc.

switch arith
    case 'fixed'
        %#function quantum.fixedlatticefilterq
        constr = 'quantum.fixedlatticefilterq';
end

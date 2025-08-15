function constr = thisfiltquant_plugins(h,arith)
%FILTQUANT_PLUGINS Table of filterquantizer plugins

%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

switch arith
    case 'fixed'
        %#function quantum.fixeddffirtfilterq
        [wstr, wid] = lastwarn;
        w = warning('off');
        constr = 'quantum.fixeddffirtfilterq';
        lastwarn(wstr, wid)
        warning(w);
end

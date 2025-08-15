function g = setgain(Hd, g)
%

%   Copyright 1988-2005 The MathWorks, Inc.

% Check data type and store Gain as reference
if isempty(g)
    error(message('signal:dfilt:schema:Empty')); 
end

Hd.refgain = g;

set_ncoeffs(Hd.filterquantizer, 1);

% Quantize the gain
quantizecoeffs(Hd);

% clear metadata
clearmetadata(Hd);

% Hold an empty to not duplicate storage
g = [];

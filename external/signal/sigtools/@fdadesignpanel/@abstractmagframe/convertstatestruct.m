function sout = convertstatestruct(hObj, sin)
%CONVERTSTATESTRUCT Convert to the new state structure

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

strs  = getstatefield(hObj);
props = allprops(hObj);

try
    
    sin   = sin.mag.(strs{1});
    
    sout.Tag      = class(hObj);
    sout.Version  = 0;
    sout.magUnits = sin.units;
    
    for indx = 1:length(sin.(strs{2}))
        sout.(props{indx}) = sin.(strs{2}){indx};
    end
catch
    sout = [];
end

% [EOF]

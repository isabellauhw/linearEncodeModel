function newA = postprocessmask(this, oldA, units)
%POSTPROCESSMASK - Change the mask according to passband offset value.

%   Copyright 1999-2015 The MathWorks, Inc.

newA = oldA;

switch(units)
    case 'db'
        gain = this.PassbandOffset;
        newA(3) = oldA(3) + gain;        
        newA(10) = oldA(10) + gain;        
    case {'linear', 'zerophase'}
        gain = convertmagunits(this.PassbandOffset,'db','linear','amplitude');
        newA(3) = oldA(3) + gain - 1;       
        newA(10) = oldA(10) + gain - 1;        
    case 'squared'
        gain = convertmagunits(this.PassbandOffset,'db','linear','amplitude');
        newA(3) = (oldA(3) + gain - 1)^2;
        newA(10) = (oldA(10) + gain - 1)^2 ;
end
newA(4) = newA(3);
newA(11) = newA(10);

% [EOF]


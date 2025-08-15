function disp(Hb)
%DISP Object display.
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2005 The MathWorks, Inc.

if length(Hb) > 1
    vectordisp(Hb);
else
    thisdisp(Hb)
end


% [EOF]

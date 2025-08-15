function setorder(h, orderStr)
%SETORDER Set the length of the filter

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

try
    order = evaluatevars(orderStr);
    set(h.privWindow, 'Length', order);
catch %#ok<CTCH> 
  str = getString(message('signal:siggui:firwinoptionsframe:setorder:InvalidVar'));
  warning(h, str);  % warning is a method of h not the function
end

% [EOF]

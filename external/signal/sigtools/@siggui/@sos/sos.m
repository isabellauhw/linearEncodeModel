function hSOS = sos(filtobj)
%SOS Create an SOS Converter dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

narginchk(1,1);

hSOS = siggui.sos;

hSOS.Filter = filtobj;

set(hSOS,'Version',1);
settag(hSOS);

% [EOF]

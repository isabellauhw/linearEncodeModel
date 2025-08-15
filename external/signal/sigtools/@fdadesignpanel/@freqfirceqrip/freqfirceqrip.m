function h = freqfirceqrip
%FREQFIRCEQRIP Constructor

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

h = fdadesignpanel.freqfirceqrip;

% Setup the dynamic property
setspectype(h, get(h, 'FreqSpecType'));

% [EOF]

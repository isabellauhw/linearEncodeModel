function hFs = fsspecifier
%FSSPECIFIER Constructor for the sampling frequency specifier

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

narginchk(0,0);

hFs = siggui.fsspecifier;

setstate(hFs,defaultfs);
set(hFs,'Version',1);


% -----------------------------------------------------
function specs = defaultfs

specs.units = 'Normalized (0 to 1)';
specs.value = 'Fs';

% [EOF]

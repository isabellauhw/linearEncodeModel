function invert(hObj, about)
%INVERT Invert about the imaginary axis
%   INVERT(hOBJ, STR) Invert the current pz about where STR can be
%   'imaginary', 'real', or 'unitcircle'

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

hPZ = get(hObj, 'CurrentRoots');

if isempty(hPZ)
    error(message('signal:siggui:pzeditor:invert:noPoleZeroSelected'));
end

opts = {'imaginary', 'real', 'unitcircle'};
indx = strmatch(about, opts);

if isempty(indx)
    error(message('signal:siggui:pzeditor:invert:invalidAction', about));
end

about = [opts{indx} '_fcn'];

newvalue = feval(about, hPZ);

setvalue(hPZ, newvalue);

% -------------------------------------------------------------------------
function newvalue = imaginary_fcn(hPZ)

newvalue = conj(double(hPZ))*-1;

% -------------------------------------------------------------------------
function newvalue = real_fcn(hPZ)

newvalue = conj(double(hPZ));

% -------------------------------------------------------------------------
function newvalue = unitcircle_fcn(hPZ)

newvalue = invertunitcircle(hPZ);

% [EOF]

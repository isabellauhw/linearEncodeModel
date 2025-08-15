function mirror(hObj, about)
%MIRROR Mirror about the current roots
%   MIRROR(hOBJ, STR) Mirror the current pz

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

hPZ = get(hObj, 'CurrentRoots');

if isempty(hPZ)
    error(message('signal:siggui:pzeditor:mirror:noPoleZeroSelected'));
end

opts = {'imaginary', 'real', 'unitcircle'};
indx = strmatch(about, opts);

if isempty(indx)
    error(message('signal:siggui:pzeditor:mirror:invalidAction', about));
end

hCopy = copy(hPZ);
set(hCopy, 'Current', 'Off');

about = [opts{indx} '_fcn'];

setvalue(hCopy, feval(about, hCopy));

for indx = 1:length(hCopy)
    hCopy(indx).Handles.line = [];
    unrender(hCopy(indx)); % Make sure the object is not rendered.
end

hPZ = get(hObj, 'Roots');
hPZ = union(hPZ, hCopy);
set(hObj, 'Roots', hPZ);

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

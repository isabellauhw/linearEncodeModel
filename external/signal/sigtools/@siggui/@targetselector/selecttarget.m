function selecttarget(hTS)
%SELECTTARGET Select the target from a dialog

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

try
    [bdnum,prnum] = boardprocsel;
    set(hTS, 'BoardNumber', sprintf('%d', bdnum));
    set(hTS, 'ProcessorNumber', sprintf('%d', prnum));
catch
    error(message('signal:siggui:targetselector:selecttarget:CannotRunBoardSelection'));
end

% [EOF]

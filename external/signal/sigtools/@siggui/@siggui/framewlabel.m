function framewlabel(this, pos, lbl)
%FRAMEWLABEL   Create a framewlabel.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,3);

if nargin < 3
    lbl = get(classhandle(this), 'Description');
    lbl = getTranslatedString('signal:sigtools:siggui',lbl);
end

h = get(this, 'Handles');

hnew = framewlabel(this.FigureHandle, pos, lbl, ...
    [strrep(class(this), '.', '_'), '_framewlabel'], ...
    get(0, 'DefaultUicontrolBackgroundColor'), 'Off');

if isfield(h, 'framewlabel')
    h.framewlabel = [h.framewlabel hnew];
else
    h.framewlabel = hnew;
end

[cshtags, cshtool] = getcshtags(this);
if isfield(cshtags, 'framewlabel')
    cshelpcontextmenu(hnew, cshtags.framewlabel, cshtool);
end

set(this, 'Handles', h);

% [EOF]

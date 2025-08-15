function thisrender(this, varargin)
%THISRENDER Render the FIR Options window frame for FDATool.

%   Author(s): V.Pellissier & Z. Mecklai
%   Copyright 1988-2017 The MathWorks, Inc.

pos = parserenderinputs(this, varargin{:});
if nargin < 2
    hFig = gcf;
end

if isempty(pos)
    % Get the gui sizes
    sz = gui_sizes(this);
    pos = sz.pixf.*[217, 55, 178, 133-(sz.vffs/sz.pixf)];
end

framewlabel(this, pos, getString(message('signal:sigtools:siggui:Options')));
renderactionbtn(this, pos-[0 2*sz.pixf 0 0], getString(message('signal:sigtools:siggui:View')), 'view');

%reduce the buttom height
H = get(this,'Handles');
P = get(H.view, 'Position');
set(H.view, 'Position', P);

rendercontrols(this, pos + [0 sz.uh+2*sz.pixf 0 -sz.uh], ...
    {'Scale', 'Window', 'Parameter', 'Parameter2'});

% Reposition Window Label - avoid overlap
H = get(this,'Handles');
posWinLbl = get(H.window_lbl,'Position');
winWidth = largestuiwidth({getTranslatedString('signal:siggui:renderedlabel','Window')});
posWinLbl(3) = winWidth + sz.lfs;
set(H.window_lbl,'Position',posWinLbl);

%Set pop-up menu position explicitly
posWinPop = get(H.window,'Position');
startPos = posWinLbl(1)+posWinLbl(3);
set(H.window,'Position',[startPos+0.5*sz.popwTweak, posWinPop(2), pos(1)+pos(3)-startPos-sz.popwTweak, posWinPop(4)])

% Add context-sensitive help
cshelpcontextmenu(this, 'fdatool_firwin_options_frame');

l = [ this.WhenRenderedListeners; ...
    handle.listener(this, this.findprop('privWindow'), ...
    'PropertyPostSet', @(h, ev) updateparameter(this)); ...
    handle.listener(this, this.findprop('isMinOrder'), ...
    'PropertyPostSet', @(h, ev) updateparameter(this)); ...
    ];

set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

% [EOF]

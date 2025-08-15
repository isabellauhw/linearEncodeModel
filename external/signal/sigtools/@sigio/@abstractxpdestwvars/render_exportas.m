function render_exportas(this,pos)
%RENDER_EXPORTAS Render a frame with an "Export As" popup.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

if nargin < 2 , pos =[]; end

hFig = get(this,'FigureHandle');
bgc  = get(0,'DefaultUicontrolBackgroundColor');
cbs  = callbacks(this);
sz   = xp_gui_sizes(this);

% Render the "Export As" frame
if isempty(pos)
    % Default Position
    pos = sz.XpAsFrpos;
else
    % Adjust position (pos is for entire destination options frames)
    ypos = (pos(2)+pos(4))-sz.XpAsFrpos(4);
    pos = [pos(1) ypos pos(3) sz.XpAsFrpos(4)];
end

h    = get(this,'Handles');
if ishandlefield(this, 'xpasfr')
    framewlabel(h.xpasfr, pos);
else
    h.xpasfr = framewlabel(hFig, pos, getString(message('signal:sigtools:sigio:ExportAs')), 'exportas', bgc, this.Visible);
end

% Render the "Export As" popupmenu
popupwidth = pos(3)-sz.hfus*2;
XpAsPoppos = [pos(1)+sz.hfus pos(2)+sz.vfus*2 popupwidth sz.uh];

% Untranslated strings
strs = set(this, 'ExportAs'); 
% Exclude 'System objects' option. It will be added later by the FDATool code
sysObjIdx = strcmpi(strs,'System Objects');
strs(sysObjIdx) = [];
% Translated strings
strsT = getTranslatedStringcell('signal:sigtools:sigtools', strs); 

if ishandlefield(this, 'exportas')
    setpixelpos(this, h.exportas, XpAsPoppos);
else
    h.exportas = uicontrol(hFig, ...
        'Style', 'Popup', ...
        'Position', XpAsPoppos, ...
        'Callback', {cbs.exportas, this}, ...
        'Tag', 'exportas_popup', ...
        'Visible', this.Visible, ...
        'HorizontalAlignment', 'Left', ...
        'String', strsT);
    setenableprop(h.exportas, this.Enable);
end
% Save untranslated strings in the app data for use in the callback  
setappdata(h.exportas, 'PopupStrings', strs);

set(this, 'Handles', h);

l = handle.listener(this, this.findprop('ExportAs'), 'PropertyPostSet', @prop_listener);
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

prop_listener(this);

% [EOF]

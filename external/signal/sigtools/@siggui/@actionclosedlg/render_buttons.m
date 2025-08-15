function render_buttons(this)
%RENDER_BUTTONS   

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

hFig = get(this,'FigureHandle');
sz   = dialog_gui_sizes(this);

fsz  = figuresize(this);
bgc  = get(0,'DefaultUicontrolBackgroundColor');

enabState = get(this, 'Enable');

ctrlStrs = {sprintf(getactionlabel(this)),getString(message('signal:sigtools:siggui:Close'))};
if hashelp(this)
    ctrlStrs{end+1} = getString(message('signal:sigtools:siggui:Help'));
end
numbtns = length(ctrlStrs);
uiWidth = largestuiwidth(ctrlStrs,'Pushbutton')+10*sz.pixf;

spacing = sz.uuhs*2;

helpx   = fsz(1)-10*sz.pixf-uiWidth;
if hashelp(this)
    closex = helpx -10*sz.pixf-uiWidth;
else
    closex = helpx;
end
actionx = closex-10*sz.pixf-uiWidth;

buttonPos = sz.button;

buttonPos([1,3]) = [actionx uiWidth];

% NOTE: The converttdlg_cbs function updates the figure's userdata
cbs = helpdialog_cbs(this);

% Render the "OK" pushbutton 
h.action = uicontrol(hFig,...
    'Style','Push',...
    'BackgroundColor',bgc,...
    'Position',buttonPos,...
    'Visible','On',...
    'Enable',enabState, ...
    'String',ctrlStrs{1}, ...
    'Tag','dialog_ok', ...
    'Callback',cbs.apply);

buttonPos(1) = closex;

% Render the "Cancel" pushbutton 
h.close = uicontrol(hFig,...
    'Style','Push',...
    'BackgroundColor',bgc,...
    'Position',buttonPos,...
    'Visible','On',...
    'Enable',enabState,...
    'String',ctrlStrs{2},...
    'Tag','dialog_cancel',...
    'Callback',cbs.cancel);

if hashelp(this)

    buttonPos(1) = helpx;

    % Render the "Apply" pushbutton
    h.help = uicontrol(hFig,...
        'Style','Push',...
        'BackgroundColor',bgc,...
        'Position',buttonPos,...
        'Visible','On',...
        'Enable',enabState,...
        'String',ctrlStrs{3},...
        'Tag','dialog_apply',...
        'Callback',cbs.help);
end

h.warn = [];

set(this,'DialogHandles',h);

% [EOF]

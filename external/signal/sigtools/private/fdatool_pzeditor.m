function h = fdatool_pzeditor(hSB)
%FDATOOL_PZEDITOR Install the pole/zero editor in FDATool.

%   Copyright 1988-2017 The MathWorks, Inc.

hFDA = getfdasessionhandle(hSB.FigureHandle);
sz = fdatool_gui_sizes(hFDA);

status(hFDA, getString(message('signal:sigtools:private:LoadingPoleZeroEditor')));

h = siggui.pzeditor(getfilter(hFDA));

status(hFDA, [getString(message('signal:sigtools:private:LoadingPoleZeroEditor')) ' ...']);

% Disable zooms when going to the PZ Editor.
hFig = hSB.FigureHandle;
z = zoom(hFig);
zoomEnab = z.Enable;

z.Enable = 'off';

if iscalledbydspblks(hSB)
  offset = 16*sz.pixf;
  factor = 2.5;
else
  offset = 0;
  factor = 1;
end

render(h, hSB.FigureHandle, sz.panel-[-sz.ffs -sz.ffs-offset 2*sz.ffs 2*factor*sz.ffs]);

z.Enable = zoomEnab;

status(hFDA, [getString(message('signal:sigtools:private:LoadingPoleZeroEditor'))...
              '... ' getString(message('signal:sigtools:private:Done'))]);

attachlisteners(hFDA, h);

% --------------------------------------------------------------
function attachlisteners(hFDA, h)

l = [ ...
    handle.listener(hFDA, 'FilterUpdated', {@lclfilterupdated_listener, hFDA}); ...
    handle.listener(h, 'NewFilter', {@lclnewfilter_listener, hFDA}); ...
    handle.listener(h, 'ButtonUp', {@lclbuttonup_listener, hFDA}); ...
    handle.listener(h, h.findprop('Visible'), 'PropertyPreSet', ...
    {@lclvisible_listener, hFDA});
    ];

set(l, 'CallbackTarget', h);
setappdata(hFDA, 'PZEditor', l);

% --------------------------------------------------------------
function lclbuttonup_listener(h, eventData, hFDA) %#ok<*INUSL>

l = getappdata(hFDA, 'PZEditor');
set(l, 'Enabled', 'Off');

opts.source = 'Pole/Zero Editor';

setfilter(hFDA, get(h, 'Filter'), opts);

set(l, 'Enabled', 'On');

% --------------------------------------------------------------
function lclvisible_listener(h, eventData, hFDA)

% Make sure that before we turn the panel visible that the filters are
% synced.
if strcmpi(get(eventData, 'NewValue'), 'on')
    if getappdata(hFDA, 'pzeditor_crumb')
        syncfilter(h, hFDA);
    end
end

% --------------------------------------------------------------
function lclfilterupdated_listener(h, eventData, hFDA)

% Disable and enable the listeners so that we won't get a double update
% from the pzeditor sending out a new filter (which is the same as the old
% filter).

% Don't do anything if the panel is invisible.  Too expensive.
if strcmpi(h.Visible, 'On')
    syncfilter(h, hFDA);
else
    setappdata(hFDA, 'pzeditor_crumb', true);
end

% --------------------------------------------------------------
function lclnewfilter_listener(h, eventData, hFDA)

l = getappdata(hFDA, 'PZEditor');
set(l, 'Enabled', 'Off');

opts.source = 'Pole/Zero Editor';
if ~strcmpi(h.ButtonState, 'up')
    opts.fastupdate = true;
end

hFDA.McodeType = 'pzeditor';

setfilter(hFDA, get(h, 'Filter'), opts);

set(l, 'Enabled', 'On');

% --------------------------------------------------------------
function syncfilter(h, hFDA)

l = getappdata(hFDA, 'PZEditor');
set(l, 'Enabled', 'Off');

filtobj = getfilter(hFDA);

set(h, 'Filter', filtobj);

set(l, 'Enabled', 'On');
setappdata(hFDA, 'pzeditor_crumb', false);

% [EOF]

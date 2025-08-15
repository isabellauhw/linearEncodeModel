function h = fdatool_mfilttool(hSB)
%FDATOOL_MFILTTOOL   

%   Copyright 1988-2017 The MathWorks, Inc.

hFig = get(hSB, 'FigureHandle');
hFDA = getfdasessionhandle(hFig);

status(hFDA, getString(message('signal:sigtools:private:LoadingMultirateFilterpanel')));

h   = fdtbxgui.mfiltdesignpanel;
sz   = fdatool_gui_sizes(hFDA);

status(hFDA, [getString(message('signal:sigtools:private:LoadingMultirateFilterpanel')) ' ...']);

set(h, 'CurrentFilter', getfilter(hFDA));

render(h, hFig, sz.defaultpanel);
resizefcn(h, [sz.fig_w sz.fig_h]*sz.pixf);

l = [ ...
        handle.listener(h, 'FilterDesigned', @filterdesigned_listener); ...
        handle.listener(hFDA, 'FilterUpdated', {@filterupdated_listener, h}); ...
    ];
set(l, 'CallbackTarget', hFDA);
setappdata(hFDA, 'mfiltpanellisteners', l);

status(hFDA, [getString(message('signal:sigtools:private:LoadingMultirateFilterpanel')) ...
       ' ... ' getString(message('signal:sigtools:private:Done'))]);

% -------------------------------------------------------------------------
function filterdesigned_listener(hFDA, eventData)

h = get(eventData, 'Source');

data = get(eventData, 'Data');

opts.mcode      = data.mcode;
opts.source     = 'Multirate Design';
opts.name       = get(data.filter, 'FilterStructure');

% If the current implemntation is to use the current filter then we do not
% want to reset the mcode.  Just continue writing it.
if ~strcmpi(h.Implementation, 'current')
    opts.resetmcode = true;
end

if strcmpi(h.frequencyUnits, 'normalized (0 to 1)')
    opts.fs = [];
else
    opts.fs = convertfrequnits(evaluatevars(h.Fs), h.FrequencyUnits, 'hz');
end

hFDA.McodeType = 'multirate';

setfilter(hFDA, data.filter, opts);


% -----------------------------------------------------------------------
function filterupdated_listener(hFDA, eventData, h) %#ok<*INUSL>

fmb = get(hFDA, 'filtermadeby');
if ~strncmpi(fmb, 'multirate design', 16)
    set(h, 'IsDesigned', false);
end
set(h, 'CurrentFilter', getfilter(hFDA));

% [EOF]

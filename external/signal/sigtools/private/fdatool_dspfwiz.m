function hF = fdatool_dspfwiz(hSB)
%FDATOOL_DSPFWIZ   FDATool to DSPFWIZ link.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hFig = get(hSB, 'FigureHandle');
hFDA = getfdasessionhandle(hFig);

status(hFDA, getString(message('signal:sigtools:private:LoadingFilterRealization')));

hF   = siggui.dspfwiz(getfilter(hFDA));
sz   = fdatool_gui_sizes(hFDA);

status(hFDA, [getString(message('signal:sigtools:private:LoadingFilterRealization')) ' ...']);

render(hF, hFig, sz.defaultpanel-[-5 -5 10 10]*sz.pixf);
resizefcn(hF, [sz.fig_w sz.fig_h] * sz.pixf);

addlistener(hFDA, 'FilterUpdated', {@filter_listener, hF});
l = handle.listener(hF, hF.findprop('Filter'), 'PropertyPostSet', ...
    {@fwiz_filter_listener, hF});
set(l, 'CallbackTarget', hFDA);
sigsetappdata(hFDA, 'plugins', 'dspfwiz', 'listeners', l);

status(hFDA, [getString(message('signal:sigtools:private:LoadingFilterRealization')) ...
              ' ... ' getString(message('signal:sigtools:private:Done'))]);

% --------------------------------------------------------------------
function filter_listener(hFDA, eventData, hF)

% Sync the filter wizard with FDATool.
hF.Filter = getfilter(hFDA);

% --------------------------------------------------------------------
function fwiz_filter_listener(hFDA, eventData, hF)

% If the filterwizard filter changed underneath FDATool, we need to reverse
% sync it.  This can happen when loading an old dspfwiz session.
dspfilt = get(hF, 'Filter');
fdafilt = getfilter(hFDA);
opts.update = 0;

if ~isequal(dspfilt, fdafilt)
    hFDA.setfilter(dspfilt, opts);
end

% [EOF]

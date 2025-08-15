function hQP = fdatool_qfiltpanel(hSB)
%FDATOOL_QFILTPANEL initializes the QFILTPANEL for FDATOOL.
%   hQP = FDATOOL_QFILTPANEL(hSB) returns a FDTBXGUI.QFILTPANEL object hQP,
%   given SIGGUI.SIDEBAR object hSB.

%   Copyright 1999-2017 The MathWorks, Inc.

% Turn warning off so quantizing doesn't throw warnings
wrn = warning('off'); %#ok<WNOFF>
if isa(hSB, 'sigtools.fdatool')
    hFDA = hSB;
    hFig = get(hFDA, 'FigureHandle');
else
    hFig = get(hSB, 'FigureHandle');
    hFDA = getfdasessionhandle(hFig);
end

% The first time this is called, we haven't established a default filter yet,
% so we use the default here.
if sigisappdata(hFDA, 'qpanel', 'handle')
    hQP = siggetappdata(hFDA, 'qpanel', 'handle');
else

    status(hFDA, getString(message('signal:sigtools:private:LoadingPanel')));
    Hd = lclcopy(getfilter(hFDA));
    
    status(hFDA, [getString(message('signal:sigtools:private:LoadingPanel')) ' ...']);
    hQP = fdtbxgui.qtool(Hd);
    set(hQP, 'DSPMode', getflags(hFDA, 'calledby', 'dspblks'));
    sigsetappdata(hFDA, 'qpanel', 'handle', hQP);

    sz = fdatool_gui_sizes(hFDA);

    render(hQP, hFig, sz.defaultpanel);
    resizefcn(hQP, [sz.fig_w, sz.fig_h]*sz.pixf);
    
    th = get(hQP,'TabHandles');
    th.tablabels(1).Position(2) = -0.1;
    th.tablabels(2).Position(2) = -0.1;
    th.tablabels(3).Position(2) = -0.1;
    for i = 1:length(th.tabbuttons)
      th.tabbuttons(i).Position = th.tabbuttons(i).Position + [0 0 0 0.01];      
    end
    
    attachlisteners(hFDA, hQP);
    
    % Fire the NewSettings event so that the arithmetic is updated if a
    % non-double precision filter was loaded to the GUI. Make sure the GUI
    % does not become dirty by sending a flag in the event data.
    d.MakeDirtyFlag = false;
    send(hQP, 'NewSettings',sigdatatypes.sigeventdata(hQP, 'NewSettings', d))
                
    status(hFDA, [getString(message('signal:sigtools:private:LoadingPanel')) ' ... done']);
end

% Restore warning state.
warning(wrn)

% ------------------------------------------------------------
function attachlisteners(hFDA, hQP)
% Events that update the filter.

listeners = [ ...
    handle.listener(hFDA, hFDA.findprop('Filter'), ...
    'PropertyPostSet', @filter_eventcb); ...
    handle.listener(hQP, 'NewSettings', @newsettings_listener); ...
    ];

set(listeners, 'CallbackTarget', [hQP, hFDA]);

sigsetappdata(hFDA, 'qpanel', 'listeners', listeners);


% ------------------------------------------------------------
function filter_eventcb(callbacktarget, eventData) %#ok<*INUSD>
% Filter in FDATOOL has been changed.  Now reflect that change in the qpanel. 

hQP = callbacktarget(1);
hFDA = callbacktarget(2);

Hd = getfilter(hFDA);
if ~isempty(strfind(hFDA.filtermadeby, 'converted')) && ...
        ~isa(Hd, 'mfilt.abstractcic') && ...
        ~isa(hQP.Filter, 'mfilt.abstractcic')
    l = siggetappdata(hFDA, 'qpanel', 'listeners');
    set(l, 'Enabled', 'Off');
    set(hQP, 'Arithmetic', 'double');
    set(l, 'Enabled', 'On');
end
if Hd ~= hQP.Filter
    Hd = lclcopy(Hd);
    hQP.Filter = Hd;
    HdwFs = getfilter(hFDA, 'wfs');
    HdwFs.Filter = hQP.Filter;
end

% ------------------------------------------------------------
function newsettings_listener(callbacktarget, eventData)

updateMCode = true;
if ~isempty(eventData)
  ed = get(eventData);
  opts.filedirty = ed.Data.MakeDirtyFlag;
  updateMCode = ed.Data.MakeDirtyFlag;
end

hQP  = callbacktarget(1);
hFDA = callbacktarget(2);

quantStr = ' (quantized)';

if isquantized(hQP.Filter)    
    opts.source = [strrep(hFDA.filterMadeBy, quantStr, '') quantStr];
else
    opts.source = strrep(hFDA.filterMadeBy, quantStr, '');
end

opts.source = strrep(opts.source, ' (converted)', ''); % Make sure that converted is gone.
if updateMCode
  opts.mcode  = genmcode(hQP);
else
  opts.mcode = hFDA.MCode;
end

l = siggetappdata(hFDA, 'qpanel','listeners');

set(l, 'Enabled','Off');

hFDA.McodeType = 'quantize';

setfilter(hFDA, lclcopy(hQP.Filter), opts);

set(l, 'Enabled','On');

% ------------------------------------------------------------
function fmb = rmquantized(hFDA) %#ok<DEFNU>

fmb = get(hFDA, 'FilterMadeBy');
indx = strfind(lower(fmb), ' (quantized)');
if ~isempty(indx)
    fmb(indx:indx+11) = [];
end

% ------------------------------------------------------------
function Hd = lclcopy(Hd)

mi = [];
if isprop(Hd, 'MaskInfo')
    mi = get(Hd, 'MaskInfo');
end
Hd = copy(Hd);
if ~(isempty(mi) || isprop(Hd, 'MaskInfo')) 
    p = adddynprop(Hd, 'MaskInfo', 'mxArray');
    set(p, 'Visible', 'Off');
    set(Hd, 'MaskInfo', mi);
end

% [EOF]

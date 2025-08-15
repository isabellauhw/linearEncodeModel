function h = fdatool_design(hSB)
%FDATOOL_DESIGN Install the design panel in fdatool

%   Copyright 1988-2017 The MathWorks, Inc.

hFDA = getfdasessionhandle(hSB.FigureHandle);
sz   = fdatool_gui_sizes(hFDA);

allowplugins = getappdata(hFDA.FigureHandle, 'allowplugins');
if isempty(allowplugins)
    allowplugins = true;
end

h = siggui.designpanel(allowplugins);
render(h,hSB.FigureHandle, sz.panel);

set(h, 'IsDesigned', 1);
set(h, 'StaticResponse', 'On');
install_listeners(h);

% -----------------------------------------------------------------------
function install_listeners(h)

hFDA = getfdasessionhandle(h.FigureHandle);

addlistener(hFDA, 'FilterUpdated', {@filterupdated_eventcb, hFDA}, h);
addlistener(hFDA, 'FullViewAnalysis', @fullviewanalysis_eventcb, h); 
addlistener(hFDA, 'Print', @print_eventcb, h); 
addlistener(hFDA, 'PrintPreview', @printpreview_eventcb, h); 

l = handle.listener(h, 'FilterDesigned', {@filterdesigned_eventcb, h});

set(l, 'CallbackTarget', hFDA);

setappdata(hFDA, 'designPanelListeners', l);


% -----------------------------------------------------------------------
%       Event Callbacks
% -----------------------------------------------------------------------

% -----------------------------------------------------------------------
function filterdesigned_eventcb(hFDA, eventData, h)

data = get(eventData, 'Data');

if isempty(data.filter)
  send(hFDA,'FilterUpdated',handle.EventData(hFDA,'FilterUpdated'));
else
  opts.fcnhndl  = @setdesignedflag;
  opts.source   = 'Designed';
  
  opts.fs = get(h, 'CurrentFs');
  opts.mcode = data.mcode;
  opts.resetmcode = true;
  
  hFDA.McodeType = 'design';
  
  hFDA.setfilter(data.filter, opts);
end

% -----------------------------------------------------------------------
function print_eventcb(h, eventData) %#ok<INUSD>

if strcmpi(h.StaticResponse, 'On') && strcmpi(h.Visible, 'On')
    hfig = copyStaticResponse(h);
    
    setptr(hfig,'watch');   % Set mouse cursor to watch.
    printdlg(hfig);
    setptr(hfig,'arrow');   % Reset mouse pointer.
    close(hfig)
end

% -----------------------------------------------------------------------
function printpreview_eventcb(h, eventData) %#ok<INUSD>

if strcmpi(h.StaticResponse, 'On') && strcmpi(h.Visible, 'On')
    hfig = copyStaticResponse(h);
    
    printpreview(hfig)  
    
    if ishandle(hfig)
        delete(hfig)
    end
end

% -----------------------------------------------------------------------
function fullviewanalysis_eventcb(h, eventData) %#ok<INUSD>

if strcmpi(h.StaticResponse, 'On') && strcmpi(h.Visible, 'On')
    hfig = copyStaticResponse(h);
    set(hfig, 'Name', 'Full View Analysis', 'Visible', 'On');
end

% -----------------------------------------------------------------------
function filterupdated_eventcb(h, eventData, hFDA) %#ok<INUSL>

% If the new filter is not designed then set the isdesigned flag
fmb = get(hFDA, 'filtermadeby');
if ~strncmpi(fmb, 'designed', 8)
    set(h, 'IsDesigned', 0);
end

% -----------------------------------------------------------------------
function hfig = copyStaticResponse(h)

hax = findobj(h.FigureHandle, ...
    'Type', 'Axes', ...
    'Tag', 'staticresponse_axes');
hfig = createfigcopy(hax);

% [EOF]

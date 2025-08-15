function thisrender(this, hFig, varargin)
%RENDER Renders the Sidebar
%   RENDER Renders the sidebar object associated with this.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.
%   $Revision: 1.9.4.19 $  $Date: 2013/09/24 23:51:29 $

narginchk(2,3);

if ishghandle(hFig)
    render_sidebar(this, hFig);
else
    feval(hFig, this, varargin{:});
end


%----------------------------------------------------------
function render_sidebar(this, hFig)

sz      = sidebar_gui_sizes(this);
set(this, 'FigureHandle', hFig);

framePos = sz.frame;
framePos(3) = framePos(3)+3;


% Render the frame
h.frame = uipanel('Parent', hFig, ...
    'Units', 'Pixels', ...
    'Position', framePos, ...
    'Visible', 'Off', ...
    'BorderWidth',1);

set(h.frame,'Units','Normalized');

set(this,'Handles',h);

% Install the panel_listener
% We do a PreSet listener so that we still have access to the old value
% This enables us to hide the old panel and show the new panel in the same listener
Listeners = handle.listener(this, this.findprop('CurrentPanel'),...
    'PropertyPreSet', @panel_listener);
set(Listeners,'CallbackTarget',this);

set(this,'WhenRenderedListeners',Listeners);

%----------------------------------------------------------
function renderselectionbutton(this, opts) %#ok<DEFNU>
%RENDERSELECTIONBUTTON Render the selection button
%   RENDERSELECTIONBUTTON(this, OPTS) Renders the selection button to the
%   sidebar associated with this with the information contained within OPTS.

h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');

if isfield(opts,'tooltip')
    tooltip = opts.tooltip;
else
    tooltip = '';
end
if isfield(opts,'icon')
    icon = opts.icon;
else
    icon = [];
end

pos = nextPos(this);

% Get the index to the new button
if isfield(h, 'button')
    index = numel(h.button)+1;
else
    index = 1;
end

pos(2) = pos(2) + 4;
pos(1) = pos(1) + 4;

h.button(index) = uicontrol(h.frame,...
    'Style','togglebutton',...
    'Position',pos,...
    'Visible', 'Off', ...
    'Interruptible', 'Off', ...
    'BusyAction', 'Queue', ...
    'Callback',{@selector_cb,this,index},...
    'TooltipString',tooltip,...
    'CData',icon,...
    'Tag','sidebar_button',...
    'HorizontalAlignment','right');

set(h.button(index),'Units','Normalized');

if isfield(opts, 'csh_tag')
    fdaddcontextmenu(hFig, h.button(index), opts.csh_tag);
end
% end
set(this,'Handles',h);

% --------------------------------------------------------
function pos = nextPos(this)

sz = sidebar_gui_sizes(this);

h = get(this, 'Handles');
pos = sz.button;
if isfield(h, 'button')
    nButtons = numel(h.button);
else
    nButtons = 0;
end
pos(2) = pos(2)+pos(4)*(nButtons-1);
pos    = pos - [1 1 -1 1];

% --------------------------------------------------------
function sz = sidebar_gui_sizes(this)

sz = this.gui_sizes;

fx = 0*sz.pixf;
fy = 28*sz.pixf;
fw = 30*sz.pixf;
fh = 507*sz.pixf;

sz.frame  = [fx fy fw fh];
sz.button = [fx fy fw fw];

% --------------------------------------------------------
function selector_cb(~, ~, this, index)

hFig = get(this, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

% If the currently selected panel is not constructed, construct it
if isempty(getpanelhandle(this, index))
    constructAndSavePanel(this, index);
end

set(this, 'currentpanel', index);

set(hFig, p{:});

sendstatus(this, getString(message('signal:sigtools:siggui:Ready')));

% [EOF]

function thisrender(this, varargin)
%THISRENDER  Renders the magtext frame.

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

% If hFig is not specified, create a new figure
pos = parserenderinputs(this, varargin{:});
if isempty(pos), pos = 'mag'; end

% call the super class's render method
super_render(this, pos);

% Get the handles to the objects created
h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');
sz   = gui_sizes(this);

pos = getpixelpos(this, 'framewlabel', 1);

pos = [pos(1)+sz.hfus pos(2)+sz.vfus pos(3)-2*sz.hfus pos(4)-2*sz.vfus-sz.pixf*40];

h.text = uicontrol('Style', 'text',...
    'Parent', hFig, ...
    'Visible','off',...
    'Units', 'pixels',...
    'Position', pos,...
    'HorizontalAlignment', 'left',...
    'String', get(this, 'Text'));

set(this, 'Handles', h);

% Install listener
wrl(1) = handle.listener(this, this.findprop('text'),...
    'PropertyPostSet', @text_listener);

set(wrl,'CallbackTarget',this);

% Store the listeners in the WhenRenderedListeners property of the superclass
this.WhenRenderedListeners = wrl;

% Set the units to norm
setunits(this, 'Normalized');

% -------------------------------------------------------------------------
function text_listener(this, eventData)

set(this.Handles.text, 'String', this.Text);

% [EOF]

function thisrender(this, varargin)
%THISRENDER  Renders the text frame with the default values.
%   THISRENDER(H, HFIG, POS)
%   H       -   Handle to object
%   HFIG    -   Handle to parent figure
%   POS     -   Position of frame
%   Since the textOptionsFrame may be a superclass, it's render method
%   must be callable from subclasses hence all the code necessary to
%   actually render the frame is moved to another method

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

% Render the container frame and return values needed for every render method
renderabstractframe(this, varargin{:});

h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');
sz   = gui_sizes(this);

framePos = get(h.framewlabel(1), 'Position');

% Calculate the position of the text.
pos(1) = framePos(1) + sz.hfus;
pos(2) = framePos(2) + sz.vfus;
pos(3) = framePos(1) + framePos(3) - pos(1) - sz.hfus;
pos(4) = framePos(2) + framePos(4) - 2*sz.vfus - pos(2);

h.text = uicontrol('Style','Text',...
    'HorizontalAlignment','left',...
    'String',get(this,'Text'),...
    'BackgroundColor',get(0,'DefaultUicontrolBackgroundColor'),...
    'Enable','on',...
    'Visible','off',...
    'Units','pixels',...
    'Position',pos,...
    'Parent',hFig);

% Install text listener
listener(1) = handle.listener(this, this.findprop('Text'),...
    'PropertyPostSet',@text_listener);

% Set the callback target
set(listener,'CallbackTarget',this);

% Store the listener
set(this, 'WhenRenderedListeners',listener);
set(this, 'Handles', h);

% [EOF]

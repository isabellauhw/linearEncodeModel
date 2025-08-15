function thisrender(this, varargin)
%THISRENDER Render the frequency specifications GUI component.
% Render the frame and uicontrols

%   Author(s): R. Losada, Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

pos = parserenderinputs(this, varargin{:});
if isempty(pos), pos = 'freq'; end

% Call the super classes render method
super_render(this, pos);

sz   = gui_sizes(this);
pos  = getpixelpos(this, 'framewlabel', 1);
fsh  = getcomponent(this, 'siggui.specsfsspecifier');
hFig = get(this, 'FigureHandle');
h    = get(this, 'Handles');

% Render the FSSpecifier
render(fsh, hFig, pos);

lblpos = getpixelpos(fsh, 'value_lbl');

% Render the text box

h.text = uicontrol(hFig, ...
    'Style','text',...
    'Position',[lblpos(1) pos(2)+sz.vfus pos(1)+pos(3)-lblpos(1)-17*sz.pixf ...
        lblpos(2)-pos(2)-sz.vfus-sz.uuvs],...
    'Visible','off',...
    'HorizontalAlignment', 'left',...
    'String', get(this, 'Text'));
    
set(this,'Handles',h);

wrl = [ ... 
        handle.listener(fsh, 'UserModifiedSpecs',@(fsh, ev) event_listener(this));
        handle.listener(this, this.findprop('Text'),...
        'PropertyPostSet', @(hSrc, ev) text_listener(this)); ...
    ];

% Store the listener in the listener property
set(this, 'WhenRenderedlisteners', wrl);

% -------------------------------------------------------------------------
function text_listener(this)

set(this.Handles.text, 'String', this.Text);

% [EOF]

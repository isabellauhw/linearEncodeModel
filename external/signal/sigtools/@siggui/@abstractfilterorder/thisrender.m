function thisrender(this, varargin)
%RENDER Render the entire filter order GUI component.
% Render the frame and uicontrols

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

frpos = parserenderinputs(this, varargin{:});
bgc   = get(0,'DefaultUicontrolBackgroundColor');
hFig  = get(this,'FigureHandle');
sz    = gui_sizes(this);

% Calculate this frame's position and then render the frame.
if isempty(frpos)
    frpos = sz.pixf.*[217 186 178 74];
end

h.framewlabel = framewlabel(hFig,frpos,getString(message('signal:sigtools:siggui:FilterOrder')), ...
                            'filterOrderFrame',bgc,'off');

%
% Render the radio buttons and popup.
%

% Define the strings
orderStrs = {getString(message('signal:sigtools:siggui:Specifyorder')), ...
             getString(message('signal:sigtools:siggui:MinimumOrder'))};
tags = set(this,'Mode');%{'specify','minimum'}

% Get structure of callback handles
cbs = {{@specifyOrder_cb,this},{@minimumOrder_cb,this}};

h.rbs = [-1 -1]; % Preallocate for speed.

pos = [frpos(1)+sz.hfus, frpos(2)+frpos(4),...
    largestuiwidth(orderStrs,'radiobutton') sz.uh];

% Put up the radio buttons
for n=1:length(orderStrs)
    
    pos(2) = pos(2)-(sz.uh+2*sz.vfus+sz.lblTweak);
    h.rbs(n)=uicontrol(hFig,'Style','radiobutton',...
        'BackgroundColor',bgc,...
        'Position',pos,...
        'Visible','off',...
        'String',orderStrs{n},...
        'Tag',tags{n},...
        'Callback',cbs{n});
end

if length(tags) > 2
    set(h.rbs(2), 'String', '');
    pos(1) = pos(1) + 20*sz.pixf;
    lbls = cell(1,length(tags)-1);
    for indx = 1:length(tags)-1
      switch tags{indx+1}
        case 'minimum'
          msgID = 'MinimumOrder';
        case 'minimum even'
          msgID = 'MinimumOrderEven';
        case 'minimum odd'
          msgID = 'MinimumOrderOdd';
      end
      lbls{indx} = getString(message(['signal:sigtools:siggui:' msgID]));
    end
    pos(3) = largestuiwidth(lbls)+sz.rbwTweak;
    
    if pos(3)+pos(1) > frpos(1)+frpos(3)+sz.hfus
        pos(3) = frpos(1)+frpos(3)-pos(1)-sz.hfus;
    end
    
    pos(2) = pos(2) + sz.lblTweak;
    
    h.pop = uicontrol(hFig, 'Style', 'Popup', ...
        'BackgroundColor', 'w', ...
        'Position', pos, ...
        'Visible', 'off', ...
        'Tag', 'minimum', ...
        'String', lbls, ...
        'Callback', cbs{2}, ...
        'HorizontalAlignment', 'Left', ...
        'UserData', tags(2:end));
else
    h.pop = [];
end

%
% Render the edit box
%

% Find the position of specify order
specorder_pos = get(h.rbs(1),'Position');

h.eb = uicontrol(hFig,'Style','edit',...
    'BackgroundColor','white',...
    'Position',[specorder_pos(1)+specorder_pos(3) specorder_pos(2) 40*sz.pixf sz.uh],...
    'Visible','off',...
    'HorizontalAlignment','left',...
    'Tag','order_eb',...
    'Callback',{@order_eb_cb,this},...
    'String',get(this, 'order'));

% Store handles in object
set(this,'Handles',h);

% Install listener for the mode
% Install a listener for the isMinOrd property
% Install a listener for the order property
listeners = [ ...
    handle.listener(this, this.findprop('mode'),'PropertyPostSet', @mode_listener); ...
    handle.listener(this, this.findprop('isMinOrd'), 'PropertyPostSet', @is_minord_listener); ...
    handle.listener(this, this.findprop('order'), 'PropertyPostSet', @order_listener); ...
    ];

set(listeners,...
    'CallbackTarget',this);

% Store the listeners in the WhenRenderedListeners
this.WhenRenderedListeners = listeners;

mode_listener(this);
is_minord_listener(this);

cshelpcontextmenu(this, 'fdatool_filter_order_specs_frame');

%-----------------------------------------------------------------
function minimumOrder_cb(h_source, ~, this, varargin)
%MINIMUMORDER_CB Callback for the minimum order radio button.

% Because HG deselects radio-buttons when they are clicked on and
% already selected, we need to ensure that it stays selected.

if strcmpi(get(h_source, 'Style'), 'popupmenu')
    indx = get(h_source, 'Value') + 1;
else
    indx = 2;
end

lcl_setmode(h_source,this,indx);

%-----------------------------------------------------------------
function order_eb_cb(h_source, ~, this, varargin)
%ORDER_EB_CB Callback for the specify order edit box.

% Get value in edit box
val = fixup_uiedit(h_source);

% Set the mode to specify
set(this,'Order',val{1});
% Notify any listeners that this event occurred
send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));

%------------------------------------------------------------------
function specifyOrder_cb(h_source, ~, this, varargin)
%SPECIFYORDER_CB Callback for the specify order radio button.

lcl_setmode(h_source,this,1);

%------------------------------------------------------------------
function lcl_setmode(h_source,this,indx)
% Because HG deselects radio-buttons when they are clicked on and
% already selected, we need to ensure that it stays selected.

modeOpts = set(this,'Mode'); %{'specify','minimum'} <- from the subclass
if strcmpi(get(this,'Mode'),modeOpts{indx})
    if ~strcmpi(get(h_source, 'Style'), 'popupmenu')
        set(h_source,'Value',1);
    end
else
    % Set the mode to the specified value
    set(this,'Mode',modeOpts{indx});
    
    % Notify any listeners that this event occurred
    send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));
end

% [EOF]

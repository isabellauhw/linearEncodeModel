function thisrender(this, varargin)
%THISRENDER Render the Pole/Zero editor

%   Copyright 1988-2017 The MathWorks, Inc.

pos = parserenderinputs(this, varargin{:});
sz  = gui_sizes(this);

if isempty(pos)
    pos = [34 35 724 235]*sz.pixf+[sz.ffs 0 -sz.ffs 0];
    figpos = figuresize(this);
    if pos(3) > figpos(1)-pos(1), pos(3) = figpos(1)-pos(1)-sz.ffs; end
end

actionPos = [pos(1:2) 173*sz.pixf pos(4)];
axesPos   = [pos(1)+actionPos(3) pos(2) pos(3)-actionPos(3) pos(4)];

if iscalledbydspblks(this)
  offset = 12*sz.pixf;
else
  offset = 0;
end

render_frame(this, pos, offset);
render_actions(this, actionPos, offset);
[cshtags, cshtool] = getcshtags(this);
cshelpcontextmenu(this.FigureHandle, this.Handles.frame, cshtags.plot,cshtool);

render_axes(this, axesPos, offset);
render_tools(this);

draw(this);

attachlisteners(this);
prop_listener(this, 'Gain');
prop_listener(this, 'AnnounceNewSpecs');
prop_listener(this, 'ConjugateMode');
prop_listener(this, 'CurrentSection');
lclaction_listener(this);
lclcoordinatemode_listener(this);
currentroots_listener(this);
allroots_listener(this);
errorstatus_listener(this);

% -----------------------------------------------------
function render_actions(this, pos, offset)

h    = get(this, 'Handles');
sz   = gui_sizes(this);
hFig = get(this, 'FigureHandle');

[cshtags, cshtool] = getcshtags(this);

h.ctrlframe = uicontrol(hFig, ...
    'Position', [pos(1) pos(2)+offset pos(3) pos(4)-offset], ...
    'Style', 'Frame', ...
    'Visible', 'Off');
  
icons = LocalMakeIcons;

if offset > 0
  offsetButtonPos = offset - 5*sz.pixf;
else
  offsetButtonPos = 0;
end

buttonPos = [pos(1)+sz.hfus pos(2)+pos(4)-sz.hfus-24+offsetButtonPos 25 24];

h.action_frame = uicontrol(hFig, ...
    'Position', [pos(1) pos(2)+offset pos(3) pos(4)-offset], ...
    'Style', 'Frame', ...
    'Visible', 'Off');    
lbls  = set(this, 'Action');
cshelpcontextmenu(h.action_frame, cshtags.controls,cshtool);

nactions = length(lbls);

for indx = 1:nactions
    h.actionbtn(indx) = uicontrol(hFig, ...
        'Position', buttonPos, ...
        'CData', icons{indx}, ...
        'Tag', lbls{indx}, ...
        'Style', 'Toggle', ...
        'Callback', {@lclbutton_cb, this}, ...
        'TooltipString', getTranslatedString('signal:sigtools:siggui',lbls{indx}), ...
        'Visible', 'Off');
    buttonPos(1) = buttonPos(1)+buttonPos(3);    
    cshTagField = lbls{indx};
    cshTagField = cshTagField(~isspace(cshTagField));
    cshTagField = strrep(cshTagField,'/','');        
    cshelpcontextmenu(h.actionbtn(indx), cshtags.(cshTagField),cshtool);
end

cbs  = callbacks(this);

tags = {'gain', 'coordinatemode', 'real', 'imaginary', 'currentsection'};
lbls = {getString(message('signal:sigtools:siggui:FilterGain')), ...
        getString(message('signal:sigtools:siggui:Coordinates')), ...
        getString(message('signal:sigtools:siggui:Real')), ...
        getString(message('signal:sigtools:siggui:Imaginary')), ...
        getString(message('signal:sigtools:siggui:Section'))};
cbs  = {{cbs.gain, this}, {cbs.property, this, 'CoordinateMode', getString(message('signal:sigtools:siggui:ChangeCoordinateMode'))}, ...
        {cbs.currentvalue, this}, {cbs.currentvalue, this}, {cbs.currentsection, this}, ...
        {cbs.property, this, 'conjugate'}, ...
        {cbs.property, this, 'AnnounceNewSpecs', getString(message('signal:sigtools:siggui:ChangeAutoUpdate'))}};
style = {'edit', 'popup', 'edit', 'edit', 'popup'};
strs  = {'Test', set(this, 'CoordinateMode'), 'Test', 'Test', 1:length(this.AllRoots)};

n = length(tags)+2;

skip = (pos(4)-buttonPos(4)-sz.hfus-n*sz.uh)/(n+1)+sz.uh;

lblPos  = [pos(1)+sz.hfus/2 buttonPos(2)-skip largestuiwidth(lbls) sz.uh];
editPos = [lblPos(1)+lblPos(3)+sz.hfus/2 lblPos(2)+sz.lblTweak pos(3)-lblPos(3)-1.5*sz.hfus sz.uh];

for indx = 1:n-2
    
    h.([tags{indx} '_lbl']) = uicontrol(hFig, ...
        'Position', lblPos, ...
        'HorizontalAlignment', 'Left', ...
        'Visible', 'Off', ...
        'Style', 'Text', ...
        'Tag', tags{indx}, ...
        'String', lbls{indx});
    
    h.(tags{indx}) = uicontrol(hFig, ...
        'Position', editPos, ...
        'Tag', tags{indx}, ...
        'HorizontalAlignment', 'Left', ...
        'Visible', 'Off', ...
        'Style', style{indx}, ...
        'String', getTranslatedStringcell('signal:sigtools:siggui',strs{indx}), ...
        'Callback', cbs{indx});
    
    setenableprop(h.(tags{indx}), this.Enable);
    
    lblPos(2)  = lblPos(2)-skip;
    editPos(2) = editPos(2)-skip;
    
   cshelpcontextmenu(h.([tags{indx} '_lbl']),cshtags.(tags{indx}),cshtool);
   cshelpcontextmenu(h.(tags{indx}), cshtags.(tags{indx}),cshtool);
    
end
% Save untranslated strings in the app data for use in the callback 
setappdata(h.coordinatemode, 'PopupStrings', set(this, 'CoordinateMode'));

strs = {getString(message('signal:sigtools:siggui:Conjugate')), getString(message('signal:sigtools:siggui:AutoUpdate'))};

lblPos(3) = largestuiwidth(strs)+sz.rbwTweak;

h.conjugatemode = uicontrol(hFig, ...
    'Position', lblPos, ...
    'Style', 'CheckBox', ...
    'String', strs{1}, ...
    'HorizontalAlignment', 'Left', ...
    'Visible', 'Off', ...
    'Enable', 'Off', ...
    'Callback', cbs{6});

cshelpcontextmenu(h.conjugatemode, cshtags.conjugatemode, cshtool);  
lblPos(2) = lblPos(2)-skip;


h.announcenewspecs = uicontrol(hFig, ...
    'Position', lblPos, ...
    'Tag', 'announcenewspecs',...
    'Style', 'CheckBox', ...
    'String', strs{2}, ...
    'HorizontalAlignment', 'Left', ...
    'Visible', 'Off', ...
    'Enable', 'On', ...
    'Callback', cbs{7});
cshelpcontextmenu(h.announcenewspecs, cshtags.autoupdate,'fdatool');  

pos = get(h.imaginary, 'Position');
width = largestuiwidth({getString(message('signal:sigtools:siggui:Rad'))});
h.angleunits = uicontrol(hFig, ...
    'Position', [pos(1)+pos(3)-width pos(2) width sz.uh], ...
    'Style', 'Text', ...
    'HorizontalAlignment', 'Left', ...
    'Visible', 'Off', ...
    'String', getString(message('signal:sigtools:siggui:Rad')));

set(this, 'Handles', h);

% -----------------------------------------------------
function render_tools(this)

hFig = get(this, 'FigureHandle');
cbs  = callbacks(this);
h    = get(this, 'Handles');

h.tools = findall(hFig, 'type', 'uimenu', 'tag', 'pzeditor_tools_menu');

if isempty(h.tools)
    hMain = findall(hFig, 'type', 'uimenu', 'tag', 'edit');
    if isempty(hMain)
        hMain = findall(hFig, 'type', 'uimenu', 'tag', 'tools');
        if isempty(hMain)
            hMain = uimenu(hFig, 'Label', getString(message('signal:sigtools:siggui:Tools')));
        end
    end
    h.tools = uimenu(hMain, 'Separator', 'On', 'Label', getString(message('signal:sigtools:siggui:PoleZeroEditor')));
end

tags     = {'selectall', 'selectallpoles', 'selectallzeros', 'selectinsideunitcircle', ...
        'selectoutsideunitcircle', 'selectlowerhalf', 'selectupperhalf', ...
        'selectleft', 'selectright','selectnone'};
tooltips = {getString(message('signal:sigtools:siggui:SelectAll')), ...
            getString(message('signal:sigtools:siggui:SelectAllPoles')), ...
            getString(message('signal:sigtools:siggui:SelectAllZeros')), ...
            getString(message('signal:sigtools:siggui:SelectInsideUnitCircle')), ...
            getString(message('signal:sigtools:siggui:SelectOutsideUnitCircle')), ...
            getString(message('signal:sigtools:siggui:SelectBelowRealAxis')), ...
            getString(message('signal:sigtools:siggui:SelectAboveRealAxis')), ...
            getString(message('signal:sigtools:siggui:SelectLeftHalf')), ...
            getString(message('signal:sigtools:siggui:SelectRightHalf')), ...
            getString(message('signal:sigtools:siggui:DeselectCurrentPolesandZeros'))};

% h.menus.select.main = uimenu(h.tools, 'Label', '&Select');
h.contextmenu.select = uicontextmenu('Parent', hFig);
set(h.axes, 'UIContextMenu', h.contextmenu.select);

for indx = 1:length(tags)
%     h.select.(tags{indx}) = uimenu(h.select.main, ...
    inputs = {'Label', tooltips{indx}, 'Tag', tags{indx}, ...
            'Callback', {cbs.method, this, 'select', tooltips{indx}, tags{indx}(7:end)}};
    h.menus.(tags{indx})       = uimenu(h.tools, inputs{:});
    h.contextmenu.(tags{indx}) = uimenu(h.contextmenu.select, inputs{:}); 
end

% h.action.main = uimenu(h.tools, 'Label', '&Action');
h.contextmenu.action = uicontextmenu('Parent', hFig);

tags = {'invertreal', 'invertimag', 'invertunitcircle', 'mirrorreal','mirrorimag', 'mirrorunitcircle', ...
        'deletecurrentroots'};
tooltips = {getString(message('signal:sigtools:siggui:InvertAboutTheRealAxis')), ...
            getString(message('signal:sigtools:siggui:InvertAboutTheImaginaryAxis')), ...
            getString(message('signal:sigtools:siggui:InvertAboutTheUnitCircle')), ...
            getString(message('signal:sigtools:siggui:MirrorAboutTheRealAxis')), ...
            getString(message('signal:sigtools:siggui:MirrorabouttheImaginaryAxis')), ...
            getString(message('signal:sigtools:siggui:MirrorabouttheUnitCircle')), ...
            getString(message('signal:sigtools:siggui:DeleteCurrentPoleZero'))};
sep = {'off', 'off', 'off', 'on', 'off', 'off', 'on'};

for indx = 1:3
    inputs = {'Label', tooltips{indx}, 'Tag', tags{indx}, 'Separator', sep{indx}, ...
            'Callback', {cbs.method, this, 'invert', tooltips{indx}, tags{indx}(7:end)}};
    h.menus.action.(tags{indx}) = uimenu(h.tools, inputs{:});
    h.contextmenu.(tags{indx})  = uimenu(h.contextmenu.action, inputs{:});
end

for indx = 4:6
    inputs = {'Label', tooltips{indx}, 'Tag', tags{indx}, 'Separator', sep{indx}, ...
            'Callback', {cbs.method, this, 'mirror', tooltips{indx}, tags{indx}(7:end)}};
    h.menus.action.(tags{indx}) = uimenu(h.tools, inputs{:});
    h.contextmenu.(tags{indx})  = uimenu(h.contextmenu.action, inputs{:});
end

for indx = 7:length(tags)
    inputs = {'Label', tooltips{indx}, 'Tag', tags{indx}, 'Separator', sep{indx}, ...
            'Callback', {cbs.method, this, tags{indx}, tooltips{indx}}};
    h.menus.action.(tags{indx}) = uimenu(h.tools, inputs{:});
    h.contextmenu.(tags{indx})  = uimenu(h.contextmenu.action, inputs{:});
end

set(h.menus.action.invertreal, 'Separator', 'On');

inputs = {'Tag', 'scale', 'Label', getString(message('signal:sigtools:siggui:ScaleByAFactor')), 'Callback', {cbs.scale, this}};

% h.action.scale      = uimenu(h.action.main, inputs{:});
h.menus.action.scale = uimenu(h.tools, inputs{:});
h.contextmenu.scale  = uimenu(h.contextmenu.action, inputs{:});

inputs = {'Tag', 'rotate', 'Label', getString(message('signal:sigtools:siggui:RotateCounterClockwise')), 'Callback', {cbs.rotate, this}};

% h.action.rotate      = uimenu(h.action.main, inputs{:});
h.menus.action.rotate = uimenu(h.tools, inputs{:});
h.contextmenu.rotate  = uimenu(h.contextmenu.action, inputs{:});

set(this, 'Handles', h);

% -----------------------------------------------------
function render_frame(this, pos, offset)

h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');
sz   = gui_sizes(this);

h.frame = axes('Parent', hFig, ...
    'Units', 'pixels', ...    
    'Position', pos + [0 1+offset 0 -1-offset] *sz.pixf, ...
    'Box','On',...
    'Color',get(0, 'DefaultUicontrolBackgroundColor'),...
    'Tag','frameaxis',...
    'Visible', 'Off', ...
    'XTick',[],...
    'YTick',[],...
    'XTickLabel',[],...
    'YTickLabel',[]);

zoomBehavior = hggetbehavior(h.frame, 'zoom');
zoomBehavior.Enable = false;

if iscalledbydspblks(this)
  inputPrcPos = [pos(1)+4*sz.pixf pos(2)-(18*sz.pixf) pos(3) pos(4)];
  [h.inputprocessing_lbl, h.inputprocessing_popup] = inputProcessingSelector(this, inputPrcPos);
  set([h.inputprocessing_lbl h.inputprocessing_popup],'Units','Normalized');
end

set(this, 'Handles', h);

% -----------------------------------------------------
function render_axes(this, pos, offset)

sz   = gui_sizes(this);
h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');

h.errorstatus = uicontrol('Parent', hFig, ...
    'Units', 'Pixels', ...
    'Tag', 'pzeditor_errorstatus', ...
    'Style', 'Text', ...
    'FontSize', 2*get(0, 'DefaultUicontrolFontSize'), ...
    'Position', pos + [10 10 -20 -20]*sz.pixf, ...
    'Visible', 'Off');

pos  = pos - [30 20-offset -80 -40] *sz.pixf;

h.axes = axes('Parent', hFig, ...
    'Units', 'Pixels', ...
    'OuterPosition', pos, ...
    'Tag', 'pzeditor_axes', ...
    'XLimMode', 'Manual', ...
    'YLimMode', 'Manual', ...
    'Box', 'On', ...
    'XGrid', 'On', ...
    'YGrid', 'On', ...
    'DataAspectRatio',[1 1 1],...
    'PlotBoxAspectRatio',pos([3 4 4]), ...
    'Visible', 'Off');

h.xlabel = xlabel(h.axes, getString(message('signal:sigtools:siggui:RealPart')));
h.ylabel = ylabel(h.axes, getString(message('signal:sigtools:siggui:ImaginaryPart')));

h.poles = [];
h.zeros = [];

addbuttondownfcn(this, h.axes, 'on'); % Allow interruption

set(this, 'Handles', h);

% -----------------------------------------------------
function attachlisteners(this)

l = [ ...
    handle.listener(this, this.findprop('ErrorStatus'), ...
    'PropertyPostSet', @errorstatus_listener); ...
        handle.listener(this, this.findprop('CurrentSection'), ...
        'PropertyPostSet', @currentsection_listener); ...
        handle.listener(this, this.findprop('CurrentRoots'), ...
        'PropertyPostSet', @currentroots_listener); ...
        handle.listener(this, this.findprop('Action'), ...
        'PropertyPostSet', @lclaction_listener); ...
        handle.listener(this, this.findprop('AllRoots'), ...
        'PropertyPreSet', @allroots_listener); ...
        handle.listener(this, [this.findprop('Gain'), ...
            this.findprop('AnnounceNewSpecs'), ...
            this.findprop('ConjugateMode'), ...
            this.findprop('CurrentSection')], ...
        'PropertyPostSet', @prop_listener);
        handle.listener(this, this.findprop('CoordinateMode'), ...
        'PropertyPostSet', @lclcoordinatemode_listener); ...
    ];

set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

% -----------------------------------------------------
function errorstatus_listener(this, ~)

set(this.Handles.errorstatus, 'String', this.ErrorStatus);

visible_listener(this);
enable_listener(this);

% -----------------------------------------------------
function lclcoordinatemode_listener(this, eventData)

if nargin > 1
    prop_listener(this, eventData);
end

h  = get(this, 'Handles');
sz = gui_sizes(this);

ipos = getpixelpos(this, 'imaginary');
lpos = getpixelpos(this, 'angleunits');

if strcmpi(this.CoordinateMode, 'polar')
    onestr = getString(message('signal:sigtools:siggui:Magnitude'));
    twostr = getString(message('signal:sigtools:siggui:Angle'));
    visState = this.Visible;
    ipos = [ipos(1:2) lpos(1)-ipos(1)-.5*sz.hfus ipos(4)];
else
    onestr = getString(message('signal:sigtools:siggui:Real'));
    twostr = getString(message('signal:sigtools:siggui:Imaginary'));
    visState = 'Off';
    ipos = [ipos(1:2) lpos(1)-ipos(1)+lpos(3) ipos(4)];
end

minwidth = 30*sz.pixf;

if ipos(3) < minwidth
    ipos(3) = minwidth;
end

setpixelpos(this, 'imaginary', ipos);

set(h.angleunits, 'Visible', visState);
set(h.real_lbl, 'String', onestr);
set(h.imaginary_lbl, 'String', twostr);

currentroots_listener(this, 'update_currentvalue');

% -----------------------------------------------------
function lclaction_listener(this, ~)

h = get(this, 'Handles');

hon = findobj(h.actionbtn, 'Tag', get(this, 'Action'));

set(setdiff(h.actionbtn, hon), 'Value', 0);
set(hon, 'Value', 1);

if strcmpi(this.Action, 'move pole/zero')
    set(h.axes, 'UIContextMenu', h.contextmenu.select);
else
    set(h.axes, 'UIContextMenu', []);
end

% -----------------------------------------------------
function lclbutton_cb(hcbo, ~, this)

hfig = ancestor(hcbo, 'figure');
zoom(hfig, 'off');

set(hcbo, 'Value', 1);
set(this, 'Action', get(hcbo, 'Tag'));

function icons = LocalMakeIcons

cm = [0 0 0;
     0.502 0 0;
         0    0.5020         0;
    0.5020    0.5020         0;
         0         0    0.5020;
    0.5020         0    0.5020;
         0    0.5020    0.5020;
    0.7529    0.7529    0.7529;
    0.5020    0.5020    0.5020;
    1.0000         0         0;
         0    1.0000         0;
    1.0000    1.0000         0;
         0         0    1.0000;
    1.0000         0    1.0000;
         0    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    0.4000    0.4000    0.4000;
    0.4267    0.4267    0.4267;
    0.4533    0.4533    0.4533;
    0.4800    0.4800    0.4800;
    0.5067    0.5067    0.5067;
    0.5333    0.5333    0.5333;
    0.5600    0.5600    0.5600;
    0.7529    0.7529    0.7529;
    0.6133    0.6133    0.6133;
    0.6400    0.6400    0.6400;
    0.6667    0.6667    0.6667;
    0.6933    0.6933    0.6933;
    0.7200    0.7200    0.7200;
    0.7467    0.7467    0.7467;
    0.7733    0.7733    0.7733;
    0.8000    0.8000    0.8000;
    1         1         1;
    0.85      0.85       0.85];
 
 d =  [...
    32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 25
    32 24 24 24 24 1  24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 1  1  24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 1  33 1  24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 1  33 33 1  24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 1  33 33 33 1  24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 1  33 33 33 33 1  24 24 24 24 24 24 24 24 17
    32 24 24 24 24 1  33 33 33 33 33 1  24 24 24 24 24 24 24 17
    32 24 24 24 24 1  33 33 33 33 33 33 1  24 24 24 24 24 24 17
    32 24 24 24 24 1  33 33 33 33 33 33 33 1  24 24 24 24 24 17
    32 24 24 24 24 1  33 33 33 33 33 33 33 33 1  24 24 24 24 17
    32 24 24 24 24 1  33 33 33 33 33 1  1  1  1  24 24 24 24 17
    32 24 24 24 24 1  33 33 1  33 33 1  24 24 24 24 24 24 24 17
    32 24 24 24 24 1  33 1  24 1  33 33 1  24 24 24 24 24 24 17
    32 24 24 24 24 1  1  24 24 1  33 33 1  24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 1  33 33 1  24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 1  33 33 1  24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 1  1  1  24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    25 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17];
    
 default=LocalInd2RGB(d,cm); 
    
 p=[...
    32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 25
    32 24 10 24 24 24 10 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 10 24 10 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 10 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 10 24 10 24 24 1  24 24 24 24 24 24 24 24 24 24 17
    32 24 10 24 24 24 10 24 1  1  24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  33 1  24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  33 33 1  24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  33 33 33 1  24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  33 33 33 33 1  24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  33 33 33 33 33 1  24 24 24 24 17
    32 24 24 24 24 24 24 24 1  33 33 33 33 33 33 1  24 24 24 17
    32 24 24 24 24 24 24 24 1  33 33 33 33 1  1  1  24 24 24 17
    32 24 24 24 24 24 24 24 1  33 1  33 33 1  24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  1  24 1  33 1  24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  24 24 24 1  33 1  24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 1  33 1  24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 1  33 1  24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 1  1  1  24 24 24 17
    25 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17];
      
addpole=LocalInd2RGB(p,cm);
      
 z=[...
    32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 25
    32 24 24 10 10 10 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 10 24 24 24 10 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 10 24 24 24 10 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 10 24 24 24 10 24 1  24 24 24 24 24 24 24 24 24 24 17
    32 24 24 10 10 10 24 24 1  1  24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  33 1  24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  33 33 1  24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  33 33 33 1  24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  33 33 33 33 1  24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  33 33 33 33 33 1  24 24 24 24 17
    32 24 24 24 24 24 24 24 1  33 33 33 33 33 33 1  24 24 24 17
    32 24 24 24 24 24 24 24 1  33 33 33 33 1  1  1  24 24 24 17
    32 24 24 24 24 24 24 24 1  33 1  33 33 1  24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  1  24 1  33 1  24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1  24 24 24 1  33 1  24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 1  33 1  24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 1  33 1  24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 1  1  1  24 24 24 17
    25 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17];
         
addzero=LocalInd2RGB(z,cm);

e= [...
    32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 25
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 1  1  1  1  1  1  1  24 24 24 24 24 24 24 24 24 24 17
    32 24 1  1  33 33 33 33 33 1  24 24 24 24 24 24 24 24 24 17
    32 24 1  33 1  33 33 33 33 33 1  24 24 24 24 24 24 24 24 17
    32 24 1  33 33 1  33 33 33 33 33 1  24 24 24 24 24 24 24 17
    32 24 24 1  33 33 1  33 33 33 33 33 1  24 24 24 24 24 24 17
    32 24 24 24 1  33 33 1  33 33 33 33 33 1  24 24 24 24 24 17
    32 24 24 24 24 1  33 33 1  33 33 33 33 33 1  24 24 24 24 17
    32 24 24 24 24 24 1  33 33 1  33 33 33 33 33 1  24 24 24 17
    32 24 24 24 24 24 24 1  33 33 1  33 33 33 33 33 1  24 24 17
    32 24 24 24 24 24 24 24 1  33 33 1  1  1  1  1  1  1  24 17
    32 24 24 24 24 24 24 24 24 1  33 1  33 33 33 33 33 1  24 17
    32 24 24 24 24 24 24 24 24 24 1  1  1  1  1  1  1  1  24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    25 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17];
erase=LocalInd2RGB(e,cm); 

icons = {default, addpole, addzero, erase};

%%%%%%%%%%%%%%%%%%%%
%%% LocalInd2RGB %%%
%%%%%%%%%%%%%%%%%%%%
function rout = LocalInd2RGB(a,cm)

% Extract r,g,b components
r = zeros(size(a)); r(:) = cm(a,1);
g = zeros(size(a)); g(:) = cm(a,2);
b = zeros(size(a)); b(:) = cm(a,3);

rout = zeros([size(r),3]);
rout(:,:,1) = r;
rout(:,:,2) = g;
rout(:,:,3) = b;

% [EOF]

function thisrender(this, varargin)
%RENDER Renders the "Realize Model" panel
%   RENDER Renders the sidebar object associated with hSB.

%   Copyright 1995-2017 The MathWorks, Inc.

pos = parserenderinputs(this, varargin{:});

sz  = gui_sizes(this);

if isempty(pos)
    pos = [10 10 710 205] * sz.pixf;
end

this.privGUIPosition = pos;

hFig = get(this, 'FigureHandle');

if iscalledbydspblks(this)
  containerPos = [pos(1) pos(2)+(27*sz.pixf) pos(3) pos(4)*.9];
  offset = 0;
else
  containerPos = [pos(1) pos(2)+(52*sz.pixf) pos(3) pos(4)*.78];
  offset = 25*sz.pixf;
end

h.container = uicontainer('Parent', hFig, ...
    'Units',    'Pixels', ...
    'Position', containerPos, ...
    'Visible',  'off');
set(h.container, 'Units', 'normalized');
hLayout = siglayout.gridbaglayout(h.container);
set(hLayout, 'VerticalWeights', [1 0], ...
    'HorizontalGap', 5*sz.pixf, ...
    'VerticalGap', 5*sz.pixf);

set(this, 'Container', h.container, 'Layout', hLayout);

h.mframe = uipanel('Parent', h.container, ...
    'Title', [' ' getString(message('signal:sigtools:siggui:Model')) ' '], ...
    'Tag', 'wiz_model');
h.oframe = uipanel('Parent', h.container, ...
    'Title', [' ' getString(message('signal:sigtools:siggui:Optimization')) ' '], ...
    'Tag', 'wiz_optimization');

[cshtags, cshtool] = getcshtags(this);  
cshelpcontextmenu(h.mframe,cshtags.panel,cshtool);
cshelpcontextmenu(h.oframe,cshtags.panel,cshtool);

hLayout.add(h.mframe, 1, 1, 'Fill', 'Both');
hLayout.add(h.oframe, 1, 2, 'Fill', 'Both');

cbs   = siggui_cbs(this);
buttonWidth  = largestuiwidth({getString(message('signal:sigtools:siggui:RealizeModel'))},'Push');
h.button = uicontrol(hFig, ...
    'Style', 'Push', ...
    'String', getString(message('signal:sigtools:siggui:RealizeModel')), ...
    'Visible','Off',...
    'Position', [pos(1) pos(2)+offset buttonWidth+3*sz.pixf sz.uh+3*sz.pixf], ...
    'Tag','dspfwiz_build',...
    'Callback', {cbs.method, this, 'build'});
[cshtags, cshtool] = getcshtags(this);  
cshelpcontextmenu(h.button, cshtags.actionbutton,cshtool);

inputPrcPos =  [pos(1)+18*sz.pixf pos(2)+offset pos(3) pos(4)];

[h.inputprocessing_lbl,h.inputprocessing_popup,inputProcOffset] = inputProcessingSelector(this, inputPrcPos,false);

inputPrcPosLblWidth = get(h.inputprocessing_lbl,'Position');
inputPrcPosLblWidth = inputPrcPosLblWidth(3);

rateOptsPos =  [inputPrcPos(1) pos(2) pos(3) pos(4)];
[h.rateoptions_lbl,h.rateoptions_popup] = rateOptionsSelector(this, rateOptsPos, inputPrcPosLblWidth);

alignInputProcessingWithRateOptions(h,sz);

guiWidth = pos(3)+pos(1);
totalOffset = inputProcOffset + inputPrcPos(1) + sz.uuhs;
buttonPos = get(h.button,'Position');
newCenter = totalOffset + (guiWidth - totalOffset)/2;
set(h.button,'Position',[newCenter-buttonPos(3)/2 buttonPos(2:4)]);

set([h.button h.inputprocessing_lbl h.inputprocessing_popup h.rateoptions_lbl h.rateoptions_popup],'Units','Normalized');

set(this, 'Handles', h);
  
rendercontrols(this, h.mframe, {'blockname', 'destination', ...
    'userdefined', 'overwriteblock', 'usebasicelements'});
rendercontrols(this, h.oframe, {'optimizezeros', 'optimizeones', ...
    'optimizenegones', 'optimizedelaychains', 'optimizescalevalues'});

h = get(this, 'Handles');

hLayout = siglayout.gridbaglayout(h.mframe);
set(hLayout, 'HorizontalWeights', [0 1]);
hLayout.add(h.blockname_lbl,    1, 1, ...
    'Anchor', 'southwest', ...
    'MinimumWidth', largestuiwidth(h.blockname_lbl), ...
    'TopInset', 15*sz.pixf+sz.lblTweak, ...
    'LeftInset', 10*sz.pixf);
hLayout.add(h.blockname,        1, 2, ...
    'MinimumWidth', 100*sz.pixf, ...
    'Anchor', 'southwest', ...
    'Fill', 'Horizontal', ...
    'TopInset', 15*sz.pixf, ...
    'RightInset', 10*sz.pixf);
hLayout.add(h.destination_lbl, 2, 1, ...
    'MinimumWidth', largestuiwidth(h.destination_lbl), ...
    'TopInset', sz.lblTweak, ...
    'Anchor', 'southwest', ...
    'LeftInset', 10*sz.pixf);
hLayout.add(h.destination,     2, 2, ...
    'Anchor', 'southwest', ...
    'MinimumWidth', 100*sz.pixf, ...
    'RightInset', 10*sz.pixf);
hLayout.add(h.userdefined_lbl, 3, 1, ...
    'Anchor', 'southwest', ...
    'MinimumWidth', largestuiwidth(h.userdefined_lbl), ...
    'TopInset', sz.lblTweak, ...
    'LeftInset', 10*sz.pixf);
hLayout.add(h.userdefined,     3, 2, ...
    'Anchor', 'southwest', ...
    'Fill', 'Horizontal', ...
    'MinimumWidth', 100*sz.pixf, ...
    'RightInset', 10*sz.pixf);
hLayout.add(h.overwriteblock,   4, [1 2], ...
    'Fill', 'Horizontal', ...
    'LeftInset', 10*sz.pixf, ...
    'RightInset', 10*sz.pixf);
  
hLayout.add(h.usebasicelements, 5, [1 2], ...
    'Fill', 'Horizontal', ...
    'BottomInset', 5*sz.pixf, ...
    'LeftInset', 10*sz.pixf, ...
    'RightInset', 10*sz.pixf);

hLayout = siglayout.gridbaglayout(h.oframe);
hLayout.add(h.optimizezeros,       1, 1, ...
    'Fill', 'Horizontal', ...
    'TopInset',  15*sz.pixf, ...
    'LeftInset', 10*sz.pixf, ...
    'RightInset', 10*sz.pixf);
hLayout.add(h.optimizeones,        2, 1, ...
    'Fill', 'Horizontal', ...
    'LeftInset', 10*sz.pixf, ...
    'RightInset', 10*sz.pixf);
hLayout.add(h.optimizenegones,     3, 1, ...
    'Fill', 'Horizontal', ...
    'LeftInset', 10*sz.pixf, ...
    'RightInset', 10*sz.pixf);
hLayout.add(h.optimizedelaychains, 4, 1, ...
    'Fill', 'Horizontal', ...
    'LeftInset', 10*sz.pixf, ...
    'RightInset', 10*sz.pixf);

hLayout.add(h.optimizescalevalues, 5, 1, ...
    'Fill', 'Horizontal', ...
    'LeftInset', 10*sz.pixf, ...
    'RightInset', 10*sz.pixf);
  
l = [ ...
        handle.listener(this, this.findprop('Filter'), ...
        'PropertyPostSet', @lclfilter_listener); ...
        handle.listener(this, this.findprop('BlockName'), ...
        'PropertyPostSet', @blockname_listener); ...
    ];

set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', union(this.WhenRenderedListeners, l));

lclfilter_listener(this);
blockname_listener(this);

setupenablelink(this, 'destination', 'user defined', 'userdefined', '-update');
setupenablelink(this, 'destination', {'current', 'user defined'}, 'overwriteblock', '-update');
setupenablelink(this, 'usebasicelements', 'on', 'optimizezeros', ...
    'optimizeones', 'optimizenegones', 'optimizedelaychains', '-update');

%-----------------------------------------------------------------------
function alignInputProcessingWithRateOptions(h,sz)
% find largest width between input processing / rate option labels
lblW = max(h.inputprocessing_lbl.Position(3),h.rateoptions_lbl.Position(3));
lblX = min(h.inputprocessing_lbl.Position(1),h.rateoptions_lbl.Position(1));

% align labels
h.inputprocessing_lbl.Position(1) = lblX;
h.inputprocessing_lbl.Position(3) = lblW;
h.rateoptions_lbl.Position(1) = lblX;
h.rateoptions_lbl.Position(3) = lblW;
h.inputprocessing_lbl.HorizontalAlignment = 'right';
h.rateoptions_lbl.HorizontalAlignment = 'right';

% align left edges of popups
h.inputprocessing_popup.Position(1) = lblX+lblW + sz.uuhs;
h.rateoptions_popup.Position(1) = lblX+lblW + sz.uuhs;
  
%-----------------------------------------------------------------------
function [label,popup] = rateOptionsSelector(this,pos,inputPrcPosLblWidth)

bgc   = get(0,'DefaultUicontrolBackgroundColor');
sz    = gui_sizes(this);

hFig  = get(this,'FigureHandle');

specsX = {...
  siggui.message('signal:siggui:dspfwiz:thisrender:EnforceSingleRate'), ...
  siggui.message('signal:siggui:dspfwiz:thisrender:AllowMultirate')};

specs = {'Enforce single-rate processing', 'Allow multirate processing'}; 	

labelStr = siggui.message('signal:siggui:dspfwiz:thisrender:RateOptionsLabel');

lblWidth =  largestuiwidth({labelStr},'text');
lblPos = [pos(1) pos(2)+(2*sz.pixf) lblWidth sz.uh];

% Render the Input Processing label
label = uicontrol(hFig,...
    'Style','text',...
    'HorizontalAlignment', 'Center', ...
    'BackgroundColor',bgc,...
    'Position', lblPos,...
    'String',labelStr,...
    'Visible','Off',...
    'Tag','dspfwiz_rateoptions_lbl');

offset = inputPrcPosLblWidth - lblWidth;

popUpWidth  = largestuiwidth(specs,'popup');
fsPopPos = [pos(1)+lblWidth+sz.uuhs+offset pos(2) popUpWidth sz.uh+(7*sz.pixf)];

% Render the Rate Options popupmenu
popup = uicontrol(hFig,...
    'Style','Popup',...
    'BackgroundColor','White',...
    'HorizontalAlignment', 'Left', ...
    'Position', fsPopPos,...
    'Visible','Off',...
    'String', specsX,...
    'Tag','dspfwiz_rateoptions_popup', ...
    'Callback',{@selectedrateoptions_cb, this, specs});

cshelpcontextmenu(label, 'fdatool_dspfwiz_rateoptions\dsp','fdatool');
cshelpcontextmenu(popup, 'fdatool_dspfwiz_rateoptions\dsp','fdatool');

%----------------------------------------------------------------------
function selectedrateoptions_cb(hcbo, ~, this, strs)

indx = get(hcbo, 'Value');
set(this, 'RateOptions', strs{indx});

sendfiledirty(this);

%-------------------------------------------------------------------
function lclfilter_listener(this, ~)

Hd = get(this, 'Filter');
h  = get(this, 'Handles');

if ismethod(Hd, 'block') && isspblksinstalled
    w = warning('off'); %#ok<WNOFF>
    try

        [wstr, wid] = lastwarn;
        blockparams(Hd, 'off');
        enabstate = this.Enable;
        lastwarn(wstr, wid);
    catch ME %#ok<NASGU>

        set(this, 'UseBasicElements', 'On');
        enabstate = 'off';
    end
    warning(w);
else
    set(this, 'UseBasicElements', 'On');
    enabstate = 'off';
end

if ~isrealizable(Hd)
    enabstate = 'off';
    set(this, 'UseBasicElements', 'Off');
end

setenableprop(h.usebasicelements, enabstate);

if isa(Hd, 'dfilt.abstractsos')
    enabstate = this.Enable;
else
    enabstate = 'off';
end

setenableprop(h.optimizescalevalues, enabstate);
prop_listener(this, 'optimizescalevalues');

%-------------------------------------------------------------------
function blockname_listener(this, ~)

h = get(this, 'Handles');

set(h.overwriteblock, 'String', ...
    sprintf(getTranslatedString('signal:siggui:renderedlabel',get(findprop(this, 'OverwriteBlock'), 'Description')), this.BlockName));

% Adjust uicontrol size to fit new label, but don't let it extend outside the frame. 
%

% Cache old units.
origunits = get(h.overwriteblock,'Units');
set(h.overwriteblock,'Units','pixels');

% Get sizes and positions.
sz = gui_sizes(this);
w = largestuiwidth(h.overwriteblock);
w = w+sz.rbwTweak;
pos = get(h.overwriteblock,'Position');

% Set new position, but don't overrun the frame.
mframepos = getpixelpos(this,'mframe',1);
framewidth = mframepos(3);
if w > framewidth,   w = framewidth-2*sz.hfus; end
set(h.overwriteblock,'Position',[pos(1), pos(2), w, pos(4)]);

% Reset to original units.
set(h.overwriteblock,'Units',origunits);

% [EOF]

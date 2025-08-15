function thisrender(this, varargin)
%RENDER  Render the freqmagspecs frame and all associated uicontrols
%   RENDER(H, HFIG, POS)
%   H   -   Handle to freqmagspecs object
%   HFIG-   Handle to figure into which to render
%   POS -   Position at which the frame should be rendered

%   Author(s): Z. Mecklai, J. Schickler
%   Copyright 1988-2011 The MathWorks, Inc.

pos = parserenderinputs(this, varargin{:});
if isempty(pos), pos = 'freqmag'; end

% Render the super class to get the labels and edit boxes
super_render(this, pos);

pos = getpixelpos(this, 'framewlabel', 1);

hFig = get(this, 'FigureHandle');

% Render the FSSpecifier
fsh = getcomponent(this, '-class', 'siggui.specsfsspecifier');
render(fsh, hFig, pos);

% Layout the uicontrols
pos = getpixelpos(this, 'framewlabel', 1);

layout_uicontrols(this, pos);

sz  = gui_sizes(this);
pos = [pos(1)+sz.hfus pos(2) pos(3)-3*sz.hfus pos(4)-sz.uh-sz.vfus-2*sz.uuvs];

% Get the handle to the LabelsAndValues class
lvh = getcomponent(this, 'siggui.labelsandvalues');

% Render the LabelsAndValues class
render(lvh, hFig, pos);

cshelpcontextmenu(this, 'fdatool_ALL_freqmag_specs_frame');

% -------------------------------------------------------------------------
function layout_uicontrols(this,pos,sz) 
%LAYOUT_UICONTROLS  Layout the rendered uicontrols for the larger frame 

% Get the handle to the fesspecifier 
fsh = getcomponent(this, '-class', 'siggui.specsfsspecifier'); 

sz = gui_sizes(this);

% Get the uicontrols handles to all the objects 
handles = get(this, 'Handles');
fshandles = get(fsh, 'Handles');

framePos = pos;

% Set the Position of the Frequency Units popup label 
units_lbl_width = largestuiwidth({...
    getString(message('signal:sigtools:siggui:FreqVector')),...
    getString(message('signal:sigtools:siggui:FreqEdges')),...
    getString(message('signal:sigtools:siggui:GrpdelayVector')),...
    getString(message('signal:sigtools:siggui:WeightVector')),...
    getString(message('signal:sigtools:siggui:FrequencyUnits1'))}); 
units_lbl_pos = [framePos(1)+sz.hfus, ... 
        framePos(2)+framePos(4)-sz.uh-2*sz.vfus-sz.lblTweak,... 
        units_lbl_width,... 
        sz.uh]; 
set(fshandles.units_lbl, ... 
    'Units','pixels',... 
    'Position',units_lbl_pos,... 
    'String',getString(message('signal:sigtools:siggui:FrequencyUnits1'))); 

% Set the position of the popup 
lbl_pos = getpixelpos(this, 'framewlabel', 2);
popup_width = 120*sz.pixf; % lbl_pos(1) + lbl_pos(3) - units_lbl_pos(1) - units_lbl_pos(3); 
popup_pos = [units_lbl_pos(1)+units_lbl_pos(3),... 
        units_lbl_pos(2)+sz.lblTweak, ... 
        popup_width,... 
        sz.uh]; 
set(fshandles.units, ... 
    'Units','pixels',... 
    'Position',popup_pos); 

% Calculate and set the position of the FS label 
indent   = 10*sz.pixf; 
uiWidth = largestuiwidth({'Fs:'}); 
fs_lbl_pos = [popup_pos(1)+popup_pos(3) + indent,... 
        units_lbl_pos(2),... 
        uiWidth,... 
        sz.uh]; 
set(fshandles.value_lbl, ... 
    'Units','pixels',... 
    'Position',fs_lbl_pos); 

% Set the position of the FS edit box 
eb_pos = [fs_lbl_pos(1) + fs_lbl_pos(3) + sz.uuhs,... 
        units_lbl_pos(2) + sz.lblTweak,... 
        framePos(1) + framePos(3) - (fs_lbl_pos(1) + fs_lbl_pos(3) + sz.uuhs + 17*sz.pixf),... 
        sz.uh]; 
set(fshandles.value, ... 
    'Units','pixels',... 
    'Position', eb_pos); 

% [EOF]

function thisrender(this, varargin)
%THISRENDER Render the design panel

%   Copyright 1988-2017 The MathWorks, Inc.

pos  = parserenderinputs(this, varargin{:});

sz = gui_sizes(this);

if isempty(pos)
    x = 68*sz.pixf;
    y = 75*sz.pixf;   
    y2 = y-sz.bh-sz.uuvs;
    h2 = 205*sz.pixf;
    w2 = 707*sz.pixf;
else
    x  = pos(1)+sz.ffs;
    y  = pos(2)+sz.bh+sz.uuvs;
    y2 = pos(2);
    w2 = pos(3);
    h2 = pos(4)-sz.bh-sz.uuvs-sz.vffs+2*sz.pixf;
end
w  = 174*sz.pixf;
h1 = 76*sz.pixf;

hFig = get(this, 'FigureHandle');

hft = getcomponent(this, '-class', 'siggui.selector', 'Name', 'Response Type');
render(hft, hFig, [x y w h2], [x y+h1+sz.uuvs w h2-h1-(sz.uuvs+sz.vfus)]);
cshelpcontextmenu(hft, this.ResponseTypeCSHTag);

hdm = getcomponent(this, '-class', 'siggui.selector', 'Name', 'Design Method');
render(hdm, hFig, [x y w h1]);
cshelpcontextmenu(hdm, 'fdatool_design_method_frame');

renderactionbtn(this, [x y2 w2 h1], 'Design Filter', 'design', 'design filter');

if iscalledbydspblks(this)
  x = x+12*sz.pixf;
  guiWidth = pos(3)+pos(1);
  inputPrcPos =  [x y2 w2 h1];
  h = get(this,'Handles');
  [h.inputprocessing_lbl, h.inputprocessing_popup, inputProcOffset] = inputProcessingSelector(this, inputPrcPos);      
  inputProcOffset = inputProcOffset + x;
  buttonPos = get(h.design,'Position');
  newCenter = inputProcOffset + (guiWidth - inputProcOffset)/2;
  set(h.design,'Position',[newCenter-buttonPos(3)/2 buttonPos(2:4)]);
  set(this,'Handles',h);  
  set([h.inputprocessing_lbl h.inputprocessing_popup],'Units','Normalized');
end
handles = get(this,'Handles');
set(handles.design,'Units','Normalized');

attachlisteners(this);
lclbuildcurrent(this);

% ---------------------------------------------------------------------
function lclbuildcurrent(this)
% Frames have been hard coded to speed up launch time

hFig  = get(this, 'FigureHandle');

hcomp = [siggui.filterorder, ...
    siggui.remezoptionsframe];% , ...
%         fdadesignpanel.lpfreqpassstop, ...
%         fdadesignpanel.lpmag];

render(hcomp(1), hFig);
render(hcomp(2), hFig);
hframe = [hcomp siggui.freqspecs siggui.magspecs];
%         render(hcomp(3), [], hFig); ...
%         render(hcomp(4), [], hFig);];
% set(hcomp(4), 'IRType', 'FIR');

% Do some more delayed loading of classes.  Since the lpfreqpassstop and
% lpmag classes just contain the freqspecs and magspecs classes, we can get
% away with crteating them and setting them up ourselves.
set(hframe(3), 'Labels', {'Fpass', 'Fstop'}, 'Values', {'9600', '12000'});
set(hframe(4), 'Labels', {'Apass', 'Astop'}, 'Values', {'1', '80'});

render(hframe(3), hFig);
render(hframe(4), hFig);

addcomponent(this, hcomp);
set(this, 'Frames', hframe);
set(this, 'ActiveComponents', hframe);

listeners(this, [], 'addlisteners2components');

% ---------------------------------------------------------------------
function attachlisteners(this)

hDM = getcomponent(this, '-class', 'siggui.selector', 'Name', 'Design Method');
hFT = getcomponent(this, '-class', 'siggui.selector', 'Name', 'Response Type');

listener = [...
        handle.listener(hDM, 'NewSelection', {@listeners, 'designmethod_listener'}); ...
        handle.listener(hDM, 'NewSubSelection', {@listeners, 'designmethod_listener'}); ...
        handle.listener(hFT, 'NewSelection', {@listeners, 'responsetype_listener'}); ...
        handle.listener(hFT, 'NewSubSelection', {@listeners, 'responsetype_listener'}); ...
        handle.listener(this, this.findprop('CurrentDesignMethod'), ...
        'PropertyPostSet', {@listeners, 'currentdesignmethod_listener'}); ...
        handle.listener(this, this.findprop('StaticResponse'), ...
        'PropertyPostSet', {@listeners, 'staticresponse_listener'}); ...
    ];

set(listener, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', listener);

setupenablelink(this, 'isdesigned', false, 'design');

% [EOF]

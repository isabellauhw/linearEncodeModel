function [label,selectedinputprocessing,offset] = inputProcessingSelector(this,pos,varargin)
%INPUTPROCESSINGSELECTOR Render input processing selector popup

%   Copyright 2011-2016 The MathWorks, Inc.

bgc   = get(0,'DefaultUicontrolBackgroundColor');
sz    = gui_sizes(this);


specsX = {siggui.message(...
  'signal:siggui:siggui:inputProcessingSelector:ColumnsAsChannels'), ...
  siggui.message(...
  'signal:siggui:siggui:inputProcessingSelector:ElementsAsChannels')};

specs = {'Columns as channels (frame based)',...
         'Elements as channels (sample based)'};


hFig  = get(this,'FigureHandle');

labelStr = siggui.message(...
  'signal:siggui:siggui:inputProcessingSelector:InputProcLabel');

lblWidth =  largestuiwidth({labelStr},'text');
lblPos = [pos(1) pos(2)+(2*sz.pixf) lblWidth sz.uh];

sigguiType = class(this);
idx = strfind(sigguiType,'.')+1;

% Render the Input Processing label
label = uicontrol(hFig,...
    'Style','text',...
    'HorizontalAlignment', 'Center', ...
    'BackgroundColor',bgc,...
    'Position', lblPos,...
    'String',labelStr,...
    'Visible','Off',...
    'Tag',[sigguiType(idx:end) '_inputproc_lbl']);

popUpWidth  = largestuiwidth(specs,'popup');
fsPopPos = [pos(1)+lblWidth+sz.uuhs pos(2) popUpWidth sz.uh+(7*sz.pixf)];

% Render the Input Processing popupmenu
selectedinputprocessing = uicontrol(hFig,...
    'Style','Popup',...
    'BackgroundColor','White',...
    'HorizontalAlignment', 'Left', ...
    'Position', fsPopPos,...
    'Visible','Off',...
    'String', specsX,...
    'Tag',[sigguiType(idx:end) '_inputproc_popup'], ...
    'Callback',{@selectedinputprocessing_cb, this, specs});
  
offset = lblWidth+sz.uuhs + popUpWidth;

cshelpcontextmenu(label, 'fdatool_inputprocessing\signal', 'fdatool');  
cshelpcontextmenu(selectedinputprocessing, 'fdatool_inputprocessing\signal', 'fdatool');  
%----------------------------------------------------------------------
function selectedinputprocessing_cb(hcbo, ~, this, strs)

indx = get(hcbo, 'Value');
set(this, 'InputProcessing', strs{indx});

thisselectedinputprocessing_cb(this)

sendfiledirty(this);

% [EOF]

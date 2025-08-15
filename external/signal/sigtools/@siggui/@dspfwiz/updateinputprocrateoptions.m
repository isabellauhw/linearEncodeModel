function updateinputprocrateoptions(this)
%UPDATEINPUTPROCRATEOPTIONS

%   Copyright 2011 The MathWorks, Inc.

hdls = get(this,'Handles');

inputProcSpecs = {'Columns as channels (frame based)',...
  'Elements as channels (sample based)'}; % (FB, SB)

rateOptionsSpecs = {'Enforce single-rate processing',...
  'Allow multirate processing'};

inputProcSpecsX = {siggui.message(...
  'signal:siggui:siggui:inputProcessingSelector:ColumnsAsChannels'), ...
  siggui.message(...
  'signal:siggui:siggui:inputProcessingSelector:ElementsAsChannels')}; % (FB, SB)

rateOptionsSpecsX = {...
  siggui.message('signal:siggui:dspfwiz:thisrender:EnforceSingleRate'), ...
  siggui.message('signal:siggui:dspfwiz:thisrender:AllowMultirate')};

% Input processing
forceValue = false;
if strcmpi(this.UseBasicElements,'on')
  % realizemdl method
  if ~doFrameProcessing(this.Filter) || ~isfdtbxinstalled
    % realizemdl only supports SB
    inputProcSpecsX(1)  = [];
    this.InputProcessing = 'Elements as channels (sample based)';
    forceValue = true;
  end  
else
  % block method
  restrictions = getblockinputprocessingrestrictions(this.Filter);
  if ~isempty(restrictions) && strcmp(restrictions,'columnsaschannels')
    % Only supports elements as channels
    inputProcSpecsX(1)  = [];
    this.InputProcessing = 'Elements as channels (sample based)';
    forceValue = true;
  elseif ~isempty(restrictions) && strcmp(restrictions,'elementsaschannels')
    % Only supports columns as channels
    inputProcSpecsX(2) = [];
    this.InputProcessing = 'Columns as channels (frame based)';
    forceValue = true;
  end
end
setInputProcessingOptions(this,hdls,inputProcSpecsX,inputProcSpecs,forceValue);

% Rate options
forceValue = false;
if ismultirate(this.Filter)
  if strcmpi(this.UseBasicElements,'on')
    % realizemdl method
     restrictions = getrealizemdlraterestrictions(this.Filter,convertInputProcName(this));
  else
    % block method
    restrictions = getblockraterestrictions(this.Filter,convertInputProcName(this));
  end
    
  if ~isempty(restrictions) && strcmp(restrictions,'enforcesinglerate')
    % realizemdl method only suppports multirate
    rateOptionsSpecsX(1) = [];
    this.RateOption = 'Allow multirate processing';
    forceValue = true;
  elseif ~isempty(restrictions) && strcmp(restrictions,'allowmultirate')
    %Only single rate supported
    rateOptionsSpecsX(2) = [];
    this.RateOption = 'Enforce single-rate processing';
    forceValue = true;
  end
  
  setRateOptions(this,hdls,rateOptionsSpecsX,rateOptionsSpecs,forceValue);
  showRateOptionsWidget(this,true)  
else
  showRateOptionsWidget(this,false)
end

%--------------------------------------------------------------------------
function name = convertInputProcName(this)

if strcmp(this.InputProcessing,'Columns as channels (frame based)')
  name = 'columnsaschannels';
else
  name = 'elementsaschannels';
end
  
%--------------------------------------------------------------------------
function idx = str2idx(this,type,specs)

if strcmp(type,'inputProcessing')
  value = this.InputProcessing;
else
  value = this.RateOptions;
end
idx  = find(strcmp(value,specs)==1);

%--------------------------------------------------------------------------
function setInputProcessingOptions(this,hdls,specsX,specs,forceValue)

set(hdls.inputprocessing_popup, 'String', specsX);
if forceValue
  set(hdls.inputprocessing_popup, 'Value', 1);
else
  idx = str2idx(this,'inputProcessing',specs);
  set(hdls.inputprocessing_popup, 'Value', idx);
end

%--------------------------------------------------------------------------
function setRateOptions(this,hdls,specsX,specs,forceValue)

set(hdls.rateoptions_popup, 'String', specsX);
if forceValue
  set(hdls.rateoptions_popup, 'Value', 1);
else
  idx = str2idx(this,'rateOptions',specs);
  set(hdls.rateoptions_popup, 'Value', idx);
end

%--------------------------------------------------------------------------
function showRateOptionsWidget(this,showFlag)
% siggui_visible_listener will make the widget visible if
% privShowRateOptionsFlag is true
this.privShowRateOptionsFlag = showFlag;

% [EOF]
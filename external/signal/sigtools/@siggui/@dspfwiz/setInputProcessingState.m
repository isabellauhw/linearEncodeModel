function setInputProcessingState(this, s)
%setInputProcessingState

%   Copyright 2011 The MathWorks, Inc.

% Set the input processing option. If loading from a pre R2011b block, then
% set input processing to inherited. 

if ~iscalledbydspblks(this)
  return;
end

if isfield(s,'InputProcessing')  
  set(this,'InputProcessing',s.InputProcessing);   
  if strcmpi(s.InputProcessing,'columns as channels (frame based)')
    idx = 1;
  else
    idx = 2;
  end
else
  idx = 1;
  set(this,'InputProcessing','columns as channels (frame based)');
end  
hdls = get(this,'Handles'); 
set(hdls.inputprocessing_popup,'Value',idx)

function setstate(this, state)
%SETSTATE   Set the state.

%   Copyright 1988-2011 The MathWorks, Inc.

% Set the input processing option. If loading from a pre R2011b block, then
% set input processing to inherited. 
setInputProcessingState(this,state);

if isfield(state,'Gain')
  if length(state.Gain) > 1
    this.Gain = state.Gain(this.CurrentSection);
  else
    this.Gain = state.Gain;
  end    
end

if isfield(state,'AnnounceNewSpecs')
  this.AnnounceNewSpecs = state.AnnounceNewSpecs;
end

% [EOF]

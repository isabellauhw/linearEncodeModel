function state = getstate(this)
%GETSTATE   Get the state.

%   Copyright 1988-2011 The MathWorks, Inc.

prt = get(this.Parent);
if prt.UserData.flags.calledby.dspblks > 0
  state.InputProcessing = this.InputProcessing;
end

%state.Gain = this.Gain;
state.AnnounceNewSpecs = this.AnnounceNewSpecs;

allroots = get(this, 'AllRoots');
for idx = 1:length(allroots)
  state.Gain(idx) = allroots(idx).gain;
end
 
% [EOF]

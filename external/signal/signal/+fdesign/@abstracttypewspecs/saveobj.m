function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Copyright 1999-2005 The MathWorks, Inc.

s.class         = class(this);
s.CaptureState  = this.CapturedState;
s.Specification = this.SpecificationType;

for indx = 1:length(this.AllSpecs)
    s.AllSpecs{indx} = saveobj(this.AllSpecs(indx));
end

s = setstructfields(s, thissaveobj(this));

% Copy the MaskScalingFactor property if exists
if isprop(this,'MaskScalingFactor')
  s.MaskScalingFactor = this.MaskScalingFactor;
end

% [EOF]

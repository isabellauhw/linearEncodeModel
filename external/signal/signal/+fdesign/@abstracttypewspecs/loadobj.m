function this = loadobj(this, s)
%LOADOBJ   Load this object

%   Copyright 1999-2008 The MathWorks, Inc.

if nargin < 2
    s    = this;
    this = feval(s.class);
end

for indx = 1:length(s.AllSpecs)
    hAllSpecs(indx) = feval(s.AllSpecs{indx}.class); 
end

% Backwards compatibility
if isfield(s, 'SpecificationType')
    s.Specification = s.SpecificationType;
end

% load the MaskScalingFactor property if exists
if isfield(s,'MaskScalingFactor')
  this.MaskScalingFactor = s.MaskScalingFactor;
end
   
this.CapturedState = s.CaptureState;
this.AllSpecs = hAllSpecs'; % transpose to column vector

if strcmpi(this.SpecificationType, s.Specification)
    updatecurrentspecs(this);  
else
    this.Specification = s.Specification;
end

% Allow subclasses to set themselves up before trying to set the specs of
% the contained objects.  If they need that information they can get it
% from S.
thisloadobj(this, s);

% Set up all the properties AFTER setting the specificationtype because
% SETCURRENTSPECS calls SYNCSPECS which would overwrite the specifications.
for indx = 1:length(s.AllSpecs)
       this.AllSpecs(indx).loadobj(this.AllSpecs(indx),s.AllSpecs{indx});
end

% [EOF]

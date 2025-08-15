function specification = set_specification(this, specification)
%SET_SPECIFICATION   Pre-Set Function for the 'Specification' property.

%   Copyright 1999-2005 The MathWorks, Inc.

% This should be private.

notify(this, 'FaceChanging');

this.privSpecification = specification;

updatecurrentspecs(this);

c = this.CapturedState; 

f = strrep(class(this.CurrentSpecs), '.', '_');

if ~isfield(c, f)
    c.(f) = getstate(this.CurrentSpecs);
    
    this.CapturedState = c;
end

notify(this, 'FaceChanged')

% [EOF]

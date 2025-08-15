function minphase = set_minphase(this, minphase)
%SET_MINPHASE   PreSet function for the 'minphase' property.

%   Copyright 1999-2017 The MathWorks, Inc.

if isfdtbxinstalled
    if isminorderodd(this)
        error(message('signal:fmethod:abstracteqrip:set_minphase:InvalidSpecificationOddOrder'));
    end
    this.privMinPhase = minphase;
else
    error(message('signal:fmethod:abstracteqrip:set_minphase:InvalidSpecificationNoLicense', '''Minimum phase'''));
end

% [EOF]

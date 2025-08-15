function maxphase = set_maxphase(this, maxphase)
%SET_MAXPHASE   PreSet function for the 'maxphase' property.

%   Copyright 1999-2017 The MathWorks, Inc.

if isfdtbxinstalled
    if isminorderodd(this)
        error(message('signal:fmethod:abstracteqrip:set_maxphase:InvalidSpecificationOddOrder'));
    end
    thisset_maxphase(this, maxphase);
else
    error(message('signal:fmethod:abstracteqrip:set_maxphase:InvalidSpecificationNoLicense', '''Maximum phase'''));
end

% [EOF]

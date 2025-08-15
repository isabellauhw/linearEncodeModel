function matchexactly = set_matchexactly(this, matchexactly)
%SET_MATCHEXACTLY   PreSet function for the 'matchexactly' property.

%   Copyright 1999-2015 The MathWorks, Inc.

error(message('signal:fmethod:abstractbutter:set_matchexactly:invalidSpecification'));

this.privMatchExactly = matchexactly;

% [EOF]

function thisSupportedStructs = addsysobjdesignopt(this)
%ADDSYSOBJDESIGNOPT Add SystemObject design option if it applies
%
% thisSupportedStructs is the list of supported structures for the method
% at hand.

%   Copyright 1999-2015 The MathWorks, Inc.

% Get the supported structures for the fmethod at hand.
thisSupportedStructs = getvalidsysobjstructures(this);

% If thisSupportedStructs is not empty then it means that at least one
% structure supports a System object conversion, so we need to add the
% SystemObject design option.
if ~isempty(thisSupportedStructs) && isfdtbxinstalled && ~isprop(this,'SystemObject')
    p = addprop(this,'SystemObject');
    p.AbortSet = false;
    p.NonCopyable = true;
    p.Transient = true;
    this.SystemObject = false;

end

% [EOF]

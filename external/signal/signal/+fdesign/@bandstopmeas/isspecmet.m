function b = isspecmet(this, hfdesign)
%ISSPECMET   True if the object is specmet.

%   Copyright 2005 The MathWorks, Inc.

if nargin < 2
    %hfdesign = get(this, 'SpecificationType');
    hfdesign = this.Specification;
end

specs = measureinfo(hfdesign);

if ((isempty(specs.Apass1) || this.Apass1 <= specs.Apass1) && ...
    (isempty(specs.Astop)  || this.Astop  >= specs.Astop) && ...
    (isempty(specs.Apass2) || this.Apass2 <= specs.Apass2))
    b = true;
else
    b = false;
end

% [EOF]

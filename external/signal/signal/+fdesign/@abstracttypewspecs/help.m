function help(this, designmethod)
%HELP   Provide help for the specified design method.

%   Copyright 2005-2018 The MathWorks, Inc.

if nargin > 1
    designmethod = convertStringsToChars(designmethod);
end

if nargin < 2
    help('fdesign');
elseif isdesignmethod(this, designmethod)
    help(this.CurrentSpecs, designmethod);
else
    error(message('signal:fdesign:abstracttypewspecs:help:invalidDesignMethod', designmethod));
end

% [EOF]

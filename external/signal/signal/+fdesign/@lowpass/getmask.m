function [F, A] = getmask(this, fcns, ~, specs)
%GETMASK   Get the mask.

%   Copyright 2005-2017 The MathWorks, Inc.

% If the specs were not passed in or are [], use the design specifications.
if nargin < 4 || isempty(specs)
    specs = getspecs(this.CurrentSpecs);
    fpass = specs.Fpass;
    fstop = specs.Fstop;
else
    fpass = specs.Fpass;
    fstop = specs.Fstop;
    if ~specs.NormalizedFrequency
        fpass = fpass/specs.Fs*2;
        fstop = fstop/specs.Fs*2;
    end
end

if isempty(fpass)
    fpass = NaN;
end
if isempty(fstop)
    fstop = NaN;
end

% The frequency vector is always the same.
F = [1 fpass fpass eps eps fstop fstop 1]*fcns.getfs()/2;

A = fcns.gethighlow(specs);

% [EOF]

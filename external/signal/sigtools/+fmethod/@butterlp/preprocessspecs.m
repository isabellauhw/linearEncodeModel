function specs = preprocessspecs(this, specs)
%PREPROCESSSPECS   

%   Copyright 1999-2015 The MathWorks, Inc.

if isa(specs, 'fspecs.lpcutoff')
    if specs.NormalizedFrequency
        specs = fspecs.lp3db(specs.FilterOrder, specs.Fcutoff);
    else
        specs = fspecs.lp3db(specs.FilterOrder, specs.Fcutoff, specs.Fs);
    end
end

% [EOF]

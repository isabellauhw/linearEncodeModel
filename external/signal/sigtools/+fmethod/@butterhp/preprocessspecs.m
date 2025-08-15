function specs = preprocessspecs(this, specs)
%PREPROCESSSPECS   Processes the specifications

%   Copyright 1999-2015 The MathWorks, Inc.

if isa(specs, 'fspecs.hpcutoff')
    if specs.NormalizedFrequency
        specs = fspecs.hp3db(specs.FilterOrder, specs.Fcutoff);
    else
        specs = fspecs.hp3db(specs.FilterOrder, specs.Fcutoff, specs.Fs);
    end
end

% [EOF]

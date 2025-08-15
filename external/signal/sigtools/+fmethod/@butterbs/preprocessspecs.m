function specs = preprocessspecs(this, specs)
%PREPROCESSSPECS   Process the specifications

%   Copyright 1999-2015 The MathWorks, Inc.

if isa(specs, 'fspecs.bscutoff')
    if specs.NormalizedFrequency
        specs = fspecs.bs3db(specs.FilterOrder, specs.Fcutoff1, specs.Fcutoff2);
    else
        specs = fspecs.bs3db(specs.FilterOrder, specs.Fcutoff1, specs.Fcutoff2, specs.Fs);
    end
end


% [EOF]

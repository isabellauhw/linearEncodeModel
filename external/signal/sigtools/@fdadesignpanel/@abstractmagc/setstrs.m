function [strs, lbls] = setstrs(h)
%SETSTRS Return the strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Get current magunits
magOpts = set(h,'MagUnits');
props   = allprops(h);

cb = get(h, 'ConstrainedBands');

strs = props(1:end/4);

for indx = 1:length(cb)
    cbi = cb(indx);
    if cbi <= length(strs)
        switch h.magUnits
            case magOpts{1}
                strs{cbi} = props{end/4+cbi};
            case magOpts{2}
                strs{cbi} = props{2*end/4+cbi};
            case magOpts{3}
                strs{cbi} = props{3*end/4+cbi};
        end
    end
end

lbls = cell(size(strs));
for indx = 1:length(strs)
    lbls{indx} = [strs{indx} ':'];
end

% [EOF]

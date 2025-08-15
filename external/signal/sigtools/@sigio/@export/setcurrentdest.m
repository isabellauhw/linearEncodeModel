function out = setcurrentdest(this, out)
%SETCURRENTDEST SetFunction for CurrentDestination property.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

ad = get(this,'AvailableDestinations');
ac = get(this,'AvailableConstructors');

if  any([isempty(ad) isempty(ac)])
    return;
else
    % Try to find the destination string
    idx = strmatch(lower(out),lower(ad));
    if isempty(idx) 
        idx = 1; 
        warning(message('signal:sigio:Export:setcurrentdest:destinationNotAvail', out));
    end
    out = ad{idx};
end

% Set the appropriate destination object
setdestobj(this, ac{idx});

this.isapplied = false;

% [EOF]

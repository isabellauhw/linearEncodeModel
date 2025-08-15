function out = setavaildes(h,out)
%SETAVAILDES SetFunction for AvailableDestinations property.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

ac = get(h,'AvailableConstructors');

if  any([isempty(out) isempty(ac)])
    return;
else
    set(h,'privAvailableDestinations',out);
    
    % Get current destination
    cdes = get(h,'CurrentDestination');
    if isempty(cdes)
        idx = 1;
    else
        idx = strmatch(lower(cdes),lower(out));
        if isempty(idx), idx = 1; end
    end
    
    set(h,'CurrentDestination',out{idx}); 
end

% If the object is already set don't do anything
if ~strcmpi(class(h.Destination), ac{idx})
    
    % Set the appropriate destination object
    setdestobj(h, ac{idx});
end

out = [];

% [EOF]

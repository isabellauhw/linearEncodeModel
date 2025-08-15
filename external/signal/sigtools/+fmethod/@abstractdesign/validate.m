function validate(h,specs)
%VALIDATE   Perform algorithm specific spec. validation.

%   Copyright 1999-2015 The MathWorks, Inc.

% Populate defaults
isvalid = true;

vso = validspecobj(h);

% Handle the cell of strings, i.e. multiple valid specification objects.
if iscellstr(vso)
    for indx = 1:length(vso)
        if isa(specs, vso{indx})
            isvalid(indx) = true;
        else
            isvalid(indx) = false;
        end
    end
    isvalid = any(isvalid);
else
    isvalid = isa(specs, vso);
end

if ~isvalid
    error(message('signal:fmethod:abstractdesign:validate:invalidSpec', 'FSPECS', validspecobj( h )));
end

% [EOF]

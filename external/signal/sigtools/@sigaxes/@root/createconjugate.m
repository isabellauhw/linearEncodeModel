function varargout = createconjugate(h, hPZ)
%CREATECONJUGATE Create a conjugate

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if strcmpi(h.Conjugate, 'on')
    varargout = {[]};
    return;
end

hUsed = {[]};
for indx = 1:length(h)
    
    % If we get a vector of PZ's see if any of them are the complex conjugate.
    if nargin > 1
        hUsed{indx} = find(setdiff(hPZ, h(indx)), '-isa', class(h(indx)), ...
            'Real', h(indx).Real, 'Imaginary', -h(indx).Imaginary);
    end
end
set(h, 'Conjugate', 'On');

% Return any of the passed in Roots that were used.
if nargout
    varargout = {[hUsed{:}]};
end

% [EOF]

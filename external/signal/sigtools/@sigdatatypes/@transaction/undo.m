function undo(h)
%UNDO   Undo the transaction.

%   Author(s): D. Foti & J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if ~isempty(h.Property)
    try
        set(h.Object, fliplr(h.Property), fliplr(h.OldValue));
    catch ME
        if ~strcmp(ME.identifier, 'MATLAB:class:SetDenied')
            throwAsCaller(ME);
        end
    end
end


function a = array(this)
%ARRAY Convert the vector to an array
%   H.ARRAY Converts the vector to an array, if possible.  If we have mixed
%   numbers and characters, the numbers will be converted to characters.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

try,
    a = [this.Data{:}];
catch
    error(message('signal:sigutils:vector:array:ValuesNotSameType'));
end

% [EOF]

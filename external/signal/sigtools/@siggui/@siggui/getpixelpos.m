function pos = getpixelpos(this, field, varargin)
%GETPIXELPOS Get the position in pixel units.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,inf);

if ischar(field)
    field = this.Handles.(field);
    for indx = 1:length(varargin)
        if ischar(varargin{indx})
            field = field.(varargin{indx});
        else
            field = field(varargin{indx});
        end
    end
end

pos = getpixelposition(field);

% [EOF]

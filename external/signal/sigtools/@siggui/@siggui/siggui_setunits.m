function siggui_setunits(this, units)
%SIGGUI_SETUNITS Sets all units in the frame

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

narginchk(2,2);

if isempty(this.Container) || ~ishghandle(this.Container)

    hvec = handles2vector(this);

    if ~isempty(hvec)
        % Remove all objects that do not have a Units property.
        hvec(~isprop(hvec, 'Units')) = [];
        
        % Remove Text objects.  Do not set their units.
        hvec(ishghandle(hvec, 'text')) = [];
        
        set(hvec,'Units',units);
    end
else
    set(this.Container, 'Units', units)
end

% [EOF]

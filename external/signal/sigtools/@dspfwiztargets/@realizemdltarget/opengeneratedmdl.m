function opengeneratedmdl(this)
%OPENGENERATEDMDL   

%   Author(s): V. Pellissier
%   Copyright 2006-2008 The MathWorks, Inc.

sys     = this.system;
slindex = strfind(sys,'/');

try
    if isMaskOff(this)
        % Open only unmasked subsystems
        open_system(sys(1:slindex(end)-1));
    end
catch ME %#ok<NASGU> 

    % If there is no mask, open system
    open_system(sys(1:slindex(end)-1));
end
% [EOF]

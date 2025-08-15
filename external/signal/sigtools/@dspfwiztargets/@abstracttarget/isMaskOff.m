function maskIsOff = isMaskOff(this)
%ISMASKOFF True if the object is MaskOff

%   Copyright 2010 The MathWorks, Inc.

syspath = this.system;

% Remove the block name.  We are going to open the parent.
seps = strfind(syspath, '/');

maskIsOff = local_isMaskOff(syspath(1:seps(end)-1));

% -------------------------------------------------------------------------
function maskIsOff = local_isMaskOff(syspath)

seps = strfind(syspath,'/');

if isempty(seps)
    
    % If there is no '/' character in the path, then we are at the top
    % level which means it cannot be masked.
    maskIsOff = true;
elseif strncmpi(get_param(syspath,'mask'),'on',2)
    
    % If this path says the mask is on, return false.
    maskIsOff = false;
else
    
    % If this path says the mask is off, check parent systems.  We do not
    % want to open the system if there are any masked subsystems in our
    % ancestry.
    maskIsOff = local_isMaskOff(syspath(1:seps(end)-1));
end


% [EOF]

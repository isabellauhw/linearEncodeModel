function flag = isdynpropenab(h,propname)
%ISDYNPROPENAB True if dynamic property is enabled (set/get are on).
%   ISDYNPROPENAB(H, PROP) True if the dynamic property PROP in the object
%   H is enabled, i.e. PublicGet and PublicSet are on.
    
%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

p = findprop(h,propname);

% Check if the property found was due to partial match
if ~strcmpi(propname,p.Name)
    error(message('signal:isdynpropenab:NotSupported'));
end

if isobject(h)
  flag = strcmpi(p.GetAccess,'public') && strcmpi(p.SetAccess,'public');  
else
  flag = strcmpi(p.AccessFlags.PublicGet,'on') && ...
        strcmpi(p.AccessFlags.PublicSet,'on');
end

% [EOF]

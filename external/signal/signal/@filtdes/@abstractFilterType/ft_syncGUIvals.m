function ft_syncGUIvals(h,d,arrayh)
%SYNCGUIVALS Sync values from frames.
%
%   Inputs:
%       h - handle to this object
%       d - handle to design method
%       arrayh - array of handles to frames


%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

specObjs = get(h,'specobjs');

for n = 1:length(specObjs)
	syncGUIvals(specObjs(n),d,arrayh);
end




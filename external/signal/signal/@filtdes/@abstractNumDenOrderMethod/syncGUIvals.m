function syncGUIvals(h,arrayh)
%SYNCGUIVALS Sync values from frames.
%
%   Inputs:
%       h - handle to this object   
%       arrayh - array of handles to frames

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.

narginchk(2,2);

% Call the super's method
super_syncGUIvals(h,arrayh);


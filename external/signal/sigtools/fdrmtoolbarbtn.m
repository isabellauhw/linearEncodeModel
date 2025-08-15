function fdrmtoolbarbtn(hndl)
%FDRMTOOLBARBTN Remove a toolbar button from the Filter Design & Analysis Tool (FDATool).
%   FDRMTOOLBARBTN(HNDL) deletes the toolbar button with handle HNDL.  HNDL can be a 
%   vector of handles.
%
%   EXAMPLE:
%   % Add a button to the toolbar
%   load mwtoolbaricons;
%   h = fdatool;
%   hndl = fdaddtoolbarbtn(h,3,{'TOGGLE'},{help});
%
%   % Remove the toolbar button from FDATool
%   fdrmtoolbarbtn(hndl); 
%
%   See also FDADDTOOLBARBTN, DELETE.

%   Author(s): P. Costa 
%   Copyright 1988-2002 The MathWorks, Inc.

narginchk(1,1);
delete(hndl);

% [EOF]

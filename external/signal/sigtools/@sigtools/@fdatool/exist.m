function status = exist(hFDA)
%EXIST Determines if FDATool is still open
%   EXIST(HFDA) determines if the FDATool associated with HFDA is 
%   still open.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

narginchk(1,1);

hFig = get(hFDA,'FigureHandle');
status = ishghandle(hFig);

% [EOF]

function thisrender(h, hFig, pos)
%THISRENDER Render the destination options frame.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

if nargin < 3 , pos =[]; end
if nargin < 2 , hFig = gcf; end

abstractxdwvars_thisrender(h,pos);

% [EOF]

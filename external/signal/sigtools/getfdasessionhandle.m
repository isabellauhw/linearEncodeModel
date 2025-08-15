function h = getfdasessionhandle(hFig)
%GETFDASESSIONHANDLE  Return the handle to an FDATool session.

%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

if isempty(hFig) || ~ishghandle(hFig)
    h = [];
else
    h = siggetappdata(hFig, 'fdatool', 'handle');
end

% [EOF]

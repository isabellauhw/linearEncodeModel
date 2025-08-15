function lvh = construct_mf(h, varargin)
%CONSTRUCT_MF  Construct a freq frame

%   Copyright 1988-2003 The MathWorks, Inc.

lvh = siggui.labelsandvalues(varargin{:});
addcomponent(h, lvh);

% [EOF]

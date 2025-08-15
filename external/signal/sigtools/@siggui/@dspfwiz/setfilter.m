function out = setfilter(hObj, out)
%FILTER_LISTENER Listener to the filter property

%   Copyright 1995-2017 The MathWorks, Inc.

if ~isempty(out) && ~isa(out, 'dfilt.basefilter')
    error(message('signal:siggui:dspfwiz:setfilter:InvalidParam'));
end

% Construct a new parameter object with the new filter
parm = dspfwiz.parameter(out);

set(hObj, 'Parameter', parm);

% [EOF]

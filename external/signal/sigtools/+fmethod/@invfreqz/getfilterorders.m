function [NumOrder, DenOrder] = getfilterorders(this,hspecs)
%GETFILTERORDERS   Get the filterorders.

%   Copyright 1999-2017 The MathWorks, Inc.

NumOrder  = hspecs.FilterOrder;
DenOrder = hspecs.FilterOrder;

% [EOF]

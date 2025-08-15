function y = isIrregular(tv)
% Check regularity of time vector intervals.

%   Copyright 2017-2019 The MathWorks, Inc.
%#codegen

err = max(abs(tv(:).'-linspace(tv(1),tv(end),numel(tv)))./max(abs(tv(:))));
y = err > 3*eps(class(tv));
end

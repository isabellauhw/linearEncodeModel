function [effectiveFs, isIrregular] = getEffectiveFs(tv,isIrregular)
% Check regularity of time vector intervals.

%   Copyright 2017-2019 The MathWorks, Inc.
%#codegen
if nargin<2
    isIrregular = signal.internal.utilities.isIrregular(tv);
end
% The mean has better numerical precision than the median so if the vector
% is uniformly sampled then use mean to get the average sample rate.

if isIrregular
    if ~signal.internal.validateNonUniformTimeValues(tv)
        if coder.target('MATLAB')
            error(message('signal:utilities:utilities:TimeValuesIrregular'));
        else
            coder.internal.error('signal:utilities:utilities:TimeValuesIrregular');
        end
    end
    effectiveFs = 1/median(diff(tv(:)));
else
    effectiveFs = 1/mean(diff(tv(:)));
end
effectiveFs = abs(effectiveFs); % time vector could be descending in values

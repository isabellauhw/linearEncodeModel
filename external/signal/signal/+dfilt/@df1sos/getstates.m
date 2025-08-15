function zh = getstates(Hd,dummy)
%GETSTATES Overloaded get for the States property.

% This should be a private method

%   Author: R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

zh = Hd.HiddenStates;

if ~isempty(zh)
    % Reshape to what users see
    zh.Numerator = reshape(zh.Numerator, 2, numel(zh.Numerator)/2);
    zh.Denominator = reshape(zh.Denominator, 2, numel(zh.Denominator)/2);
end

% [EOF]

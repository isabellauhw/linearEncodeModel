function fs = evaluatefs(str)
%EVALUATEFS  Evaluate sampling frequency input.
%   FS = EVALUATEFS(STR) evaluates user input string STR and returns
%   scalar FS.  An error message is given if FS is negative, zero,
%   not numeric, or not a scalar.

%   Author: T. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.

[fs,errmsg,mssgObj] = evaluatevars(str);
if ~isempty(errmsg), error(mssgObj); end
if ~isnumeric(fs)
  error(message('signal:evaluatefs:MustBeNumeric'))
end
if isempty(fs) | length(fs)>1
  error(message('signal:evaluatefs:InvalidDimensions'));
end
if fs<=0
  error(message('signal:evaluatefs:MustBePositive'))
end

% [EOF] evaluatefs.m

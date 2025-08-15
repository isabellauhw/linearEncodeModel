function test = test(this, test)
%TEST Tests the MATLAB code by running it.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.

if nargin < 2, test = testinit(class(this)); end

try
    eval(this.string);
    test = qeverify(test, {true, true});
catch ME
    disp(sprintf('MATLAB code errored out with : %s', ME.message));
    test = qeverify(test, {true, false});
end

% [EOF]

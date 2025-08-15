function [s,g] = mybilineardesign(h,has,c)
%MYBILINEARDESIGN   

%   Copyright 1999-2017 The MathWorks, Inc.

% Design analog filter
N = has.FilterOrder;
if rem(N,2) == 1
    error(message('signal:fmethod:ellipbpfstop:mybilineardesign:oddOrder'));
end
if rem(N,4) == 0 && any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'}))
    error(message('signal:fmethod:ellipbpfstop:mybilineardesign:twiceEvenOrder'));
end

wp = has.Wpass;
ws = has.Wstop;
rp = has.Apass;
[sa,ga] = alpfstop(h,N/2,wp,ws,rp); % Halve the order

[s,g] = thisbilineardesign(h,N,sa,ga,c);

% [EOF]

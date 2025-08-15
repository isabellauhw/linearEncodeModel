function [s,g] = mybilineardesign(h,has,c)
%MYBILINEARDESIGN   

%   Copyright 1999-2017 The MathWorks, Inc.

% Design analog filter
N = has.FilterOrder;
if rem(N,2) == 1
    error(message('signal:fmethod:ellipbsastop:mybilineardesign:oddOrder'));
end
if rem(N,4) == 0 && any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'}))
    error(message('signal:fmethod:ellipbsastop:mybilineardesign:twiceEvenOrder'));
end

wp = has.Wpass;
rp = has.Apass;
rs = has.Astop;
[sa,ga] = alpastop(h,N/2,wp,rp,rs); % Halve the order

[s,g] = thisbilineardesign(h,N,sa,ga,c);

% [EOF]

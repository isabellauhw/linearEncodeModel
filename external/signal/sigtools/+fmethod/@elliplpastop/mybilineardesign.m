function [s,g] = mybilineardesign(h,has,c)
%MYBILINEARDESIGN   

%   Copyright 1999-2017 The MathWorks, Inc.

% Design analog filter
N = has.FilterOrder;
if rem(N,2) == 0 && any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'}))
    error(message('signal:fmethod:elliplpastop:mybilineardesign:evenOrder'));
end

wp = has.Wpass;
rp = has.Apass;
rs = has.Astop;
[sa,ga] = alpastop(h,N,wp,rp,rs);

[s,g] = thisbilineardesign(h,N,sa,ga);

% [EOF]

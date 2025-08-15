function [s,g] = mybilineardesign(h,has,c)
%MYBILINEARDESIGN   

%   Copyright 1999-2017 The MathWorks, Inc.

% Design analog filter
N = has.FilterOrder;
if rem(N,2) == 0 && any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'}))
    error(message('signal:fmethod:elliplpfstop:mybilineardesign:evenOrder'));
end

wp = has.Wpass;
ws = has.Wstop;
rp = has.Apass;
[sa,ga] = alpfstop(h,N,wp,ws,rp);

[s,g] = thisbilineardesign(h,N,sa,ga);

% [EOF]

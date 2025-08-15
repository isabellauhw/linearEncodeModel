function Ha = design(h,hs)
%DESIGN   

%   Copyright 1999-2015 The MathWorks, Inc.


Ha = sosminacheby1lp(h,hs);

%--------------------------------------------------------------------------
function Ha = sosminacheby1lp(h,hasmin)
%SOSMINACHEBY1LP Lowpass analog Type I Chebyshev filter second-order sections.
%   Ha = SOSMINACHEBY1LP(Wp,Ws,Rp,Rs) designs a minimum-order lowpass
%   analog type I Chebyshev filter that meets the specifications Wp, Ws, Rp, and
%   Rs.
%
%   Ha = SOSMINACHEBY1LP(Wp,Ws,Rp,Rs,EXORD) specifies a string on how to
%   use any excess order resulting from rounding the minimum-order required
%   to an integer. EXORD can be one of: 'passband' to meet the passband
%   specification exactly (and exceed the stopband specification) or 'stopband' to
%   meet the stopband specification exactly (and exceed the passband
%   specification). EXORD defaults to 'stopband'.


% Compute minimum order
has = tospecifyord(h,hasmin);

hlp = fmethod.cheby1alp;
Ha = design(hlp,has);

% [EOF]

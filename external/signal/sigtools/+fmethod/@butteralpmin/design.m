function Ha = design(h,hs)
%DESIGN   

%   Copyright 1999-2015 The MathWorks, Inc.

Ha = sosminabutterlp(h,hs);

%--------------------------------------------------------------------------
function Ha = sosminabutterlp(h,hasmin)
%SOSMINABUTTERLP Lowpass analog Butterworth filter second-order sections.
%   [S,G] = SOSMINABUTTERLP(Wp,Ws,Rp,Rs) designs a minimum-order lowpass
%   analog Butterworth filter that meets the specifications Wp, Ws, Rp, and
%   Rs.
%
%   [S,G] = SOSMINABUTTLP(Wp,Ws,Rp,Rs,EXORD) specifies a string on how to
%   use any excess order resulting from rounding the minimum-order required
%   to an integer. EXORD can be one of: 'passband' to meet the passband
%   specification exactly (and exceed the stopband specification) or 'stopband' to
%   meet the stopband specification exactly (and exceed the passband
%   specification). EXORD defaults to 'stopband'.


% Compute order and cutoff frequency
has = tospecifyord(h,hasmin);

% Design filter
hlp = fmethod.butteralp;
Ha = design(hlp,has);

% [EOF]

function [sos,g,Astop] = alpfstop(h,N,Wp,Ws,Apass)
%ALPFSTOP   

%   Copyright 1999-2015 The MathWorks, Inc.

% Compute cutoff
Wc=sqrt(Wp*Ws);

% Design prototype
[sos,g,Astop] = apspecord(h,N,Wp/Wc,Apass); % Astop is a measurement

sos = stosbywc(h,sos,Wc);

% [EOF]

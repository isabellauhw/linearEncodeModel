function sos = stosbywc(h,sos,Wc)
%STOSBYWC   

%   Copyright 1999-2015 The MathWorks, Inc.

% Make transformation s -> s/Wc
sos(:,[1,4])=sos(:,[1,4])/Wc^2;

sos(:,5)=sos(:,5)/Wc;


% [EOF]

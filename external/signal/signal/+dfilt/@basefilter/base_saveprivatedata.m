function s = base_saveprivatedata(this)
%BASE_SAVEPRIVATEDATA   

%   Copyright 2004-2015 The MathWorks, Inc.

s.privdesignmethod = this.privdesignmethod;

% For backwards compatibility, there is legacy load code that checks if
% privdesignmethod is a field of s and then reads designmethod, so we need
% to make sure both fields are added to the saved structure. 
s.designmethod = s.privdesignmethod; 

% [EOF]

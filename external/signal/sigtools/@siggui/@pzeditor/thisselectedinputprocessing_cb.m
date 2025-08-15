function thisselectedinputprocessing_cb(this)
%THISSELECTEDINPUTPROCESSING_CB 

%   Copyright 2011 The MathWorks, Inc.

send(this, 'NewFilter', handle.EventData(this, 'NewFilter'));

% [EOF]
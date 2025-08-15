function thisselectedinputprocessing_cb(this)
%THISSELECTEDINPUTPROCESSING_CB

%   Copyright 2011-2017 The MathWorks, Inc.

% Fire the listener so that the GUI is updated with the new input
% processing option. Send empty data since we do not want to update the
% filter. 
if get(this, 'isImported')
  data.filter = [];
  send(this, 'FilterGenerated', sigdatatypes.sigeventdata(this, 'FilterGenerated', data));
end
% [EOF]

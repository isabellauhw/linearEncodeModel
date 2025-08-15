function thisselectedinputprocessing_cb(this)
%THISSELECTEDINPUTPROCESSING_CB

%   Copyright 2011 The MathWorks, Inc.

% Fire the listener so that the GUI is updated with the new input
% processing option. Send empty data since we do not want to update the
% filter or the mcode. Fire the listener only when a filter is designed.
% Otherwise, the GUI will be updated when the user clicks the 'Design
% Filter' button.
if this.IsDesigned
  data.filter = [];
  data.mcode = [];
  send(this, 'FilterDesigned', sigdatatypes.sigeventdata(this, 'FilterDesigned', data));
end

% [EOF]
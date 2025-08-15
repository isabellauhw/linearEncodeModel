function [status, errmsg] = dialogApplycallback(this)
%DIALOGAPPLYCALLBACK   Construct a PARAMDLG object.

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.

status = 1;
errmsg = '';
send(this,'DialogApply', handle.EventData(this, 'DialogApply'));

% [EOF]

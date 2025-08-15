function csh_str = getcshstring(hObj)
%GETCSHSTRING  Returns the string for context sensitive help

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.

SigguiClass = class(hObj);

BeginIndx = strfind(SigguiClass, '.');
EndIndx = strfind(SigguiClass, 'opt');

ObjClass = SigguiClass(BeginIndx + 1 : EndIndx - 1);

csh_str = ['fdatool_',ObjClass,'_options_frame'];

% [EOF]

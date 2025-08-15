function outstr = appstr(instr,app)
% APPSTR  Append string to callback string.
%   STR1 = APPSTR(STR,APP) appends the string APP to the string
%   STR.  If STR has greater than length 0, and no semicolon is
%   found in suffix (at the end of STR followed by spaces), a 
%   comma is appended first.
%   Copyright 1988-2017 The MathWorks, Inc.

%   T. Krauss  11/21/94

if isempty(instr)
	outstr = app;
else
	ind = length(instr);
	sep = ' ';   % default separator
	while (instr(ind)==' ')
		ind = ind-1;
	end
	if instr(ind)~=';'
		sep = ',';   % separator
	end
	outstr = [instr sep app];
end

function flag = iscalledbydspblks(this)
%ISCALLEDBYDSPBLKS 

%   Copyright 2011 The MathWorks, Inc.

try
  prt = get(this.Parent, 'UserData');
  flag = prt.flags.calledby.dspblks > 0 ;
catch %#ok<CTCH>
  flag = false;
end
  

function inp = setfrom(Ip,From)
%inport Constructor for this class.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.

narginchk(1,2);

if nargin > 0 
    inp=Ip;
end

if nargin > 1
    inp.from = From;
end

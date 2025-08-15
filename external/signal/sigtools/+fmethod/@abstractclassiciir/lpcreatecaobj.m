function Hd = lpcreatecaobj(this,struct,branch1,branch2)
%LPCREATECAOBJ   

%   Copyright 1999-2015 The MathWorks, Inc.

ha = feval(['dfilt.' struct], branch1{:});
hb = feval(['dfilt.' struct], branch2{:});
hp = parallel(ha,hb);
Hd = cascade(hp,dfilt.scalar(.5));

% [EOF]

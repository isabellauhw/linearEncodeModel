function Hd = hpcreatecaobj(this,struct,branch1,branch2)
%HPCREATECAOBJ

%   Copyright 1999-2017 The MathWorks, Inc.

ha = feval(['dfilt.' struct], branch1{:});
hb = feval(['dfilt.' struct], branch2{:});

m = 2*sum([length(branch1),length(branch2)]);
if rem(m,4) == 2
    hp = parallel(cascade(dfilt.scalar(-1),hb),ha);
elseif rem(m,4) == 0
    hp = parallel(cascade(dfilt.scalar(-1),ha),hb);
end
Hd = cascade(hp,dfilt.scalar(.5));

% [EOF]

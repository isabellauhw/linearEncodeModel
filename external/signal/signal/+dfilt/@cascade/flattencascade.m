function Hflat = flattencascade(this)
%FLATTENCASCADE Remove cascades of cascades

%   Copyright 2008 The MathWorks, Inc.

N = nstages(this);
Hflat = [];
for i=1:N,
    Hflat = flatcascade(this.Stage(i),Hflat);
end
Hflat = cascade(Hflat(:));

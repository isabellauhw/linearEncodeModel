function ic = getinitialconditions(Hd)
%GETINITIALCONDITIONS Get the initial conditions

%   Copyright 2009-2017 The MathWorks, Inc.

s    = double(Hd.States);
nsts  = size(Hd.sosMatrix,1)*2;
nchan = numel(s)/nsts;
ic    = reshape(s,nsts,nchan);

% [EOF]

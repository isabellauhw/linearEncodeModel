function Hflat = flatcascade(this,Hflat)
%THISFLATCASCADE Add singleton to the flat list of filters Hflat 

%   Copyright 2008 The MathWorks, Inc.
if isa(this,'dfilt.cascade')
    Hflat = thisflatcascade(this,Hflat);
else
    Hflat = [Hflat;this];
end
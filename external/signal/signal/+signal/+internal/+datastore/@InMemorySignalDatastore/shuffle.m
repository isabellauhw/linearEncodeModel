function [sdsOut,rndIdxes] = shuffle(obj)
%SHUFFLE Shuffles the files in the datastore
%For internal use only. It may be removed.
%
%   SDSOUT = SHUFFLE(SDS) creates a deep copy of the input datastore and
%   shuffles the members using randperm, resulting in the datastore SDSOUT.

%   Copyright 2019 The MathWorks, Inc.
  
  rndIdxes = randperm(numobservations(obj));
  sdsOut = subset(obj,rndIdxes);  
end

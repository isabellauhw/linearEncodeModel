function [dsOut,rndIdxes] = shuffle(obj)
%SHUFFLE Shuffles the files in the datastore
%For internal use only. It may be removed.
%
%   SDSOUT = SHUFFLE(SDS) creates a deep copy of the input datastore and
%   shuffles the files using randperm, resulting in the datastore SDSOUT.

%   Copyright 2019 The MathWorks, Inc.
try
    dsOut = copy(obj);
    rndIdxes = randperm(dsOut.NumFiles);
    % set ReadFcn to the parent datastore and initialize with only specific
    % indexes of files.
    initWithIndices(dsOut, rndIdxes);
catch e
    throw(e)
end
end

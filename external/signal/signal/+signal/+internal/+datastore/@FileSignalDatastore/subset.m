function sds2 = subset(obj,indices)
%SUBSET Creates a datastore with a subset of files
%For internal use only. It may be removed.
%
%   SDSOUT = SUBSET(SDS, indices) returns a signal file datastore, SDS2,
%   based on a subset of the files in SDS. indices can be:
%   * A vector containing the indices of the files to be included in SDS2
%   * A logical vector of same length as the number of files in SDS 
%     (true indicates the corresponding file will be in SDS2)

%   Copyright 2019 The MathWorks, Inc.

sds2 = copy(obj);
sds2.Files = sds2.Files(indices);

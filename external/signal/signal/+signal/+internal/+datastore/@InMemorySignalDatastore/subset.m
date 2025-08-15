function sdsOut = subset(obj,indices)
%SUBSET Creates a datastore with a subset of members
%For internal use only. It may be removed.
%
% SDSOUT = SUBSET(SDS,indices) returns an signal in-memory datastore,
% SDSOUT, based on a subset of the members in SDS. indices can be:
% * A vector containing the indices of the members to be included in SDSOUT
% * A logical vector of same length as the number of members in SDS 
%   (true indicates the corresponding member will be in sfds2)

%   Copyright 2019 The MathWorks, Inc.

sdsOut = copy(obj);
sdsOut.pMembers = sdsOut.pMembers(indices);
sdsOut.pMemberNames = sdsOut.pMemberNames(indices);

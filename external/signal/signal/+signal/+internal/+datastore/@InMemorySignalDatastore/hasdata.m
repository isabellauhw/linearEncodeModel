function tf = hasdata(obj)
%HASDATA Returns true if there is more data in the datastore
%For internal use only. It may be removed.
%
% TF = HASDATA(SDS) returns a logical scalar indicating availability of
% data.

%   Copyright 2019 The MathWorks, Inc.

tf = obj.pCurrentMemberIndex < numobservations(obj);

end

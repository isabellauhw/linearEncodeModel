function [data, infoStruct] = read(obj)
%READ Reads the next consecutive signal member
%For internal use only. It may be removed.
%
%   [DATA,INFO] = READ(SDS) returns signal extracted from the datastore, as
%   well as INFO structure with signal time information.

%   Copyright 2019 The MathWorks, Inc.

if ~hasdata(obj)
    % Error if no more files are available to be read.
    error(message('signal:signalDatastore:InMemorySignalDatastore:NoMoreData'));
end

if obj.ReadSize == 1
    moveToNextMember(obj);
    
    data = obj.Members{obj.pCurrentMemberIndex};
    
    infoStruct.MemberName = string(obj.pNextMember);
    infoStruct.ElementIndex = obj.pCurrentMemberIndex;
else
    remainingNumMembers = numobservations(obj) - obj.pCurrentMemberIndex;
    numReads = min(remainingNumMembers, obj.ReadSize);
    data = cell(numReads,1);
    infoStruct = [];
    for idx = 1:numReads
        moveToNextMember(obj);
        data{idx} = obj.Members{obj.pCurrentMemberIndex};
        infoStructTmp.MemberName = string(obj.pNextMember);
        infoStructTmp.ElementIndex = obj.pCurrentMemberIndex;
        infoStruct = [infoStruct; infoStructTmp]; %#ok<AGROW>
    end
end
function subds = partition(obj, partitionStrategy, partitionIndex)
%PARTITION Returns a new datastore that is a single partitioned portion of 
% the original datastore
%
%   SUBDS = PARTITION(SDS,NUMPARTITIONS,INDEX) partitions sds into
%   NUMPARTITIONS parts and returns the partitioned Datastore, SUBDS,
%   corresponding to INDEX. Use the NUMPARTITIONS function to estimate a
%   reasonable value for NUMPARTITIONS.
%
%   SUBDS = PARTITION(SDS,'Members',INDEX) partitions sds by members in the
%   'Members' property and returns the partition corresponding to INDEX.
%
%   SUBDS = PARTITION(SDS,'Members',MEMBERNAME) partitions sds by members
%   and returns the partition corresponding to MEMBERNAME.

%   Copyright 2019 The MathWorks, Inc.

narginchk(3,3)

partitionStrategy = convertStringsToChars(partitionStrategy);
partitionIndex = convertStringsToChars(partitionIndex);

if isnumeric(partitionStrategy) && isnumeric(partitionIndex)
    %SUBDS = PARTITION(SDS,NUMPARTITIONS,INDEX)
    numPartitions = partitionStrategy;
    validateattributes(numPartitions, {'numeric'}, {'scalar','integer','positive','nonempty'}, 'partition', 'NUMPARTITIONS');
    validateattributes(partitionIndex, {'numeric'}, {'scalar','integer','positive','nonempty'}, 'partition', 'INDEX');    
    if partitionIndex > numPartitions
        error(message('signal:signalDatastore:InMemorySignalDatastore:IndexExceedsPartitions'));
    end
    
    subds = copy(obj);
    numMembers = numobservations(subds);
    r = (0:numMembers - 1) / numMembers;
    boxIndices = floor(numPartitions * r) + 1;
    memberIndices = find(boxIndices == partitionIndex);
     
    subds.pMembers = obj.pMembers(memberIndices);
    subds.pMemberNames = obj.pMemberNames(memberIndices);
    
elseif ischar(partitionStrategy) && string(partitionStrategy) == "Members" && isnumeric(partitionIndex)
    validateattributes(partitionIndex, {'numeric'}, {'scalar','integer','positive','nonempty'}, 'partition', 'INDEX');
    memberIndex = partitionIndex;
    if memberIndex > numobservations(obj)
        error(message('signal:signalDatastore:InMemorySignalDatastore:IndexExceedsNumMembers'));
    end        
    subds = copy(obj);
    subds.pMembers = obj.pMembers(partitionIndex);
    subds.pMemberNames = obj.pMemberNames(partitionIndex);
    
elseif ischar(partitionStrategy) && string(partitionStrategy) == "Members" && ischar(partitionIndex)
    memberName = partitionIndex;
    memberNameIdx = ismember(obj.pMemberNames,memberName);
    if sum(memberNameIdx) > 1
        error(message('signal:signalDatastore:InMemorySignalDatastore:DuplicateMembers'));
    end
    if ~any(memberNameIdx)
        error(message('signal:signalDatastore:InMemorySignalDatastore:MemberNameNotFound'));
    end
    subds = copy(obj);
    subds.pMembers = obj.pMembers(memberNameIdx);
    subds.pMemberNames = obj.pMemberNames(memberNameIdx);
else
    error(message('signal:signalDatastore:InMemorySignalDatastore:InvalidPartitionInputs'));
end
end
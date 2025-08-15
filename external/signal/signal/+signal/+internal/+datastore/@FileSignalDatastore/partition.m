function subds = partition(obj, partitionStrategy, partitionIndex)
%PARTITION Returns a new datastore that is a single partitioned portion of 
% the original datastore
%For internal use only. It may be removed.
%
%   SUBDS = PARTITION(SDS,NUMPARTITIONS,INDEX) partitions sds into
%   NUMPARTITIONS parts and returns the partitioned Datastore, SUBDS,
%   corresponding to INDEX. Use the NUMPARTITIONS function to estimate a
%   reasonable value for NUMPARTITIONS.
%
%   SUBDS = PARTITION(sds,'Files',INDEX) partitions sds by files in the
%   Files property and returns the partition corresponding to INDEX.
%
%   SUBDS = PARTITION(sds,'Files',FILENAME) partitions sds by files and
%   returns the partition corresponding to FILENAME.

%   Copyright 2019 The MathWorks, Inc.

narginchk(3,3)

partitionStrategy = convertStringsToChars(partitionStrategy);
partitionIndex = convertStringsToChars(partitionIndex);

try
    if ~ischar(partitionStrategy) || ~strcmpi(partitionStrategy, 'Files')
        subds = partition@matlab.io.datastore.SplittableDatastore(obj, partitionStrategy, partitionIndex);
    else
        subds = partitionFileStrategy(obj, partitionIndex);
    end

catch e
    throw(e)
end
end

function subds = partitionFileStrategy(sds, index)
    try
        % Input checking
        validateattributes(index, {'double', 'char'}, {}, 'partition', 'Index');
        if ischar(index)
            filename = index;
            validateattributes(filename, {'char'}, {'nonempty', 'row'}, 'partition', 'Filename');

            % There's no good way right now to compare a filename to the
            % files held by the fileset object. This will be slow.
            index = find(strcmp(sds.Files, filename));
            if isempty(index)
                error(message('MATLAB:datastoreio:splittabledatastore:invalidPartitionFile', filename));
            end

            if numel(index) > 1
                error(message('MATLAB:datastoreio:splittabledatastore:ambiguousPartitionFile', filename));
            end
        else
            validateattributes(index, {'double'}, {'scalar', 'positive', 'integer'}, 'partition', 'Index');
            if index > sds.NumFiles
                error(message('MATLAB:datastoreio:splittabledatastore:invalidPartitionIndex', index));
            end
        end

        [subds, files] = getCopyWithOriginalFiles(sds); 
        % FileIndices of the split always have a 1-1 mapping with the Files
        % contained by the datastore. Set the fileset object of the
        % splitter and reset.
        initWithIndices(subds, index, files);
    catch ME
        throwAsCaller(ME);
    end
end

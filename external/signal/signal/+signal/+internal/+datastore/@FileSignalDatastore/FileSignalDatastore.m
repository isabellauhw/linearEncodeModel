classdef FileSignalDatastore < ...
        matlab.io.datastore.CustomReadDatastore & ...
        matlab.io.datastore.internal.ScalarBase & ...
        matlab.io.datastore.Partitionable & ...        
        matlab.io.datastore.Shuffleable & ...        
        matlab.io.datastore.mixin.Subsettable & ...
        matlab.io.datastore.internal.util.SubsasgnableFileSet & ...
        matlab.mixin.CustomDisplay  
%FileSignalDatastore Datastore for a collection of signal files. For
%internal use only. It may be removed.
%
%   FileSignalDatastore Properties:
%
%     Files                    - Cell array of file names
%     AlternateFileSystemRoots - Alternate file system root paths for the
%                                files
%     ReadSize                 - Read size
%     ReadFailureRule          - Rule to handle read failures, skip the 
%                                file or error
%     MaxFailures              - Maximum number of allowed read failures
%     ReadFailures             - Information on files that have read failures
%
%   FileSignalDatastore Methods:
%
%     read          - Reads the next consecutive signal file
%     readall       - Reads all files from the datastore
%     reset         - Resets the datastore to the start of the data
%     hasdata       - Returns true if there is more data in the datastore    
%     shuffle       - Shuffles the files in the datastore
%     subset        - Creates a datastore with a subset of files
%     preview       - Reads the first signal from the datastore for preview
%     progress      - Returns the fraction of files read
%     partition     - Returns a new datastore that is a single
%                     partitioned portion of the original datastore
%     numpartitions - Returns an estimate for a reasonable number of
%                     partitions according to the total data size
%     transform     - Create an altered form of the current datastore by
%                     specifying a function handle that will execute after
%                     read on the current datastore
%     combine       - Create a new datastore that horizontally concatenates
%                     the result of read from two or more input datastores

% Copyright 2019 The MathWorks, Inc.

properties 
    ReadSize = 1;
end

properties (SetAccess = private)
    % FileExtensions
    FileExtensions
end

properties (Dependent)
    % Files Cell array of file names
    Files;
end

properties (Dependent)
    % AlternateFileSystemRoots Alternate file system roots
    AlternateFileSystemRoots;
end

properties (Access = private)
    % Deployment needs a way to get files before resolving them
    UnResolvedFiles;
    % To help support future forward compatibility. The value indicates the
    % version of MATLAB.
    SchemaVersion;
    % To know if ReadFcn is changed
    IsReadFcnDefault;
    %CurrentFileIndex Index of the current file being read
    CurrentFileIndex = 0
    % pNextFile Next file to read
    pNextFile
    % pDisplayPropertyList
    pDisplayPropertyList = [...
        "FileExtensions";...
        "AlternateFileSystemRoots";...
        "ReadFcn";...
        "ReadSize"];    
end

properties (Constant, Access = private)
    WHOLE_FILESET_CUSTOM_READ_SPLITTER_NAME = 'matlab.io.datastore.splitter.WholeFileCustomReadFileSetSplitter';
    CONVENIENCE_CONSTRUCTOR_FCN_NAME = 'signal.internal.datastore.FileSignalDatastore';
    MAX_FILE_SIZE_FOR_DISPLAY = 3;
end

properties (Hidden)
    ReadFailureRule;
    MaxFailures;
end

methods
    %----------------------------------------------------------------------
    function obj = FileSignalDatastore(files,varargin)
        try
            files = matlab.io.datastore.FileBasedDatastore.convertFileSetToFiles(files);
            files = convertStringsToChars(files);
            [varargin{:}] = convertStringsToChars(varargin{:});
            nv = iParseNameValues(obj,varargin{:});
            initDatastore(obj,files,nv);
            obj.UnResolvedFiles = files;                        
        catch e
            throwAsCaller(e);
        end
    end
    
    %----------------------------------------------------------------------
    function frac = progress(obj)
        %PROGRESS  Returns the fraction of files read        
        frac = obj.CurrentFileIndex/obj.Splitter.Files.NumFiles;
    end
end

%--------------------------------------------------------------------------
% SET/GET Methods
%--------------------------------------------------------------------------
methods
    %Files
    %----------------------------------------------------------------------
    function set.Files(obj, files)
        try
            % set.Files can only accept file names, no folders, wildcard
            % operations or filset objects. Check that. Then also check
            % that new files have the same file type as old files. 
            [~, ~, ~, ~, diffPaths] = setNewFilesAndFileSizes(obj, files);
            
            % If we are using a default read function we cannot change the
            % file extension type. If diffPaths is empty, it means that the
            % new files already existed in the datastore.
            if ~isempty(diffPaths)
                fcnInfo = functions(obj.ReadFcn);
                if isfield(fcnInfo,'file')
                    if contains(string(fcnInfo.function),"signal.internal.datastore.readDatastoreSignalFromMAT")
                        [~,uniformFlag,uniqueList] = signal.internal.datastore.getFileExtensions(string(diffPaths));
                        if ~uniformFlag || uniqueList ~= ".mat"
                            error(message('signal:signalDatastore:FileSignalDatastore:InvalidFileSetMAT'));
                        end
                    elseif contains(string(fcnInfo.function),"signal.internal.datastore.readDatastoreSignalFromCSV")
                        [~,uniformFlag,uniqueList] = signal.internal.datastore.getFileExtensions(string(diffPaths));
                        if ~uniformFlag || uniqueList ~= ".csv"
                            error(message('signal:signalDatastore:FileSignalDatastore:InvalidFileSetCSV'));
                        end
                    end
                end
            end
            setFilesOnFileSet(obj, files);            
        catch e
            throw(e)
        end
    end
    
    function files = get.Files(obj)
        files = getFilesAsCellStrAndCache(obj);
    end
    
    %FileExtensions
    %----------------------------------------------------------------------
    function set.FileExtensions(obj, val)
        obj.FileExtensions = val;
        
    end
    
    function val = get.FileExtensions(obj)
        val = obj.FileExtensions;
    end
    
    %AlternateFileSystemRoots
    %----------------------------------------------------------------------
    function set.AlternateFileSystemRoots(obj, aRoots)
        try
            obj.Splitter.Files.AlternateFileSystemRoots = aRoots;
            reset(obj);
        catch ME
            throw(ME);
        end
    end
    
    function aRoots = get.AlternateFileSystemRoots(obj)
        aRoots = obj.Splitter.Files.AlternateFileSystemRoots;
    end
    
    %ReadFailureRule
    %----------------------------------------------------------------------
    function set.ReadFailureRule(ds, readfailrule)
        try
            readfailrule = convertStringsToChars(readfailrule);
            validateReadFailureRule(ds, readfailrule);
        catch ME
            throw(ME);
        end
    end
    
    function readfailrule = get.ReadFailureRule(ds)
        readfailrule = ds.PrivateReadFailureRule;
    end
    
    %MaxFailures
    %----------------------------------------------------------------------
    function set.MaxFailures(ds, maxfails)
        try
            maxfails = convertStringsToChars(maxfails);
            validateMaxFailures(ds, maxfails);
        catch ME
            throw(ME);
        end
    end
    
    function maxfails = get.MaxFailures(ds)
        maxfails = ds.PrivateMaxFailures;
    end
    
    % ReadSize
    %----------------------------------------------------------------------
    function set.ReadSize(obj,val)
        validateattributes(val,"numeric",["scalar","positive","integer"],'',"ReadSize");
        obj.ReadSize = val;
    end
end

methods (Hidden)
    %----------------------------------------------------------------------
    function obj = subsasgn(obj,S,B)
        try
            % At the end of subsasgn clear the cache.
            c = onCleanup(@() initializeCachedFiles(obj));
            
            subsasgnPreamble(obj,S,B);
            obj = builtin('subsasgn', obj,S,B);
        catch e
            throw(e)
        end
    end
    
    %----------------------------------------------------------------------
    function data = getObservations(obj)
        % For a file datatore this means getting files
        data = obj.Files;
    end
    
    %----------------------------------------------------------------------
    function nF = numobservations(obj)
        % For a file datatore this means getting number of files
        try
            nF = obj.NumFiles;
        catch e
            throw(e)
        end
    end
    
    %----------------------------------------------------------------------
    function initFromFileSplit(obj,filename,offset,len)
        initFromFileSplit@matlab.io.datastore.CustomReadDatastore(obj,filename,offset,len);
        % set datastore not to use prefetch reading
        obj.IsReadFcnDefault = false;
    end
    
    %----------------------------------------------------------------------
    function avgFs = getAverageFileSize(sfds)
        avgFs = mean(sfds.Splitter.getFileSizes);
    end
    
    %----------------------------------------------------------------------
    function str = getElementsForDisplay(obj,maxNumElementsToDisplay,nlspacing)
        import matlab.io.internal.cellArrayDisp;
        if obj.NumFiles >= maxNumElementsToDisplay
            % Get only maxNumElementsToDisplay files. If there are
            % millions of files this improves performance by many orders.
            indices = 1:maxNumElementsToDisplay;
            files = obj.Splitter.getFilesAsCellStr(indices);
        else
            files = obj.Files;
        end
        str = cellArrayDisp(files, true, nlspacing, obj.NumFiles);
    end
end

methods (Access = private)
    %----------------------------------------------------------------------
    function [data, info] = readUsingSplitReader(obj,splitIndex)
        splitReader = createReader(obj.Splitter, splitIndex);
        reset(splitReader);
        [data, info] = getNext(splitReader);
    end
    
    %----------------------------------------------------------------------
    function initDatastore(obj,files,nv)
        import signal.internal.datastore.FileSignalDatastore;
        import matlab.io.datastore.internal.validators.validateCustomReadFcn;
        import matlab.io.datastore.internal.isIRI;
        import matlab.io.datastore.internal.fileset.ResolvedFileSetFactory;

        % If no read function was specified use default read function.
        % Further, if no file extension was specified, used the default
        % '.mat'. If a file extension was specified, it has to be '.mat'
        readFcn = nv.ReadFcn;
        if isempty(readFcn)
            if isnumeric(nv.FileExtensions) && nv.FileExtensions == -1
                nv.FileExtensions = '.mat';
            end
            if string(nv.FileExtensions) ~= ".mat"
                error(message('signal:signalDatastore:FileSignalDatastore:InvalidFileExtensions'));
            end
            readFcn = @(x)signal.internal.datastore.readDatastoreSignalFromMAT(x,'','','');
        else
            validateCustomReadFcn(nv.ReadFcn, true, FileSignalDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME);
        end      
        
        % Get all the supported files - need to add FileExtensions to
        % nv.UsingDefaults as ResolvedFileSetFactory.buildCompressed uses
        % this information to get the supported files. 
        if isnumeric(nv.FileExtensions) && nv.FileExtensions == -1
            if ~any(ismember('FileExtensions',nv.UsingDefaults))
                nv.UsingDefaults = [nv.UsingDefaults "FileExtensions"];
            end
        end
                                
        [files, ~, ~] = ResolvedFileSetFactory.buildCompressed(files, nv);
        obj.SplitterName = signal.internal.datastore.FileSignalDatastore.WHOLE_FILESET_CUSTOM_READ_SPLITTER_NAME;
        obj.NumFiles = files.NumFiles;
        
        % initFromReadFcn sets the datastore's ReadFcn and passes rest
        % of the varargin inputs to the splitter.
        %  - initFromReadFcn(ds, readFcn, varargin)
        %
        %  - files - Pass files to the initialization of the splitter,
        %    so we don't lookup the path and verify the existence of files
        %    again
        initFromReadFcn(obj, readFcn, files);
        
        % set up TotalFiles property
        obj.TotalFiles = numel(files);
        obj.AlternateFileSystemRoots = nv.AlternateFileSystemRoots;
        if isnumeric(nv.FileExtensions) && nv.FileExtensions == -1
            obj.FileExtensions = [];
        else
            obj.FileExtensions = nv.FileExtensions;
        end
        
        % Set read size
        obj.ReadSize = nv.ReadSize;
        
        % Set the schema version
        obj.SchemaVersion = version('-release');
    end
end

methods (Access = protected)    
    %----------------------------------------------------------------------
    function n = maxpartitions(obj)
        n = maxpartitions(getFileSet(obj));
    end
    %----------------------------------------------------------------------
    function setFileSet(sfds, fileset)
        sfds.Splitter.setFiles(fileset);
    end
    
    %----------------------------------------------------------------------
    function fileset = getFileSet(sfds)
        fileset = sfds.Splitter.Files;
    end
    
    %----------------------------------------------------------------------
    function setNextFile(obj)
        if obj.Splitter.Files.NumFiles == 0
            return
        end
        file = nextfile(obj.Splitter.Files); % Get the next file from DsFileSet
        obj.pNextFile = char(file.FileName);
    end
    
    %------------------------------------------------------------------
    function moveToNextFile(obj)
        %MOVETONEXTFILE Set up the datastore to read the next file.
        %   Sets the signal file reader to read the next file in the
        %   datastore. Also resets the states.
        
        % Set signal file reader to the next file
        setNextFile(obj);
        
        % Increment file counter
        obj.CurrentFileIndex = obj.CurrentFileIndex + 1;        
    end
    
    %----------------------------------------------------------------------
    function validateReadFcn(obj, readFcn) %#ok<INUSL>
        
        % validateReadFcn is called from set.ReadFcn
        import signal.internal.datastore.FileSignalDatastore;
        import matlab.io.datastore.internal.validators.validateCustomReadFcn;
        validateCustomReadFcn(readFcn, false, signal.internal.datastore.FileSignalDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME);
    end
    
    %----------------------------------------------------------------------
    function displayScalarObject(obj)
        disp(getHeader(obj));
        group = getPropertyGroups(obj);  
        displayFiles(obj,group);
        matlab.mixin.CustomDisplay.displayPropertyGroups(obj, group);
        disp(getFooter(obj));
    end    
    
    function displayFiles(obj,group)
        import signal.internal.datastore.FileSignalDatastore;
        maxLen = 0;
        for idx = 1:numel(group.PropertyList)
            if length(char(group.PropertyList(idx))) > maxLen
                maxLen = length(char(group.PropertyList(idx)));
            end
        end
        filesIndent = [repmat(' ',1,maxLen-1) 'Files:'];
        nlspacing = sprintf(repmat(' ',1,numel(filesIndent)));
        str = obj.getElementsForDisplay(FileSignalDatastore.MAX_FILE_SIZE_FOR_DISPLAY,nlspacing);
        disp([filesIndent str]);
    end
    
    function propgrp = getPropertyGroups(obj)        
        propList = obj.pDisplayPropertyList; 
        propgrp = matlab.mixin.util.PropertyGroup(propList);
    end    
end

methods (Static, Hidden)
    %----------------------------------------------------------------------
    function outds = loadobj(ds)
        import signal.internal.datastore.FileSignalDatastore;
        switch class(ds)
            case 'struct'
                % load datastore from struct
                outds = FileSignalDatastore.loadFromStruct(ds);
            case 'signal.internal.datastore.FileSignalDatastore'
                outds = loadobj@matlab.io.datastore.CustomReadDatastore(ds);
        end
    end
    
    %----------------------------------------------------------------------
    function defaultExtensions = getDefaultExtensions()
        % Get formats specific extensions
        defaultExtensions = {'.mat','.csv'};
    end
    
    %----------------------------------------------------------------------
    function varargout = supportsLocation(loc,nvStruct)
        % This function is responsible for determining whether a given
        % location is supported by Datastore. It also returns a
        % resolved filelist.
        import matlab.io.datastore.internal.lookupAndFilterExtensions;
        import signal.internal.datastore.FileSignalDatastore;
        nvStruct.ForCompression = true;
        [varargout{1:nargout}] = lookupAndFilterExtensions(loc, nvStruct, signal.internal.datastore.FileSignalDatastore.getDefaultExtensions);
    end
    
end

methods (Static, Access = private)
    %----------------------------------------------------------------------
    function ds = loadFromStruct(dsStruct)
        
        import signal.internal.datastore.FileSignalDatastore
        % empty datastore
        ds = FileSignalDatastore({});
        FileSignalDatastore.setCorrectSplitter(ds, dsStruct.Splitter);
        reset(ds);
        
        fieldsToRemove = {'Splitter', 'BatchReader',...
            'DataBuffer', 'ErrorBuffer',...
            'FileBuffer', 'FileBufferFirstIndex',...
            'StartIndexPrefetchFiles',...
            };
        fieldList = fields(dsStruct);
        fieldsToRemove = iIntersectStrings(fieldList, fieldsToRemove);
        
        if ~isempty(fieldsToRemove)
            dsStruct = rmfield(dsStruct, fieldsToRemove);
            fieldList = fields(dsStruct);
        end
        
        for fieldIndex = 1: length(fieldList)
            field = fieldList{fieldIndex};
            ds.(field) = dsStruct.(field);
        end
    end
    
    %----------------------------------------------------------------------
    function setCorrectSplitter(ds, splitter)
        ds.Splitter = copy(splitter);
    end
end
end

function parsedStruct = iParseNameValues(~,varargin)
persistent inpP;
import signal.internal.datastore.FileSignalDatastore;
if isempty(inpP)
    inpP = inputParser;
    addParameter(inpP, 'ReadFcn','');
    addParameter(inpP, 'AlternateFileSystemRoots', {});    
    addOptional(inpP,'FileExtensions',-1);
    addOptional(inpP,'IncludeSubfolders',false);
    addOptional(inpP,'ReadSize',1);    
    
    inpP.FunctionName = FileSignalDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME;
    
end
parse(inpP, varargin{:});
parsedStruct = inpP.Results;
parsedStruct.UsingDefaults = inpP.UsingDefaults;
end

% A for loop version of intersect. Remove string items from setTwo
% if not present in setOne argument.
function setTwo = iIntersectStrings(setOne, setTwo)
num = numel(setTwo);
idxes = false(num, 1);
for ii = 1:num
    idxes(ii) = any(strcmp(setOne, setTwo(ii)));
end
setTwo(~idxes) = [];
end

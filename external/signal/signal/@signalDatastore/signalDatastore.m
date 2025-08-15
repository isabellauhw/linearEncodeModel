classdef (Sealed) signalDatastore < ...
        matlab.io.Datastore & ...
        matlab.io.datastore.Partitionable & ...
        matlab.io.datastore.Shuffleable & ... 
        matlab.io.datastore.mixin.Subsettable & ...
        matlab.mixin.CustomDisplay & ...
        matlab.mixin.SetGet 
%SIGNALDATASTORE Datastore for a collection of signals
%   SDS = signalDatastore(MEMBERS) creates a signalDatastore, SDS, with
%   in-memory input data contained in cell array MEMBERS. Each element of
%   the cell array is a member that is output by the datastore on each call
%   to read. Examples of input source data are:
%
%   - M-element cell array containing numeric matrices:
%     {Matrix1(p1xq1),...,MatrixM(pMxqM)}. A matrix is output at each call
%     to read.
%   - M-element cell array with each element being a cell array of
%     numeric vectors:
%     {{Vector11(p11x1),...Vector1R(p1Rx1)},...,{VectorM1(pM1x1),...VectorMT(pMTx1)}}
%     A cell array of vectors is output at each call to read.
%   - M-element cell array of timetables. A timetable is output at
%     each call to read. 
%   - M-element cell array with each element being a cell array of
%     timetables:
%     {{Timetable11,...,Timetable1R},...,{TimetableM1,...,TimetableMT}}
%     A cell array of timetables is output at each call to read.
%
%   SDS = signalDatastore(MEMBERS,'MemberNames',NAMES) specifies a list of
%   member names for the input data as a string vector with length equal to
%   the length of the MEMBERS cell array. If this property is not specified
%   signalDatastore uses ["Member1" ... "MemberM"] for member names.
%   "MemberNames" applies only when datastore contains in-memory data.
%   
%   SDS = signalDatastore(LOCATION) creates a signalDatastore, SDS, to read
%   files specified in LOCATION. Files with .mat extensions are added to
%   the signalDatastore if there are MAT files in the specified LOCATION.
%   Otherwise, CSV files are added to the signalDatastore if there are
%   CSV files in the specified LOCATION. On each read, signalDatastore
%   opens a file and reads the first variable in the variable list of the
%   file. See the documentation to learn how signalDatastore determines the
%   variable list of a MAT or CSV file. If your files contain more than
%   one variable and you want to specify the variable names that hold the
%   signal data you want to read, use the 'SignalVariableNames' property.
%   
%   LOCATION has the following properties:
%      - It can be a file name or a folder name.
%      - It can be a cell array or a string array of multiple file or folder names.
%      - It can be a matlab.io.datastore.DsFileSet object.
%      - It can contain a relative path (HDFS requires a full path).
%      - It can contain a wildcard (*) character.
%      - It can be a remote location specified using an internationalized
%        resource identifier (IRI). For more information on accessing remote
%        data, see "Read Remote Data" in the documentation.
% 
%   SDS = signalDatastore(LOCATION,...,'FileExtensions',EXT) specifies the
%   file extensions, EXT, of files to be included in the signalDatastore,
%   as a string vector. When no read function is specified, EXT can only be
%   set to ".mat" to read MAT files, or to ".csv" to read CSV files. In
%   this scenario, if 'FileExtensions' is omitted it defaults to ".mat" if
%   there are MAT files in the specified location, otherwise it defaults
%   to ".csv" if there are CSV files in the specified location. A custom
%   read function must be specified to read files of any other type.
%
%   When you do not specify a file extension, the signalDatastore needs to
%   parse the files to decide the default extension to read. Specify an
%   extension to avoid the parsing time.
%
%   SDS = signalDatastore(LOCATION,...,'IncludeSubfolders',TF) specifies
%   whether the files in subfolders are included in the signalDatastore.
%   Specify TF as a logical scalar. The default is false.
%
%   SDS = signalDatastore(LOCATION,...,'AlternateFileSystemRoots',AFSR)
%   specifies alternate file system root paths for the files provided in
%   the LOCATION argument. 'AlternateFileSystemRoots' contains one or more
%   rows, where each row specifies a set of equivalent root paths. Values
%   for 'AlternateFileSystemRoots' can be:
%
%     - A string row vector of root paths, such as ["Z:\datasets", "/mynetwork/datasets"]
%     - A cell array of root paths, where each row of the cell array can be
%       specified as string row vector such as
%         {["Z:\datasets", "/mynetwork/datasets"];["Y:\datasets", "/mynetwork2/datasets","S:\datasets"]}
%
%   SDS = signalDatastore(LOCATION,...,'SignalVariableNames',SIGNAMES)
%   specifies SIGNAMES as a string vector of one or more unique names. Use
%   this property when your files contain more than one variable and you
%   want to specify the names of the variables that hold the signal data
%   you want to read. When SIGNAMES has one element, signalDatastore
%   returns data contained in the specified variable. When SIGNAMES has
%   more than one element, signalDatastore returns a cell array with the
%   data contained in the specified variables. If not specified,
%   signalDatastore reads the first variable in the variable list of each
%   file. See the documentation to learn how signalDatastore determines the
%   variable list of a file. 'SignalVariableNames' is not valid if a custom
%   read function is specified.
%
%   SDS = signalDatastore(LOCATION,...,'SampleRateVariableName',FSNAME)
%   specifies FSNAME as a string scalar corresponding to the name of the
%   variable in the files that holds the sample rate value of the signal
%   that you want to read.
%
%   SDS = signalDatastore(LOCATION,...,'SampleTimeVariableName',TSNAME)
%   specifies TSNAME as a string scalar corresponding to the name of the
%   variable in the files that holds the sample time value of the signal
%   that you want to read. 
%
%   SDS = signalDatastore(LOCATION,...,'TimeValuesVariableName',TVNAME)
%   specifies TVNAME as a string scalar corresponding to the name of the
%   variable in the files that holds the time values vector of the signal
%   that you want to read.
%
%   'SampleRateVariableName', 'SampleTimeVariableName', and
%   'TimeValuesVariableName' are mutually exclusive. Use these properties
%   when your files contain a variable that holds the time information of
%   the signal data. If not specified, signalDatastore assumes that signal
%   data has no time information. These properties are not valid if a
%   custom read function is specified.
%
%   If you are working with in-memory data, or if the time information of
%   the signals in the dataset is not contained inside the files, you can
%   specify time information using the 'SampleRate', 'SampleTime', and
%   'TimeValues' properties as shown below:
%
%   SDS = signalDatastore(...,'SampleRate',FS) defines a sample rate, Fs,
%   for signalDatastore, SDS. Set 'SampleRate' to a positive numeric scalar
%   to specify the same sample rate for all signals in SDS. Set
%   'SampleRate' to a vector to specify a different sample rate for each
%   signal in SDS. The vector must have a number of elements equal to the
%   number of signals in SDS, i.e., same number of elements as the number
%   of members for an in-memory data case, or as the number of files for a
%   file data case.
%
%   SDS = signalDatastore(...,'SampleTime',Ts) defines a sample time, Ts,
%   for signalDatastore, SDS. Set 'SampleTime' to a numeric or duration
%   scalar to specify the same sample time for all signals in SDS. Set
%   'SampleTime' to a vector to specify a different sample time for each
%   signal in SDS. The vector must have a number of elements equal to the
%   number of signals in SDS.
%
%   SDS = signalDatastore(...,'TimeValues',Tv) defines time values, Tv, for
%   signalDatastore, SDS. Set 'TimeValues' to a numeric or duration vector
%   to specify the same time values for all signals in SDS. Set
%   'TimeValues' to a matrix or a cell array to specify a different time
%   values vector for each signal in SDS. If Tv is a matrix, it must have a
%   number of columns equal to the number of signals in SDS. If Tv is a
%   cell array, it must have a number of elements equal to the number of
%   signals in SDS.
%
%   'SampleRate', 'SampleTime', and 'TimeValues' are mutually exclusive and
%   are not valid if a custom read function is specified.
%  
%   SDS = signalDatastore(...,'ReadSize',READSIZE) specifies the maximum
%   number of signal files to read in a call to the read function. By
%   default, READSIZE is 1. The output of read is a cell array of signal
%   data when READSIZE > 1.
%
%   SDS = signalDatastore(LOCATION,...,'ReadFcn',@MYCUSTOMREADER) specifies
%   a custom function @MYCUSTOMREADER to read files in LOCATION. The value
%   of 'ReadFcn' must be a function handle with the following signature:
%      function [data, info] = MYCUSTOMREADER(filename)
%            ...
%      end
%   The signal data is output in the data variable. The info variable is a
%   structure containing time information and other relevant information
%   from the file.
%
%   SDS = signalDatastore(LOCATION,...,'ReadFcn',@MYCUSTOMREADER,'FileExtensions',EXT)
%   Specify custom format file extensions, EXT, as a string scalar or
%   string array. When you specify a custom read function and file
%   extensions, signalDatastore reads only the files with extensions
%   specified in EXT. If you do not specify 'FileExtensions', then  
%   signalDatastore automatically includes all files within a folder.
%
%   signalDatastore Properties (in-memory):
%   These properties apply only when signalDatastore contains in-memory data.
%
%     Members                   - Cell array of signal data.
%     MemberNames               - Names of signal members.
%
%   signalDatastore Properties (files):
%   These properties apply only when signalDatastore contains file data.
%
%     Files                     - Cell array of file names.
%     AlternateFileSystemRoots  - Alternate file system root paths for the
%                                 files.
%     ReadFcn                   - Function handle used to read files.
%     SignalVariableNames       - Names of variables in files that hold the
%                                 signal data.
%     SampleRateVariableName    - Name of variable in files that holds the
%                                 signal sample rate.
%     SampleTimeVariableName    - Name of variable in files that holds the
%                                 signal sample time.
%     TimeValuesVariableName    - Name of variable in files that holds the
%                                 signal time values.
%
%   signalDatastore Properties (all):
%
%     SampleRate                - Sample rate value(s) of the signals in 
%                                 the signalDatastore.
%     SampleTime                - Sample time value(s) of the signals in 
%                                 the signalDatastore.
%     TimeValues                - Time values vector(s) of the signals in 
%                                 the signalDatastore.
%     ReadSize                  - Upper limit on the number of signals 
%                                 returned by the read method.
%
%   signalDatastore Methods:
%
%     read          - Read the next consecutive signal.
%     readall       - Read all signals from the signalDatastore.
%     preview       - Read the first signal from the signalDatastore for
%                     preview.
%     shuffle       - Shuffle the signals in the signalDatastore.
%     subset        - Create a signalDatastore with a subset of signals.
%     partition     - Returns a new signalDatastore that represents a single
%                     portion of the original datastore. 
%     numpartitions - Estimate of a reasonable number of partitions.
%     reset         - Reset the signalDatastore to the start of the data.
%     progress      - Fraction of files read in the signalDatastore.
%     hasdata       - True if there are more signals in the signalDatastore.
%     transform	    - Create an altered form of the current datastore by 
%                     specifying a function handle that executes after read
%                     on the current datastore.
%     combine	    - Create a new datastore that horizontally concatenates 
%                     the result of read from two or more input datastores.
%
%   % EXAMPLE:
%      % Create a signal datastore to iterate through the elements of an
%      % in-memory cell array of random matrices. Set sample rate to 1 kHz.
%      members = {randn(100,1); randn(120,3); randn(135,2); randn(100,1);...
%              randn(150,2); randn(155,2); randn(85,10); randn(170,2);...
%              randn(145,3); randn(112,2)};
%      sds = signalDatastore(members,'SampleRate',1000);
%
%      while hasdata(sds)
%          [data,info] = read(sds);
%      end
%
%   See also fileDatastore, audioDatastore, tabularTextDatastore,
 
%   Copyright 2019-2020 The MathWorks, Inc.

properties (Dependent)
    %ReadSize Upper limit on the number of signals returned by the read method.
    ReadSize;
    %MemberNames Names of signal members. This property applies only when
    %signalDatastore contains in-memory data.
    MemberNames;
    %Members Cell array of member names. This property applies only when
    %signalDatastore contains in-memory data.
    Members;
    %Cell array of file names. This property applies only when
    %signalDatastore contains file data.
    Files;
    %AlternateFileSystemRoots Alternate file system roots.
    AlternateFileSystemRoots;
    %SignalVariableNames Names of variables in files that hold the signal
    %data. This property applies only when signalDatastore contains file
    %data.
    SignalVariableNames;
    %SampleRateVariableName Name of variable in files that holds the signal
    %sample rate. This property applies only when signalDatastore contains
    %file data.
    SampleRateVariableName;
    %SampleTimeVariableName Name of variable in files that holds the signal
    %sample time. This property applies only when signalDatastore contains
    %file data.
    SampleTimeVariableName;
    %TimeValuesVariableName Name of variable in files that holds the signal
    %time values. This property applies only when signalDatastore contains
    %file data.
    TimeValuesVariableName;
    %SampleRate Sample rate value(s) of the signals in the signalDatastore.
    SampleRate;
    %SampleTime Sample time value(s) of the signals in the signalDatastore.
    SampleTime;
    %TimeValues Time values vector(s) of the signals in the signalDatastore.
    TimeValues;
    %ReadFcn Custom read function
    ReadFcn;
end

properties (Access = private)
    %Private properties to hold values of dependent properties
    pSignalVariableNames = [];
    pSampleRateVariableName = [];
    pSampleTimeVariableName = [];
    pTimeValuesVariableName = [];
    pSampleRate = [];
    pSampleTime = [];
    pTimeValues = [];
    %Internal Datastore with knowledge of how to read the specific file
    %types
    pDatastoreInternal = [];
    %Cache version to help support future forward compatibility. The value
    %indicates the version of MATLAB.
    pSchemaVersion;
    %Flag to know if ReadFcn is changed
    pIsReadFcnDefault = false;
    %Index of the current file being read
    pCurrentFileIndex = 0;
    %pNextFile Next file to read
    pNextFile;
    %pTimeInformationPropertyName Time information property name - can be
    %SampleRate, SampleTime, TimeValues, SampleRateVariableName,
    %SampleTimeVariableName, TimeValuesVariableName
    pTimeInformationPropertyName = [];
    %pTimeInformationName Actual name (not property name) of the time type
    %specified - SampleRate, SampleTime, or TimeValues
    pTimeInformationName = [];
    
    %pInMemoryFlag True if we are dealing with in-memory data
    pInMemoryFlag = false;
    %Property list used to display the object
    pDisplayPropertyList = [...
        "Members";...
        "AlternateFileSystemRoots";...
        "ReadSize";...
        "SignalVariableNames";...
        "SampleRateVariableName";...
        "SampleTimeVariableName";...
        "TimeValuesVariableName";...
        "SampleRate";...
        "SampleTime";...
        "TimeValues";...
        "ReadFcn"];
    
    % List of name inputs that only relate to files
    pFileRelatedOnlyInputNames = [...
        "IncludeSubfolders";...
        "AlternateFileSystemRoots";...
        "FileExtensions";...
        "SignalVariableNames";...
        "SampleRateVariableName";...
        "SampleTimeVariableName";...
        "TimeValuesVariableName";...
        "ReadFcn"];
    
    % List of name inputs that only relate to in-memory data
    pInMemoryRelatedOnlyInputNames = "MemberNames";
    
    % List of supported files for default read
    pListOfSupportedDefaultReadFiles = [".mat",".csv"];
    
    pCheckPropertiesFlag = true;
end

properties (Constant, Access = private)
    CONVENIENCE_CONSTRUCTOR_FCN_NAME = 'signalDatastore';
    MAX_FILE_SIZE_FOR_DISPLAY = 3;
end

% Constructor
methods
    %----------------------------------------------------------------------
    function obj = signalDatastore(src,varargin)
        
        % Look at the input source type and set pInMemoryFlag
        parseInputSource(obj,src);
        
        try
            % Convert all NV pairs specified as string to char, parse
            % inputs and initialize datastore
            [varargin{:}] = convertStringsToChars(varargin{:});
            nv = iParseNameValues(obj,varargin{:});
            nv = validateNameValues(obj,nv,src);
            nv = initDatastore(obj,nv);
            if obj.pInMemoryFlag
                % In-memory case
                
                % We do not have a read function in the in-memory case but
                % set the obj.pIsReadFcnDefault flag to true to ensure that
                % we can use properties that only apply when read function
                % is default in the file case
                obj.pIsReadFcnDefault = true;
                
                fieldsToRemove = {'IncludeSubfolders','AlternateFileSystemRoots',...
                    'FileExtensions','ReadFcn','SampleRate','SampleTime',...
                    'TimeValues','SignalVariableNames','SampleRateVariableName',...
                    'SampleTimeVariableName','TimeValuesVariableName',...
                    'UsingDefaults','AllParameters'};
                nvForDatastoreInternal = rmfield(nv,fieldsToRemove);
                try
                    obj.pDatastoreInternal = signal.internal.datastore.InMemorySignalDatastore(src,nvForDatastoreInternal);
                catch e
                    throw(e);
                end
            else
                % File case
                
                signals = matlab.io.datastore.FileBasedDatastore.convertFileSetToFiles(src);
                signals = convertStringsToChars(signals);
                
                fieldsToRemove = {'MemberNames','SampleRate','SampleTime',...
                    'TimeValues','SignalVariableNames','SampleRateVariableName',...
                    'SampleTimeVariableName','TimeValuesVariableName',...
                    'UsingDefaults','AllParameters'};
                
                nvForDatastoreInternal = rmfield(nv,fieldsToRemove);
                
                % Construct a FileSignalDatastore if a read function was
                % specified, or if no file extensions were specified, or if
                % any of the file extensions is supported by that datastore
                if ~obj.pIsReadFcnDefault || isnumeric(nv.FileExtensions) || any([".mat", ".csv"] == string(nv.FileExtensions))
                    % Create a FileSignalDatastore
                    % Datastore mixins require file extensions as cell strings
                    if ~isnumeric(nvForDatastoreInternal.FileExtensions)
                        nvForDatastoreInternal.FileExtensions = cellstr(nvForDatastoreInternal.FileExtensions);
                    end
                    obj.pDatastoreInternal = signal.internal.datastore.FileSignalDatastore(signals,nvForDatastoreInternal);
                    
                    % Validate custom read function
                    if ~obj.pIsReadFcnDefault
                        [flag, mssgObj] = validateCustomReadFcn(obj,nv.ReadFcn);
                        if ~flag
                            error(mssgObj);
                        end
                    end                                                                
                else
                    % Other internal stores added here
                    error(message('signal:signalDatastore:signalDatastore:InvalidFileRequest'));
                end
            end
            % Checks to see if properties 'SignalVariableNames',
            % 'SampleRateVariableName','SampleTimeVariableName',
            % 'TimeValuesVariableName','SampleRate','SampleTime',
            % 'TimeValues' apply were skipped at construction time - so
            % let's do the checks now.
            validateProperties(obj,nv);
        catch e
            throw(e);
        end
    end
    
    %----------------------------------------------------------------------
    function frac = progress(obj)
        %PROGRESS  Returns the fraction of files read
        %   fractionRead = progress(sds) returns the fraction of files read
        %   in the datastore as a normalized value between 0.0 and 1.0.
        %
        %   % EXAMPLE:
        %      data = {randn(100,1); randn(120,3); randn(135,2); randn(100,1);...
        %             randn(150,2); randn(155,2); randn(85,10); randn(170,2);...
        %              randn(145,3); randn(112,2)};
        %      sds = signalDatastore(data,'SampleRate',1000);
        %      read(sds);
        %      read(sds);
        %      progress(sds)
        %      reset(sds);
        %      progress(sds)
        
        frac = obj.pDatastoreInternal.progress();
    end
        
    %----------------------------------------------------------------------
    function outDs = mapreduce(obj,varargin)
        outDs = mapreduce(obj.pDatastoreInternal,varargin{:});
    end
end

methods (Hidden)
    %----------------------------------------------------------------------
    function n = numobservations(obj)
        %Return the total number of observations in the datastore
        n = numobservations(obj.pDatastoreInternal);
    end
    
    %----------------------------------------------------------------------
    function flag = isInMemory(obj)
        % True if datastore contains in-memory data
        flag = obj.pInMemoryFlag;
    end
    
    %----------------------------------------------------------------------
    function flag = isReadFcnDefault(obj)
        % True if datastore contains in-memory data
        flag = obj.pIsReadFcnDefault;
    end
    
    %----------------------------------------------------------------------    
    function val = getObservations(obj)
        % Return files or in-memory members
        val = obj.pDatastoreInternal.getObservations();        
    end
    
    %----------------------------------------------------------------------
    function names = getObservationsNames(obj)
        % Get files or member names of datastore
        if obj.pInMemoryFlag
            names = obj.MemberNames;
        else
            names = obj.Files;
        end
    end
    
    %----------------------------------------------------------------------
    function [flag,mssgKey] = isCompatible(obj,sds)
        % FLAG = isCompatible(SDS1,SDS2) returns true if signalDatastore
        % SDS1 is compatible with signalDatastore SDS2
        
        flag = false;     
        mssgKey = strings(0,0);
        
        if ~isequal(obj.pInMemoryFlag,sds.pInMemoryFlag)
            mssgKey = "IncompatibleMergeMemoryVsFile";
            return;
        end        
                
        if ~isequal(obj.pSignalVariableNames,sds.pSignalVariableNames)
            mssgKey = "IncompatibleSignalVariableNames";
            return;
        end
        if ~isequal(obj.pSampleRateVariableName,sds.pSampleRateVariableName)
            mssgKey = "IncompatibleSampleRateVariableName";
            return;
        end
        if ~isequal(obj.pSampleTimeVariableName,sds.pSampleTimeVariableName)
            mssgKey = "IncompatibleSampleTimeVariableName";
            return;
        end
        if ~isequal(obj.pTimeValuesVariableName,sds.pTimeValuesVariableName)
            mssgKey = "IncompatibleTimeValuesVariableName";
            return;
        end        
        
        if ~isequal(obj.pTimeInformationPropertyName,sds.pTimeInformationPropertyName)
            mssgKey = "IncompatibleTimeInformation";
            return;
        end                
        
        if ~isequal(obj.ReadSize,sds.ReadSize)
            mssgKey = "IncompatibleReadSize";
            return;
        end
                
        if obj.pInMemoryFlag 
            newMemberNames = [obj.MemberNames; sds.MemberNames];
            if numel(string(newMemberNames)) ~= numel(unique(string(newMemberNames)))
                mssgKey = "IncompatibleNonUniqueMemberNames";
                return; 
            end                       
        else
            newFiles = [obj.Files; sds.Files];
            if numel(string(newFiles)) ~= numel(unique(string(newFiles)))
                mssgKey = "IncompatibleNonUniqueFileNames";
                return;
            end
            
            % This check ensures same read function and same targeted file
            % types (i.e. mat or csv, ...)
            if isequal(obj.pIsReadFcnDefault,sds.pIsReadFcnDefault)
                if ~isequal(func2str(obj.pDatastoreInternal.ReadFcn),func2str(sds.pDatastoreInternal.ReadFcn))
                    mssgKey = "IncompatibleFileTypes";        
                    return;
                end                
            else
                if ~isequal(func2str(obj.pDatastoreInternal.ReadFcn),func2str(sds.pDatastoreInternal.ReadFcn))
                    mssgKey = "IncompatibleReadFcn";        
                    return;                    
                end                
            end
            
            if ~isequal(obj.AlternateFileSystemRoots,sds.AlternateFileSystemRoots)
                mssgKey = "IncompatibleAlternateFileSystemRoots";
                return;
            end
        end      
        
        % Made it with no incompatibilities
        flag = true;
    end
    
     %----------------------------------------------------------------------    
    function propList = getCurrentValidProps(obj)
        propList = obj.pDisplayPropertyList;
        
        if obj.pInMemoryFlag
            propList(propList == 'AlternateFileSystemRoots') = [];
        else
            propList(propList == 'Members') = [];
        end
        
        if obj.pInMemoryFlag || obj.pIsReadFcnDefault
            propList(propList == 'ReadFcn') = [];
        end
        
        if obj.pInMemoryFlag || ~obj.pIsReadFcnDefault || isempty(obj.pSignalVariableNames)
            propList(propList == 'SignalVariableNames') = [];
        end
        if obj.pInMemoryFlag || ~obj.pIsReadFcnDefault || isempty(obj.pSampleRateVariableName)
            propList(propList == 'SampleRateVariableName') = [];
        end
        if obj.pInMemoryFlag || ~obj.pIsReadFcnDefault || isempty(obj.pSampleTimeVariableName)
            propList(propList == 'SampleTimeVariableName') = [];
        end
        if obj.pInMemoryFlag || ~obj.pIsReadFcnDefault || isempty(obj.pTimeValuesVariableName)
            propList(propList == 'TimeValuesVariableName') = [];
        end
        
        if ~obj.pIsReadFcnDefault || isempty(obj.pSampleRate)
            propList(propList == 'SampleRate') = [];
        end
        if ~obj.pIsReadFcnDefault || isempty(obj.pSampleTime)
            propList(propList == 'SampleTime') = [];
        end
        if ~obj.pIsReadFcnDefault || isempty(obj.pTimeValues)
            propList(propList == 'TimeValues') = [];
        end 
        
        if isInMemory(obj)
            propList = ["MemberNames"; propList];
        else
            propList = ["Files"; propList];
        end
    end    
    
    %----------------------------------------------------------------------
    function [newSds, successFlag, mssgKey] = mergeImpl(obj,sds)
        % NEWSDS = mergeImpl(SDS1,SDS2) merges two compatible signalDatastores        
        % [NEWSDS,FLAG,MSSGKEY] = mergeImpl(SDS1,SDS2) merges two compatible
        % signalDatastores and returns FLAG = false when merge is
        % incompatible. It also returns a message key. Use this syntax when
        % you do not want MERGE to error out if the input signalDatastores
        % are incompatible.        
        
        validateattributes(sds,{'signalDatastore'},{});
        
        newSds = [];
        [successFlag,mssgKey] = isCompatible(obj,sds);
        if nargout < 2 && ~successFlag
            error(message("signal:signalDatastore:signalDatastore:" + mssgKey));
        elseif ~successFlag
            return;
        end
        
        newSds = copy(obj);
        
        if obj.pInMemoryFlag
            newMemberNames = [obj.MemberNames; sds.MemberNames];
            newMembers = [obj.Members; sds.Members];
        else
            newFiles = [obj.Files; sds.Files];
        end
        
        timePropName = obj.pTimeInformationPropertyName;
        if isequal(timePropName,"SampleRate") || isequal(timePropName,"SampleTime")
            propName = "p" + timePropName;
            
            objExpandedVector = obj.(propName);
            sdsExpandedVector = sds.(propName);
            
            if isscalar(obj.(propName)) && isscalar(sds.(propName)) && isequal(obj.(propName),sds.(propName))
                newSds.(propName) = obj.(propName);
            else
                if isscalar(obj.(propName))
                    objExpandedVector = repmat(obj.(propName),numobservations(obj),1);
                end
                if isscalar(sds.(propName))
                    sdsExpandedVector = repmat(sds.(propName),numobservations(sds),1);
                end
                
                newSds.(propName) = [objExpandedVector(:); sdsExpandedVector(:)];
            end
            
        elseif isequal(timePropName,"TimeValues")
            
            if ~iscell(obj.TimeValues) && isvector(obj.TimeValues) && ...
                    ~iscell(sds.TimeValues) && isvector(sds.TimeValues) && ...
                    isequal(obj.TimeValues(:),sds.TimeValues(:))
                
                newSds.pTimeValues = obj.TimeValues;
                
            else
                objCell = {};
                objExpandedMatrix = [];
                if iscell(obj.TimeValues)
                    objCell = obj.TimeValues;
                elseif isvector(obj.TimeValues)
                    objExpandedMatrix = repmat(obj.TimeValues(:),1,numobservations(obj));
                else
                    objExpandedMatrix = obj.TimeValues;
                end
                
                sdsCell = {};
                sdsExpandedMatrix = [];
                if iscell(sds.TimeValues)
                    sdsCell = sds.TimeValues;
                elseif isvector(sds.TimeValues)
                    sdsExpandedMatrix = repmat(sds.TimeValues(:),1,numobservations(sds));
                else
                    sdsExpandedMatrix = sds.TimeValues;
                end
                
                if ~isempty(objCell) || ~isempty(sdsCell)
                    if isempty(objCell)
                        objCell = mat2cell(objExpandedMatrix,size(objExpandedMatrix,1),ones(1,size(objExpandedMatrix,2)))';
                    end
                    
                    if isempty(sdsCell)
                        sdsCell = mat2cell(sdsExpandedMatrix,size(sdsExpandedMatrix,1),ones(1,size(sdsExpandedMatrix,2)))';
                    end
                    newSds.pTimeValues = [objCell; sdsCell];
                else
                    if size(objExpandedMatrix,1) == size(sdsExpandedMatrix,1)
                        newSds.pTimeValues = [objExpandedMatrix sdsExpandedMatrix];
                    else
                        objCell = mat2cell(objExpandedMatrix,size(objExpandedMatrix,1),ones(1,size(objExpandedMatrix,2)))';
                        sdsCell = mat2cell(sdsExpandedMatrix,size(sdsExpandedMatrix,1),ones(1,size(sdsExpandedMatrix,2)))';
                        newSds.pTimeValues = [objCell; sdsCell];
                    end
                end
            end
        end
        
        if obj.pInMemoryFlag
            setMembersAndMemberNames(newSds.pDatastoreInternal,newMembers,newMemberNames);
        else
            newSds.Files = newFiles;
        end
    end
end
%--------------------------------------------------------------------------
% SET/GET Methods
%--------------------------------------------------------------------------
methods
    %MemberNames
    %----------------------------------------------------------------------
    function set.MemberNames(obj,val)
        if ~obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForFileCase','Members'));
        end
        % Error checking for members is done in the internal datastore
        try
            obj.pDatastoreInternal.MemberNames = val;
        catch e
            throw(e)
        end
    end
    
    function val = get.MemberNames(obj)
        if ~obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForFileCase','Members'));
        end
        val = obj.pDatastoreInternal.MemberNames;
    end
    
    %Members
    %----------------------------------------------------------------------
    function set.Members(obj,val)
        if ~obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForFileCase','Members'));
        end
        % Error checking for members is done in the internal datastore
        try
            cachedDatastoreInternal = copy(obj.pDatastoreInternal);
            obj.pDatastoreInternal.Members = val;
            [flag,mssgObj] = validateTimePropertyDimensionsWithRespectToElements(obj);
            if ~flag
                obj.pDatastoreInternal = cachedDatastoreInternal;
                error(mssgObj);
            end
        catch e
            throw(e)
        end
    end
    
    function val = get.Members(obj)
        if ~obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForFileCase','Members'));
        end
        val = obj.pDatastoreInternal.getObservations();
    end
    
    %Files
    %----------------------------------------------------------------------
    function set.Files(obj,val)
        if obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForInMemoryCase','Files'));
        end
        try
            cachedDatastoreInternal = copy(obj.pDatastoreInternal);
            obj.pDatastoreInternal.Files = val;
            [flag,mssgObj] = validateTimePropertyDimensionsWithRespectToElements(obj);
            if ~flag
                obj.pDatastoreInternal = cachedDatastoreInternal;
                error(mssgObj);
            end
        catch e
            throw(e)
        end
    end
    
    function val = get.Files(obj)
        if obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForInMemoryCase','Files'));
        end
        val = obj.pDatastoreInternal.getObservations();
    end
    
    %AlternateFileSystemRoots
    %----------------------------------------------------------------------
    function set.AlternateFileSystemRoots(obj,aRoots)
        if obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForInMemoryCase','AlternateFileSystemRoots'));
        end
        try
            obj.pDatastoreInternal.AlternateFileSystemRoots = aRoots;
        catch ME
            throw(ME);
        end
    end
    
    function aRoots = get.AlternateFileSystemRoots(obj)
        if obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForInMemoryCase','AlternateFileSystemRoots'));
        end
        
        aRoots = string(obj.pDatastoreInternal.AlternateFileSystemRoots);
    end
    
    %ReadSize
    %----------------------------------------------------------------------
    function set.ReadSize(obj,val)
        obj.pDatastoreInternal.ReadSize = val;
    end
    
    function val = get.ReadSize(obj)
        val = obj.pDatastoreInternal.ReadSize;
    end
    
    %SignalVariableNames
    %----------------------------------------------------------------------
    function set.SignalVariableNames(obj,val)
        if obj.pCheckPropertiesFlag
            validateSetOfSignalVariableNamesProperty(obj);
        end
        
        if ischar(val) || iscellstr(val) %#ok<ISCLSTR>
            val = string(val);
        end
        validateattributes(val,["string","char","cellstr"],"vector",'signalDatastore',"SignalVariableNames");
        if isempty(val) || any(val == "")
            error(message('signal:signalDatastore:signalDatastore:InvalidEmptyVarName','SignalVariableNames'));
        end
        if numel(val) ~= numel(unique(val))
            error(message('signal:signalDatastore:signalDatastore:SignalVariableNamesNotUnique'));
        end
               
        obj.pSignalVariableNames = string(val);
        obj.pSignalVariableNames = obj.pSignalVariableNames(:)';
    end
    
    function val = get.SignalVariableNames(obj)
        validateGetOfSignalVariableNamesProperty(obj);
        val = obj.pSignalVariableNames;
    end
    
    %SampleRateVariableName
    %----------------------------------------------------------------------
    function set.SampleRateVariableName(obj,val)
        if obj.pCheckPropertiesFlag
            validateSetOfTimeFromFileProperty(obj,"SampleRateVariableName");
        end
        
        val = validateStringScalar(obj,val,"SampleRateVariableName");
        obj.pSampleRateVariableName = val;
        obj.pTimeInformationPropertyName = "SampleRateVariableName";
        obj.pTimeInformationName = "SampleRate";
    end
    
    function val = get.SampleRateVariableName(obj)
        validateGetOfTimeFromFileProperty(obj,"SampleRateVariableName");
        val = obj.pSampleRateVariableName;
    end
    
    %SampleTimeVariableName
    %----------------------------------------------------------------------
    function set.SampleTimeVariableName(obj,val)
        if obj.pCheckPropertiesFlag
            validateSetOfTimeFromFileProperty(obj,"SampleTimeVariableName");
        end
        
        val = validateStringScalar(obj,val,"SampleTimeVariableName");
        obj.pSampleTimeVariableName = val;
        obj.pTimeInformationPropertyName = "SampleTimeVariableName";
        obj.pTimeInformationName = "SampleTime";
    end
    
    function val = get.SampleTimeVariableName(obj)
        validateGetOfTimeFromFileProperty(obj,"SampleTimeVariableName");
        val = obj.pSampleTimeVariableName;
    end
    
    %TimeValuesVariableName
    %----------------------------------------------------------------------
    function set.TimeValuesVariableName(obj,val)
        if obj.pCheckPropertiesFlag
            validateSetOfTimeFromFileProperty(obj,"TimeValuesVariableName");
        end
        
        val = validateStringScalar(obj,val,"TimeValuesVariableName");        
        obj.pTimeValuesVariableName = val;
        obj.pTimeInformationPropertyName = "TimeValuesVariableName";
        obj.pTimeInformationName = "TimeValues";
    end
    
    function val = get.TimeValuesVariableName(obj)
        validateGetOfTimeFromFileProperty(obj,"TimeValuesVariableName");
        val = obj.pTimeValuesVariableName;
    end
    
    %SampleRate
    %----------------------------------------------------------------------
    function set.SampleRate(obj,val)
        if obj.pCheckPropertiesFlag
            validateSetOfTimeProperty(obj,val,"SampleRate");
        end
        obj.pSampleRate = val(:);
        obj.pTimeInformationPropertyName = "SampleRate";
        obj.pTimeInformationName = "SampleRate";
    end
    
    function val = get.SampleRate(obj)
        validateGetOfTimeProperty(obj,"SampleRate");
        val = obj.pSampleRate;
    end
    
    %SampleTime
    %----------------------------------------------------------------------
    function set.SampleTime(obj,val)
        if obj.pCheckPropertiesFlag
            validateSetOfTimeProperty(obj,val,"SampleTime");
        end
        obj.pSampleTime = val(:);
        obj.pTimeInformationPropertyName = "SampleTime";
        obj.pTimeInformationName = "SampleTime";
    end
    
    function val = get.SampleTime(obj)
        validateGetOfTimeProperty(obj,"SampleTime");
        val = obj.pSampleTime;
    end
    
    %TimeValues
    %----------------------------------------------------------------------
    function set.TimeValues(obj,val)
        if obj.pCheckPropertiesFlag
            validateSetOfTimeProperty(obj,val,"TimeValues");
        end
        if isrow(val)
            val = val(:);                    
        end                    
        obj.pTimeValues = val;
        obj.pTimeInformationPropertyName = "TimeValues";
        obj.pTimeInformationName = "TimeValues";
    end
    
    function val = get.TimeValues(obj)
        validateGetOfTimeProperty(obj,"TimeValues");
        val = obj.pTimeValues;
    end
    
    %ReadFcn
    %----------------------------------------------------------------------
    function set.ReadFcn(obj,val)
        if obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForInMemoryCase','ReadFcn'));
        end
        if obj.pIsReadFcnDefault
            error(message('signal:signalDatastore:signalDatastore:InvalidReadFcnWhenReadFcnIsDefault'));
        end
        
        try
            cacheReadFcn = obj.pDatastoreInternal.ReadFcn;
            obj.pDatastoreInternal.ReadFcn = val;
        catch ME
            throw(ME);
        end
        [flag,mssgObj] = validateCustomReadFcn(obj,val);
        if ~flag
            obj.pDatastoreInternal.ReadFcn = cacheReadFcn;
            error(mssgObj);
        end
    end
    
    function val = get.ReadFcn(obj)
        if obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForInMemoryCase','ReadFcn'));
        end
        if obj.pIsReadFcnDefault
            error(message('signal:signalDatastore:signalDatastore:InvalidReadFcnWhenReadFcnIsDefault'));
        end
        val = obj.pDatastoreInternal.ReadFcn;
    end
end

methods (Access = private)
    %----------------------------------------------------------------------
    function setIsReadFcnDefault(obj,readFcn)
        fcnInfo = functions(readFcn);
        pvtFile = fullfile(fileparts(mfilename('fullpath')), 'private', 'readDatastoreSignalFromFile.m');
        tf = isfield(fcnInfo, 'file') && isequal(fcnInfo.file, pvtFile);
        obj.pIsReadFcnDefault = tf && isfield(fcnInfo, 'parentage') && isequal(fcnInfo.parentage, {'readDatastoreSignalFromFile'});
    end
    
    %----------------------------------------------------------------------
    function [readFun, fileExtensions] = getDefaultReadFunction(obj,fileExtensions)
        
        fileExtensions = string(fileExtensions);
        
        if fileExtensions == ".mat"
            % Pass in the signal variable name, the time information name
            % (i.e. SampleRate, SampleTime, TimeValues), and the property
            % value.
            if isempty(obj.pTimeInformationPropertyName) || any(obj.pTimeInformationPropertyName == ["SampleRate","SampleTime","TimeValues"])
                readFun = @(x)signal.internal.datastore.readDatastoreSignalFromMAT(...
                    x,obj.pSignalVariableNames,[],[]);
            else
                readFun = @(x)signal.internal.datastore.readDatastoreSignalFromMAT(...
                    x,obj.pSignalVariableNames,obj.pTimeInformationName,getTimeInformationValue(obj));
            end
        elseif fileExtensions == ".csv"
            % Pass in the signal variable name, the time information name
            % (i.e. SampleRate, SampleTime, TimeValues), and the value
            if isempty(obj.pTimeInformationPropertyName) || any(obj.pTimeInformationPropertyName == ["SampleRate","SampleTime","TimeValues"])
                readFun = @(x)signal.internal.datastore.readDatastoreSignalFromCSV(...
                    x,obj.pSignalVariableNames,[],[]);
            else
                readFun = @(x)signal.internal.datastore.readDatastoreSignalFromCSV(...
                    x,obj.pSignalVariableNames,obj.pTimeInformationName,getTimeInformationValue(obj));
            end
        else
            % Other file extensions will be serviced by data stores that
            % contain a read function internally so just return an empty
            % read function.
            readFun = [];
        end
    end
    
    %----------------------------------------------------------------------
    function value = getTimeInformationValue(obj)
        value = [];
        if ~isempty(obj.pTimeInformationPropertyName)
            value = obj.(obj.pTimeInformationPropertyName);
        end
    end
    
    %----------------------------------------------------------------------
    function nv = initDatastore(obj,nv)
        specifiedProperties = setdiff(nv.AllParameters,nv.UsingDefaults,'stable');
        % Set the rest of the specified properties. Exclude parameters that
        % are set in the internal datastores or parameters that are not
        % properties.
        specifiedProperties(ismember(specifiedProperties,["MemberNames","ReadFcn","FileExtensions","IncludeSubfolders","AlternateFileSystemRoots"])) = [];
        
        % Defer checking time property dimensions until we have an internal
        % datastore and we can check that dimensions are compatible with
        % the number of members or files
        c = onCleanup(@() obj.resetCheckPropertiesFlag);
        obj.pCheckPropertiesFlag = false;
        
        for idx = 1:numel(specifiedProperties)
            prop = specifiedProperties(idx);
            obj.(prop) = nv.(prop);
        end
        
        if ~obj.pInMemoryFlag && obj.pIsReadFcnDefault
            nv.ReadFcn = getDefaultReadFunction(obj,nv.FileExtensions);
        end
        
        obj.pSchemaVersion = version('-release');
    end
    
    %----------------------------------------------------------------------
    function resetCheckPropertiesFlag(obj)
        obj.pCheckPropertiesFlag = true;
    end
    
    %----------------------------------------------------------------------
    function validateProperties(obj,nv)
        specifiedProperties = setdiff(nv.AllParameters,nv.UsingDefaults,'stable');
        
        propIdx = ismember(specifiedProperties,"SignalVariableNames");
        if any(propIdx)            
            validateSetOfSignalVariableNamesProperty(obj);
        end
        propIdx = ismember(specifiedProperties,["SampleRateVariableName","SampleTimeVariableName","TimeValuesVariableName"]);
        if any(propIdx)
            prop = specifiedProperties(propIdx);
            validateSetOfTimeFromFileProperty(obj,prop);
        end
        propIdx = ismember(specifiedProperties,["SampleRate","SampleTime","TimeValues"]);
        if any(propIdx)
            prop = specifiedProperties(propIdx);
            validateSetOfTimeProperty(obj,nv.(prop),prop);
        end
    end
    
    %----------------------------------------------------------------------
    function parseInputSource(obj,src)
        if isempty(src)
            % Empty files or members case
            error(message('signal:signalDatastore:signalDatastore:InvalidEmptySource'));
        end
        
        if iscell(src)
            if iscellstr(src)
                % File data
                obj.pInMemoryFlag = false;
            else
                % In-memory data
                obj.pInMemoryFlag = true;
            end
        elseif ischar(src) || isstring(src)
            % File data
            obj.pInMemoryFlag = false;
        elseif isa(src,'matlab.io.datastore.DsFileSet')
            obj.pInMemoryFlag = false;
        else
            error(message('signal:signalDatastore:signalDatastore:InvalidSource'));
        end
    end
    
    %----------------------------------------------------------------------
    function parsedStruct = iParseNameValues(~,varargin)
        persistent inpP;
        if isempty(inpP)
            inpP = inputParser;
            addParameter(inpP, 'MemberNames',[]);
            addParameter(inpP, 'IncludeSubfolders',false);
            addParameter(inpP, 'AlternateFileSystemRoots', {});
            addParameter(inpP, 'FileExtensions',-1);
            addParameter(inpP, 'ReadSize', 1);
            
            addParameter(inpP, 'SignalVariableNames', []);
            addParameter(inpP, 'SampleRateVariableName', []);
            addParameter(inpP, 'SampleTimeVariableName', []);
            addParameter(inpP, 'TimeValuesVariableName', []);
            
            addParameter(inpP,'SampleRate',[]);
            addParameter(inpP,'SampleTime',[]);
            addParameter(inpP,'TimeValues',[]);
            
            addParameter(inpP, 'ReadFcn', []);
            
            inpP.FunctionName = signalDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME;
        end
        
        parse(inpP, varargin{:});
        parsedStruct = inpP.Results;
        parsedStruct.AllParameters = string(inpP.Parameters);
        parsedStruct.UsingDefaults = string(inpP.UsingDefaults);
    end
    
    %----------------------------------------------------------------------
    function nv = validateNameValues(obj,nv,src)
        import matlab.io.datastore.internal.validators.validateFileExtensions;
        import matlab.io.datastore.internal.fileset.ResolvedFileSetFactory;
        
        if obj.pInMemoryFlag
            % IN-MEMORY DATASTORE CASE
            
            % Do not allow file related inputs if we have in-memory data
            
            % All file-related properties must be in the UsingDefaults
            % array which means that none of those properties were
            % specified by the user.
            idx = ismember(obj.pFileRelatedOnlyInputNames,nv.UsingDefaults);
            if ~all(idx)
                specifiedProps = joinPropertyNamesForError(obj,obj.pFileRelatedOnlyInputNames(~idx));
                error(message('signal:signalDatastore:signalDatastore:FileRelatedInputsForInMemoryCase',specifiedProps));
            end
            
            % Do not allow specification of conflicting time properties
            props = ["SampleRate","SampleTime","TimeValues"];
            idx = ismember(props,nv.UsingDefaults);
            if sum(idx) < numel(props)-1
                specifiedProps = joinPropertyNamesForError(obj,props(idx));
                error(message('signal:signalDatastore:signalDatastore:SimultaneousTimeValues',specifiedProps));
            end
        else
            % FILE DATASTORE CASE
            
            % Do not allow in-memory related inputs if we have file data
            idx = ismember(obj.pInMemoryRelatedOnlyInputNames,nv.UsingDefaults);
            if ~all(idx)
                specifiedProps = joinPropertyNamesForError(obj,obj.pInMemoryRelatedOnlyInputNames(~idx));
                error(message('signal:signalDatastore:signalDatastore:InMemoryInputsForFileCase',specifiedProps));
            end
            
            % Verify FileExtensions - if specified but empty, set it back
            % to -1 and add it to the using defaults string so that
            % internal datastore parses the files correctly
            isFileExtensionsNotSpecified = validateFileExtensions(nv.FileExtensions, nv.UsingDefaults);
            
            if ismember("ReadFcn",nv.UsingDefaults)
                % When no read function was specified, only one file
                % extension can be specified. If no file extension was
                % specified then it should default to the first type of
                % files found in the list of supported files.
                if isFileExtensionsNotSpecified
                    
                    nvTest = nv;
                    nvTest.UsingDefaults(nvTest.UsingDefaults == 'FileExtensions') = [];
                    if  isa(src,'matlab.io.datastore.DsFileSet')
                        src = matlab.io.datastore.FileBasedDatastore.convertFileSetToFiles(src);
                    end
                    successFlag = false;
                    for idx = 1:numel(obj.pListOfSupportedDefaultReadFiles)
                        nvTest.FileExtensions = char(obj.pListOfSupportedDefaultReadFiles(idx));
                        % Try to get files with each default extension
                        % until files of the desired extension are found.
                        % We need to catch errors because buildCompressed
                        % errors out if no files are found.
                        try
                            files = ResolvedFileSetFactory.buildCompressed(src, nvTest);                            
                        catch ME
                            if string(ME.identifier) == "MATLAB:datastoreio:filebaseddatastore:fileExtensionsNotPresent"
                                continue;
                            else
                                throw(ME);
                            end
                        end
                        if ~isempty(files)
                            nv.FileExtensions = nvTest.FileExtensions;
                            nv.UsingDefaults(nv.UsingDefaults == "FileExtensions") = [];
                            successFlag = true;
                            break;
                        end
                    end
                    
                    if ~successFlag
                        error(message('signal:signalDatastore:signalDatastore:DefaultFilesNotFound'));
                    end
                elseif ~isscalar(string(nv.FileExtensions))
                    error(message('signal:signalDatastore:signalDatastore:InvalidFileExtensionsForDefaultRead'));
                end
                obj.pIsReadFcnDefault = true;
            else
                obj.pIsReadFcnDefault = false;
                % Do not allow var name properties or time info properties
                % if a read function was specified
                props = ["SignalVariableNames","SampleRateVariableName",...
                    "SampleTimeVariableName","TimeValuesVariableName",...
                    "SampleRate","SampleTime","TimeValues"];
                idx = ismember(props,nv.UsingDefaults);
                if ~all(idx)
                    specifiedProps = joinPropertyNamesForError(obj,props(~idx));
                    error(message('signal:signalDatastore:signalDatastore:ReadFcnPlusVarNameOrTimeProps',specifiedProps));
                end
            end
            % Do not specify more than one time variable simultaneously
            props = ["SampleRateVariableName","SampleTimeVariableName",...
                "TimeValuesVariableName","SampleRate","SampleTime","TimeValues"];
            
            idx = ismember(props,nv.UsingDefaults);
            if sum(idx) < numel(props)-1
                specifiedProps = joinPropertyNamesForError(obj,props(idx));
                error(message('signal:signalDatastore:signalDatastore:SimultaneousTimeValues',specifiedProps));
            end
        end
    end
    
    %----------------------------------------------------------------------
    function validateSetOfSignalVariableNamesProperty(obj)
        
        if obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForInMemoryCase','SignalVariableNames'));
        end
        
        if ~obj.pIsReadFcnDefault
            error(message('signal:signalDatastore:signalDatastore:InvalidProperty','SignalVariableNames','ReadFcn'));
        end
                
        if isempty(obj.pSignalVariableNames)
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyInThisConfig','SignalVariableNames'));
        end       
    end
    
    %----------------------------------------------------------------------
    function validateGetOfSignalVariableNamesProperty(obj)
        
        if obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForInMemoryCase','SignalVariableNames'));
        end
        
        if ~obj.pIsReadFcnDefault
            error(message('signal:signalDatastore:signalDatastore:InvalidProperty','SignalVariableNames','ReadFcn'));
        end
        
        if isempty(obj.pSignalVariableNames)
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyInThisConfig','SignalVariableNames'));
        end
    end
    
    %----------------------------------------------------------------------
    function validateSetOfTimeFromFileProperty(obj,propName)
        
        if obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForInMemoryCase',propName));
        end
        
        if ~obj.pIsReadFcnDefault
            error(message('signal:signalDatastore:signalDatastore:InvalidProperty',propName,'ReadFcn'));
        end
        
        currentSpec = obj.pTimeInformationPropertyName;
        if isempty(currentSpec)
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyInThisConfig',propName));
        elseif currentSpec ~= propName
            error(message('signal:signalDatastore:signalDatastore:InvalidProperty',propName,currentSpec));
        end                
    end
    
    %----------------------------------------------------------------------    
    function val = validateStringScalar(~,val,propName)
        if ischar(val)
            val = string(val);
        end
        validateattributes(val,["string","char"],"scalar",'signalDatastore',"SampleRateVariableName");
        if isempty(val) || val == ""
            error(message('signal:signalDatastore:signalDatastore:InvalidEmptyVarName',propName));
        end
    end
    
    
    %----------------------------------------------------------------------
    function validateGetOfTimeFromFileProperty(obj,propName)
        if obj.pInMemoryFlag
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyForInMemoryCase',propName));
        end
        if ~obj.pIsReadFcnDefault
            error(message('signal:signalDatastore:signalDatastore:InvalidProperty',propName,'ReadFcn'));
        end
        
        currentSpec = obj.pTimeInformationPropertyName;
        if isempty(currentSpec)
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyInThisConfig',propName));
        elseif currentSpec ~= propName
            error(message('signal:signalDatastore:signalDatastore:InvalidProperty',propName,currentSpec));
        end
    end
    
    %----------------------------------------------------------------------
    function validateSetOfTimeProperty(obj,val,propName)
        
        if ~obj.pIsReadFcnDefault
            error(message('signal:signalDatastore:signalDatastore:InvalidProperty',propName,'ReadFcn'));
        end
        
        currentSpec = obj.pTimeInformationPropertyName;
        if isempty(currentSpec)
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyInThisConfig',propName));
        elseif currentSpec ~= propName
            error(message('signal:signalDatastore:signalDatastore:InvalidProperty',propName,currentSpec));
        end
        
        if propName == "SampleRate"
            validateattributes(val,"numeric",["positive","vector","finite","nonempty"],'signalDatastore',"SampleRate");
            if ~isscalar(val)
                if length(val) ~= numobservations(obj)
                    error(message('signal:signalDatastore:signalDatastore:InvalidSampleRateDims'));
                end
            end
            
        elseif propName == "SampleTime"
            validateattributes(val,["numeric","duration"],["vector","nonempty"],'signalDatastore',"SampleTime");
            if isduration(val)
                val = seconds(val);
            end
            validateattributes(val,"numeric",["positive","finite"],'signalDatastore',"SampleTime");
            if ~isscalar(val)
                if length(val) ~= numobservations(obj)
                    error(message('signal:signalDatastore:signalDatastore:InvalidSampleTimeDims'));
                end
            end
            
        elseif propName == "TimeValues"
            if isnumeric(val) || isduration(val)
                validateattributes(val,["numeric","duration"],["2d","real","finite","nonempty"],'signalDatastore',"TimeValues");
            elseif iscell(val)
                % Must be a Nx1 cell array, N > 0
                if ~isvector(val) || isempty(val)
                    error(message('signal:signalDatastore:signalDatastore:InvalidTimeValuesDims'));
                end
            else     
                error(message('signal:signalDatastore:signalDatastore:InvalidTimeValuesDims'));
            end
            
            % Check dimensions
            if iscell(val)
                if numel(val) ~= numobservations(obj)
                    error(message('signal:signalDatastore:signalDatastore:InvalidTimeValuesDims'));
                end
                % Check that cell array contains numeric vectors
                flags = cellfun(@(x)(isnumeric(x) && isvector(x) && isreal(x)),val);
                if ~all(flags)
                    error(message('signal:signalDatastore:signalDatastore:InvalidTimeValuesCell'));
                end
            else
                if ~isvector(val)
                    if size(val,2) ~= numobservations(obj)
                        error(message('signal:signalDatastore:signalDatastore:InvalidTimeValuesDims'));
                    end
                end
            end
        end
    end
    
    %----------------------------------------------------------------------
    function validateGetOfTimeProperty(obj,propName)
        if ~obj.pIsReadFcnDefault
            error(message('signal:signalDatastore:signalDatastore:InvalidProperty',propName,'ReadFcn'));
        end
        
        currentSpec = obj.pTimeInformationPropertyName;
        if isempty(currentSpec)
            error(message('signal:signalDatastore:signalDatastore:InvalidPropertyInThisConfig',propName));
        elseif currentSpec ~= propName
            error(message('signal:signalDatastore:signalDatastore:InvalidProperty',propName,currentSpec));
        end
        
    end
    
    function [flag,mssgObj] = validateTimePropertyDimensionsWithRespectToElements(obj)
        % Verify if number of members is compatible with any
        % specified time property 'SampleRate', 'SampleTime', or
        flag = true;
        mssgObj = [];
        % 'TimeValues'
        timePropName = 'none';
        if ~isempty(obj.pTimeInformationPropertyName)
            timePropName = obj.pTimeInformationPropertyName;
            timePropValue = obj.(timePropName);
        end
        if timePropName == "SampleRate"
            if ~isscalar(timePropValue)
                if length(timePropValue) ~= numobservations(obj)
                    flag = false;
                    mssgObj = message('signal:signalDatastore:signalDatastore:InvalidFileDimsForSampleRate');
                end
            end
            
        elseif timePropName == "SampleTime"
            if ~isscalar(timePropValue)
                if length(timePropValue) ~= numobservations(obj)
                    flag = false;
                    mssgObj = message('signal:signalDatastore:signalDatastore:InvalidFileDimsForSampleTime');
                end
            end
            
        elseif timePropName == "TimeValues"
            if ~isvector(timePropValue)
                if size(timePropValue,2) ~= numobservations(obj)
                    flag = false;
                    mssgObj = message('signal:signalDatastore:signalDatastore:InvalidFileDimsForTimeValues');
                end
            end
        end
    end
    
    %----------------------------------------------------------------------
    function [flag, mssgObj] = validateCustomReadFcn(obj,fcnHandle)
        % Try to read one file and see if there are no errors and if the
        % second output is a structure.
        flag = true;
        mssgObj = [];
        try
            [~,I] = fcnHandle(obj.pDatastoreInternal.Files{1});
        catch ME
            flag = false;
            mssgObj = message('signal:signalDatastore:signalDatastore:CustomReadFcnError',ME.message);
            return;
        end
        if ~isstruct(I)
            flag = false;
            mssgObj = message('signal:signalDatastore:signalDatastore:InvalidCustomReadFcn');
        end
    end
    %----------------------------------------------------------------------
    function str = joinPropertyNamesForError(~,inputStringArray)
        str = "'" + join(inputStringArray,"', '") + "'";
    end
end

methods (Access = protected)
    %----------------------------------------------------------------------
    function n = maxpartitions(obj)
        n = maxpartitions(obj.pDatastoreInternal);
    end
    
    %----------------------------------------------------------------------
    % Display
    %----------------------------------------------------------------------
    function displayScalarObject(obj)
        % header
        disp(getHeader(obj));
        group = getPropertyGroups(obj);
        displayElements(obj,group);
        matlab.mixin.CustomDisplay.displayPropertyGroups(obj, group);
        disp(getFooter(obj));
    end
    
    function displayElements(obj,group)
        maxLen = 0;
        if obj.pInMemoryFlag
            varName = 'MemberNames:';
        else
            varName = 'Files:';
        end
        for idx = 1:numel(group.PropertyList)
            if length(char(group.PropertyList(idx))) > maxLen
                maxLen = length(char(group.PropertyList(idx)));
            end
        end
        if obj.pInMemoryFlag && length(varName) > maxLen
            maxLen = 5;
        end
        elementsIndent = [repmat(' ',1,maxLen-1) varName];
        nlspacing = sprintf(repmat(' ',1,numel(elementsIndent)));
        str = obj.pDatastoreInternal.getElementsForDisplay(signalDatastore.MAX_FILE_SIZE_FOR_DISPLAY,nlspacing);
        disp([elementsIndent str]);
        
    end
    
    function propgrp = getPropertyGroups(obj)
        propList = obj.pDisplayPropertyList;
        if obj.pInMemoryFlag
            propList(propList == 'AlternateFileSystemRoots') = [];
        else
            propList(propList == 'Members') = [];
        end
        
        if obj.pInMemoryFlag || obj.pIsReadFcnDefault
            propList(propList == 'ReadFcn') = [];
        end
        
        if obj.pInMemoryFlag || ~obj.pIsReadFcnDefault || isempty(obj.pSignalVariableNames)
            propList(propList == 'SignalVariableNames') = [];
        end
        if obj.pInMemoryFlag || ~obj.pIsReadFcnDefault || isempty(obj.pSampleRateVariableName)
            propList(propList == 'SampleRateVariableName') = [];
        end
        if obj.pInMemoryFlag || ~obj.pIsReadFcnDefault || isempty(obj.pSampleTimeVariableName)
            propList(propList == 'SampleTimeVariableName') = [];
        end
        if obj.pInMemoryFlag || ~obj.pIsReadFcnDefault || isempty(obj.pTimeValuesVariableName)
            propList(propList == 'TimeValuesVariableName') = [];
        end
        
        if ~obj.pIsReadFcnDefault || isempty(obj.pSampleRate)
            propList(propList == 'SampleRate') = [];
        end
        if ~obj.pIsReadFcnDefault || isempty(obj.pSampleTime)
            propList(propList == 'SampleTime') = [];
        end
        if ~obj.pIsReadFcnDefault || isempty(obj.pTimeValues)
            propList(propList == 'TimeValues') = [];
        end
        propgrp = matlab.mixin.util.PropertyGroup(propList);
    end
    
    %----------------------------------------------------------------------
    % Copy
    %----------------------------------------------------------------------
    function cp = copyElement(obj)
        % Deep copy of datastore
        cp = copyElement@matlab.mixin.Copyable(obj);
        cp.pDatastoreInternal = copy(obj.pDatastoreInternal);
    end
end

methods (Static, Hidden)
    %----------------------------------------------------------------------
    function defaultExtensions = getDefaultExtensions()
        % Get formats specific extensions
        defaultExtensions = {'.mat','.csv'};
    end
    
    %----------------------------------------------------------------------
    function varargout = supportsLocation(loc, nvStruct)
        % This function is responsible for determining whether a given
        % location is supported by Datastore. It also returns a
        % resolved filelist.
        import matlab.io.datastore.internal.lookupAndFilterExtensions;
        import signalDatastore;
        nvStruct.ForCompression = true;
        [varargout{1:nargout}] = lookupAndFilterExtensions(loc, nvStruct, signalDatastore.getDefaultExtensions);
    end
end
end
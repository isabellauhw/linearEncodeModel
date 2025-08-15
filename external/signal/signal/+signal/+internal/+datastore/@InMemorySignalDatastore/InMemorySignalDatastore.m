classdef InMemorySignalDatastore < ...
        matlab.io.Datastore & ...        
        matlab.io.datastore.Partitionable & ...        
        matlab.io.datastore.Shuffleable & ...
        matlab.io.datastore.mixin.Subsettable & ...
        matlab.mixin.CustomDisplay
%InMemorySignalDatastore Datastore for a collection of in-memory signals. 
%For internal use only. It may be removed.
%
%   InMemorySignalDatastore Properties:
%
%   Members  - Cell array containing signal data
%   MembersNames  - Cell array containing member names
%   ReadSize - Read size
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
    
% Copyright 2019 The MathWorks, Inc.
    
properties
    % ReadSize
    ReadSize = 1;
end

properties (Dependent)
    % Members
    Members;
    % Member names
    MemberNames;
end

properties (Access = private)
    % To help support future forward compatibility.  The value
    % indicates the version of MATLAB.
    SchemaVersion;
    % pCurrentMemberIndex Index of the current member being read
    pCurrentMemberIndex = 0
    % pNextMember Next member to read
    pNextMember = [];
    % pDisplayPropertyList
    pDisplayPropertyList = ["Members";"ReadSize"];
    % pMembers
    pMembers = [];
    % pMemberNames
    pMemberNames 
end

properties (Constant, Access = private)
    CONVENIENCE_CONSTRUCTOR_FCN_NAME = 'signal.internal.datastore.InMemorySignalDatastore';
    MAX_FILE_SIZE_FOR_DISPLAY = 3;
end

methods
    %----------------------------------------------------------------------
    function obj = InMemorySignalDatastore(members,varargin)
        [varargin{:}] = convertStringsToChars(varargin{:});
        nv = iParseNameValues(obj,varargin{:});
        initDatastore(obj,members,nv);        
    end
    
    %----------------------------------------------------------------------
    function frac = progress(obj)
        %PROGRESS  Returns the fraction of members read        
        frac = obj.pCurrentMemberIndex/numobservations(obj);
    end
end

%--------------------------------------------------------------------------
% SET/GET Methods
%--------------------------------------------------------------------------
methods
   %Members
    %----------------------------------------------------------------------
    function set.Members(obj, val)
        validateMembersType(obj,val);
        if numel(val) ~= numobservations(obj)
            error(message('signal:signalDatastore:InMemorySignalDatastore:InvalidMemberSet'))
        end
        obj.pMembers = val(:);
    end
    
    function val = get.Members(obj)
        val = obj.pMembers;
    end
    
   %MemberNames
    %----------------------------------------------------------------------
    function set.MemberNames(obj, val)        
        val = validateMemberNamesType(obj,val);
        if numel(val) ~= numobservations(obj)
            error(message('signal:signalDatastore:InMemorySignalDatastore:InvalidMembersAndNamesDimensions'))
        end        
        obj.pMemberNames = val(:);
    end
    
    function val = get.MemberNames(obj)
        val = obj.pMemberNames;
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
    function setMembersAndMemberNames(obj,members,memberNames)
        % Set members and memberNames simultaneously
        validateMembersType(obj,members);
        memberNames = validateMemberNamesType(obj,memberNames);
        obj.pMemberNames = memberNames(:);
        obj.pMembers = members;
        reset(obj);
    end
    %----------------------------------------------------------------------
    function data = getObservations(obj)
        % For an in-memory datatore this means getting the members
        data = obj.pMembers;
    end
    
    %----------------------------------------------------------------------
    function n = numobservations(obj)
        % For an in-memory datatore this means getting number of members
        n = numel(obj.pMembers);
    end
    
    %----------------------------------------------------------------------
    function str = getElementsForDisplay(obj,maxNumElementsToDisplay,nlspacing)
        import matlab.io.internal.cellArrayDisp;
        if numobservations(obj) == 0
            memberNames = obj.pMemberNames;
            str = cellArrayDisp(memberNames, true, 0, 0);
        else
            if numobservations(obj) >= maxNumElementsToDisplay
                % Get only maxNumElementsToDisplay members.
                indices = 1:maxNumElementsToDisplay;
                memberNames = obj.pMemberNames(indices);
            else
                memberNames = obj.pMemberNames;
            end
            str = cellArrayDisp(memberNames, true, nlspacing, numobservations(obj));
        end
    end       
end

methods (Access = private)
    %----------------------------------------------------------------------    
    function initDatastore(obj, members, nv)
                  
        % Set members before calling setDefaultMemberNames
        validateMembersType(obj,members);
        obj.pMembers = members(:);
        if isempty(nv.MemberNames)
            setDefaultMemberNames(obj);
        else
            memberNames = validateMemberNamesType(obj,nv.MemberNames);
            if numel(memberNames) ~= numel(members)
                error(message('signal:signalDatastore:InMemorySignalDatastore:InvalidMembersAndNamesDimensions'))
            end
            obj.pMemberNames = memberNames(:);   
        end        
        obj.ReadSize = nv.ReadSize;
        % Set the schema version
        obj.SchemaVersion = version('-release');
    end
    
    %----------------------------------------------------------------------
    function validateMembersType(~,members)
        validateattributes(members,{'cell'},{});        
        if ~isempty(members) && iscellstr(members) %#ok<ISCLSTR>
            error(message('signal:signalDatastore:InMemorySignalDatastore:InvalidMembersType'));
        end        
    end
    
    %----------------------------------------------------------------------
    function memberNames = validateMemberNamesType(~,memberNames)
        if ischar(memberNames) || iscellstr(memberNames) %#ok<ISCLSTR>
            memberNames = string(memberNames);
        end
        validateattributes(memberNames,["string","char","cellstr"],"vector",'signalDatastore',"MemberNames");
        
        if isempty(memberNames) || any(memberNames == "")
            error(message('signal:signalDatastore:InMemorySignalDatastore:InvalidEmptyVarName'));
        end
        
        % Hold the value as a cell string
        memberNames = cellstr(memberNames);
    end
            
    %----------------------------------------------------------------------
    function setDefaultMemberNames(obj)
        obj.pMemberNames = cell(numobservations(obj),1);
        for idx = 1:numobservations(obj)
            obj.pMemberNames{idx} = ['Member', num2str(idx)];
        end
    end
end

methods (Access = protected)    
    %----------------------------------------------------------------------
    function n = maxpartitions(obj)
        n = numobservations(obj);
    end    
    %----------------------------------------------------------------------
    function setNextMember(obj)
        if numobservations(obj) == 0
            return;
        end
        obj.pNextMember = obj.pMemberNames{obj.pCurrentMemberIndex + 1};
    end
    
    %------------------------------------------------------------------
    function moveToNextMember(obj)
        %MOVETONEXTMEMBER Set up the datastore to read the next member.
        if numobservations(obj) == 0
            return;
        end
        
        % Set signal file reader to the next member
        setNextMember(obj);
        
        % Increment file counter        
        obj.pCurrentMemberIndex = obj.pCurrentMemberIndex + 1;
    end

    %----------------------------------------------------------------------  
    % Display
    %----------------------------------------------------------------------
    function displayScalarObject(obj)
        disp(getHeader(obj));
        group = getPropertyGroups(obj);  
        displayMembers(obj,group);
        matlab.mixin.CustomDisplay.displayPropertyGroups(obj, group);
        disp(getFooter(obj));
    end
    
    function displayMembers(obj,group)
        import signal.internal.datastore.InMemorySignalDatastore;
        maxLen = 0;
        for idx = 1:numel(group.PropertyList)
            if length(char(group.PropertyList(idx))) > maxLen
                maxLen = length(char(group.PropertyList(idx)));
            end
        end
        if length('MemberNames') > maxLen
            maxLen = 5;
        end
        membersIndent = [repmat(' ',1,maxLen-1) 'MemberNames:'];        
        nlspacing = sprintf(repmat(' ',1,numel(membersIndent)));
        str = obj.getElementsForDisplay(InMemorySignalDatastore.MAX_FILE_SIZE_FOR_DISPLAY,nlspacing);
        disp([membersIndent str]);
    end
    
    %----------------------------------------------------------------------  
    function propgrp = getPropertyGroups(obj)        
        propList = obj.pDisplayPropertyList; 
        propgrp = matlab.mixin.util.PropertyGroup(propList);
    end
end
end

function parsedStruct = iParseNameValues(~,varargin)
persistent inpP;
import signal.internal.datastore.InMemorySignalDatastore;
if isempty(inpP)
    inpP = inputParser;
    addParameter(inpP, 'MemberNames', []);
    addParameter(inpP, 'ReadSize', 1);
    inpP.FunctionName = InMemorySignalDatastore.CONVENIENCE_CONSTRUCTOR_FCN_NAME;
end
parse(inpP, varargin{:});
parsedStruct = inpP.Results;
end

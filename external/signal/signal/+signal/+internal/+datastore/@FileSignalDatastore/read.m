function [data, infoStruct] = read(obj)
%READ Read the next consecutive signal file
%For internal use only. It may be removed.
%
%   [SIG,INFO] = READ(SDS) returns a output SIG with a signal extracted
%   from the datastore, as well as INFO structure with signal time
%   information, and information about the origin of the data.

%   Copyright 2019-2020 The MathWorks, Inc.

if ~hasdata(obj)
    % Error if no more files are available to be read.
    error(message('signal:signalDatastore:FileSignalDatastore:NoMoreData'));
end

if obj.ReadSize == 1
    % Start reading from next file and if file is remote make a local copy.
    % The local copy is deleted automatically when fileNameObj is
    % destroyed. If file is local, no copy is created.
    moveToNextFile(obj); 
    fileNameObj = matlab.io.internal.vfs.stream.RemoteToLocal(obj.pNextFile);
    try
        [data, infoStruct] = obj.ReadFcn(fileNameObj.LocalFileName);
        %data = {data};
    catch ME
        if ~strcmpi(ME.identifier,'MATLAB:datastoreio:splittabledatastore:noMoreData')
            [data, infoStruct] = matlab.io.datastore.FileBasedDatastore.errorHandlerRoutine(...
                obj,ME,obj.pNextFile,obj.CurrentFileIndex,false);
            if isa(data,'MException')
                throwAsCaller(data);
            end
        else
            throwAsCaller(e);
        end
        if isempty(obj.SplitReader.Split)
            obj.SplitReader.ReadingDone = true;
        end
    end
    
    infoStruct.FileName = string(obj.pNextFile);
    infoStruct.ElementIndex = obj.CurrentFileIndex;
else        
    remainingNumFiles = numobservations(obj) - obj.CurrentFileIndex;
    numReads = min(remainingNumFiles, obj.ReadSize);
    data = cell(numReads,1);
    infoStruct = [];
    for idx = 1:numReads
        % Start reading from next file and if file is remote get a local
        % copy.
        moveToNextFile(obj); 
        fileNameObj = matlab.io.internal.vfs.stream.RemoteToLocal(obj.pNextFile);
        try
            [dataTmp, infoStructTmp] = obj.ReadFcn(fileNameObj.LocalFileName);
            data{idx} = dataTmp;            
        catch ME
            if ~strcmpi(ME.identifier,'MATLAB:datastoreio:splittabledatastore:noMoreData')
                [data, infoStruct] = matlab.io.datastore.FileBasedDatastore.errorHandlerRoutine(...
                    obj,ME,obj.pNextFile,obj.CurrentFileIndex,false);
                if isa(data,'MException')
                    throwAsCaller(data);
                end
            else
                throwAsCaller(e);
            end
            if isempty(obj.SplitReader.Split)
                obj.SplitReader.ReadingDone = true;
            end
        end        
        infoStructTmp.FileName = string(obj.pNextFile);
        infoStructTmp.ElementIndex = obj.CurrentFileIndex;                
        infoStruct = [infoStruct; infoStructTmp]; %#ok<AGROW>
    end        
end
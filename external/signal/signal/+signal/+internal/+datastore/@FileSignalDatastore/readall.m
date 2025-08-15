function data = readall(obj)
%READALL Reads all files from the datastore
%For internal use only. It may be removed.
%   SIGS = READALL(SDS) reads all of the files from SDS and returns a cell
%   array of signals.

%   Copyright 2019-2020 The MathWorks, Inc.

files = obj.Files;

data = cell(length(files),1);
% read all the data
origReadCounter = obj.PrivateReadCounter;
obj.PrivateReadCounter = true;
for idx = 1:length(files)
    try
        % If file is remote make a local copy. The local copy is deleted
        % automatically when fileNameObj is destroyed. If file is local, no
        % copy is created.
        fileNameObj = matlab.io.internal.vfs.stream.RemoteToLocal(files{idx});
        data{idx} = obj.ReadFcn(fileNameObj.LocalFileName);
    catch ME
        data{idx} = matlab.io.datastore.FileBasedDatastore.errorHandlerRoutine(...
            obj,ME,obj.pNextFile,idx,true);
        if isa(data{idx},'MException')
            throwAsCaller(data{idx});
        end
    end
end
obj.PrivateReadCounter = origReadCounter;
dispReadallWarning(obj);
end

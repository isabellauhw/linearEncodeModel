function reset(obj)
%RESET Resets the datastore to the start of the data
%For internal use only. It may be removed.

%   Copyright 209 The MathWorks, Inc.
try
    reset@matlab.io.datastore.internal.util.SubsasgnableFileSet(obj);
    updateNumSplits(obj.Splitter);
    reset@matlab.io.datastore.FileBasedDatastore(obj);
    
    obj.CurrentFileIndex = 0;
    
catch ME
    throw(ME);
end
end

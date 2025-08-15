function [fid,fileInfo] = openFile(filename)
%openFile function is used to open the file and return its file ID for reading its header
%
%   This function is for internal use only. It may change or be removed.

%   Copyright 2020 The MathWorks, Inc.

[tfid, errmsg] = fopen(filename,'r');

originalFilename = filename;
% fopen() returns -1 if file is not present
if tfid == -1
    % Look for filename with extensions.
    filename = [originalFilename '.edf'];
    [tfid, errmsg] = fopen(filename);
    
    if tfid == -1
        filename = [originalFilename '.EDF'];
        [tfid, errmsg] = fopen(filename);
    end
end

fid = tfid;

% Record filesystem details (fileInfo is empty object if the filename is
% not the same directory).
fileInfo = dir(filename);

% Get the fileInfo when the file is not in the same directory but it is in
% the matlab path.
if isempty(fileInfo) && tfid ~= -1
    filename =  fopen(fid);
    fileInfo = dir(filename);
end

% Error if file does not exists
if fid == -1
    if ~isempty(fileInfo)
        % String 'Too many open files' is from strerror. fopen() also
        % returns error messages as char output as per documentation which
        % we is now using for checking following error condition.
        if contains(errmsg, 'Too many open files')
            error(message('signal:edf:TooManyOpenFiles', originalFilename));
        else
            error(message('signal:edf:FileReadPermission', originalFilename));
        end
    elseif isempty(fileInfo)
        error(message('signal:edf:FileDoesNotExist', originalFilename));
    end
elseif ((fid ~= -1) && (fileInfo.bytes == 0))
    fclose(fid);
    error(message('signal:edf:ZeroFileSize', originalFilename));
end

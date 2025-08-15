function validateEDF(filename, fileInfo, version, startDate, startTime,...
    headerBytes, reserve, numDataRecords, numSignals,...
    sigLabels, numSamples, transducerType, physicalDimension,...
    physicalMinimum, physicalMaximum, digitalMinimum, digitalMaximum, ...
    prefilter, sigReserve, dataRecordDuration, mfile)
%validateEDF is used to validate EDF/EDF+ files
%
%   This function is for internal use only. It may change or be removed.

%   Copyright 2020 The MathWorks, Inc.

% Check whether version of data format is 0 or not
if ~(strcmpi(version,"0"))
    error(message('signal:edf:InvalidVersion', version, filename));
end

% Check startDate of EDF/EDF+ file is in 'dd.MM.yy' format or not
try
    datetime(startDate,'InputFormat','dd.MM.yy');
catch
    error(message('signal:edf:InvalidStartdate', filename));
end

% Check startTime of EDF/EDF+ file is in 'HH.mm.ss' format or not
try
    datetime(startTime,'InputFormat','HH.mm.ss');
catch
    error(message('signal:edf:InvalidStartTime', filename));
end

% Check numSamples has integer value
validateattributes(numSamples,{'numeric'},{'integer'},mfile);

% As per EDF/EDF+ spec file header has (256 + numSignals.*256) bytes
tExpectedHeaderbytes = (256 + numel(sigLabels).*256);

% Calculate file size based on header information as each sample value is
% represented as a 2-byte integer in 2's complement format as per EDF/EDF+
% spec
if numDataRecords ~= -1 && numDataRecords > 0
    tExpectedFileSize = (sum(numSamples).*numDataRecords.*2) + tExpectedHeaderbytes;
    
    % Check whether the file size is valid or not
    if tExpectedFileSize ~= fileInfo.bytes
        error(message('signal:edf:InvalidFileSize', fileInfo.bytes, tExpectedFileSize,...
            filename));
    end
end

% Check whether headerBytes field is valid or not
if tExpectedHeaderbytes ~= headerBytes
    error(message('signal:edf:InvalidHeaderBytes', filename,...
        tExpectedHeaderbytes));
end

% Check whether Reserved field is valid or not
reserve = validatestring(reserve,{'EDF+C','EDF+D',''},mfile,"Reserved");

% Check numDataRecords field is not -1 for EDF+ file
if ((~isempty(reserve) && numDataRecords <= 0) || ...
        (isempty(reserve) && (numDataRecords < -1)))
    error(message('signal:edf:InvalidDataRecord', filename));
end

% Check whether numSignals is equal to length of signalLabels
if (length(sigLabels) ~= numSignals)
    error(message('signal:edf:InvalidNumSignals', filename));
end

% Check whether the length of all the fields in the variable - header is
% numSignals or not
tExpectedLengths = {transducerType, physicalDimension,...
    physicalMinimum, physicalMaximum, digitalMinimum, digitalMaximum, ...
    prefilter, sigReserve, numSamples};
tLengthsIdx = cellfun(@length,tExpectedLengths) == numSignals;

if ~all(tLengthsIdx)
    error(message('signal:edf:HeaderDataMissing', filename));
end

% Check if the file is EDF and error out when dataRecordDuration is zero
if ((dataRecordDuration == 0) && isempty(reserve))
    error(message('signal:edf:ZeroDataRecordDuration'));
end

% Check number of samples values 
validateattributes(numSamples, {'numeric'}, {'numel', numSignals, ...
    'positive', 'nonnan'});



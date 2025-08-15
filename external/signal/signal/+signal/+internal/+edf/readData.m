function [annotations, data] = readData(fid,filename,siglabels,numDR,phymax,...
    phymin,dmax,dmin,ns,numsamp,signals,records,dataRecordDuration,infoflag)
%readData function is used to data and annotations of EDF/EDF+ files.
%
%   This function is for internal use only. It may change or be removed.

%   Copyright 2020 The MathWorks, Inc.

% Assuming data exist after the header
dataExist = true;
recordNum = 0;
recordIdx = 0;
data = {};
if (numDR ~= -1) && ~infoflag
    if (~isempty(records) && ~isempty(signals)) && (max(records) <= numDR)
        data = cell(numel(records), numel(signals));
    else
        error(message('signal:edf:InvalidDataRecordIdx', filename));
    end
end

annotationsIdx = find(strcmp(siglabels, 'EDF Annotations'),1);
if (isempty(annotationsIdx))
    annotationsIdx = -1;
    annotations = cell(1,1);
elseif (numDR ~= -1)
    annotations = cell(numDR,1);
else
    annotations = cell(1,1);
end

sc = (phymax - phymin) ./ (dmax - dmin);
dc = phymax - sc .* dmax;

% Run the loop until we reach end of file
while dataExist
    
    % We haven't reached the end of file, so assume data
    % is present and increment the record number.
    recordNum = recordNum+1;
    record_exist = any(recordNum == records);
    
    if (record_exist)
        recordIdx = recordIdx+1;
    end
    
    for ii = 1:ns
        
        % Find signal indices
        signalIdx = find(ii == signals,1);
        
        % Check if current signal is an annotation
        if (ii == annotationsIdx)
            annotations{recordNum} = fread(fid,numsamp(ii)*2,'*char').';
            if (isempty(annotations{recordNum}) && (dataRecordDuration == 0))
                annotations(recordNum) = [];
                dataExist = false;
                break;
            else
                continue;
            end
        elseif ((numDR == -1 || record_exist) && any(signalIdx))
            temp = fread(fid,numsamp(ii),'int16');
        else
            % If seeking is unsuccessful, assume we
            % reached the end of file
            if (fseek(fid,numsamp(ii)*2,'cof') == -1)
                dataExist = false;
                break;
            else
                continue;
            end
        end
        
        % if the data read is empty, then assume we reached
        % end of file.
        if (isempty(temp))
            dataExist = false;
            break;
        elseif (record_exist)
            data{recordIdx,signalIdx} = temp*sc(ii)+dc(ii);
        elseif (isempty(records))
            data{recordNum,signalIdx} = temp*sc(ii)+dc(ii);
        end
    end
end
end

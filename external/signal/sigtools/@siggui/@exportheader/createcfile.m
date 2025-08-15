function createcfile(h, s)
%CREATECFILE Create a cfile given the data in s

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

fid = fopen(s.file,'wt');
if fid == -1
    error(message('signal:siggui:exportheader:createcfile:invalidFid'));
end
tbx = 'signal';
if isfdtbxinstalled && isprop(h.Filter, 'Arithmetic')
    if ~strcmpi(h.Filter.Arithmetic, 'double')
        tbx = 'dsp';
    end
end

exportcoeffgen(s, fid, tbx);
fclose(fid);

sendstatus(h, 'C file generated');

% [EOF]

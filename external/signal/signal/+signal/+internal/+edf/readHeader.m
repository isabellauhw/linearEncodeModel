function varargout = readHeader(fid)
%readHeader is a helper function to read the header content of EDF/EDF+ files
%
%   This function is for internal use only. It may change or be removed.
%
%     varargout is from 1 to 20 with variables extracted as follows:
%     ver       - Version.
%     pat       - Patient.
%     rec       - Recording.
%     sd        - Start date.
%     st        - Start time.
%     hb        - Header bytes.
%     rev       - Reserved.
%     numDR     - Number of data records.
%     drd       - Data record duration.
%     ns        - Number of signals.
%     sigLabels - Signal labels.
%     ttype     - Transducer type.
%     phyDim    - Physical dimension.
%     phyMin    - Physical minimum.
%     phyMax    - Physical maximum.
%     dMim      - Digital minimum.
%     dMax      - Digital maximum.
%     pf        - Prefilter.
%     numSamp   - Number of samples.
%     sigres    - Signal reserved.

%   Copyright 2020 The MathWorks, Inc.

% Read first 256 Bytes of the EDF file using fread
hdr_fixeddata = fread(fid,256,'*char').';

% Extract version of the data format
varargout{1} = strtrim(hdr_fixeddata(1:8));

% Extract local patient identification
varargout{2} = strtrim(hdr_fixeddata(9:88));

% Extract local recording identification
varargout{3} = strtrim(hdr_fixeddata(89:168));

% Extract start date of recording
varargout{4} = strtrim(hdr_fixeddata(168:176));

% Extract Start time of recording
varargout{5} = strtrim(hdr_fixeddata(177:184));

% Extract number of bytes in header record
varargout{6} = str2double(hdr_fixeddata(185:192));

% Extract reserved
varargout{7} = string(strtrim(hdr_fixeddata(193:236)));

% Extract number of data records
varargout{8} = str2double(hdr_fixeddata(237:244));

% Extract duration of a data record, in seconds
varargout{9} = str2double(hdr_fixeddata(245:252));

% Extract number of signals (ns) in data record
ns = str2double(hdr_fixeddata(253:256));
varargout{10} = ns;

% Next ns * 256 Bytes
hdr_vardata = fread(fid,ns*256,'*char').';

% Extract labels of the signals
varargout{11} = strtrim(string(reshape(hdr_vardata(1:ns*16),16,ns).'));

% Extract transducer type
varargout{12} = strtrim(string(reshape(hdr_vardata(1+ns*16:ns*96),...
    80,ns).'));

% Extract physical dimension of signals
varargout{13} = strtrim(string(reshape(hdr_vardata(1+ns*96:ns*104),...
    8,ns).'));

% Extract physical minimum in units of physical dimension
varargout{14} = str2double(string(reshape(hdr_vardata(1+ns*104:ns*112),...
    8,ns).'));

% Extract physical maximum in units of physical dimension
varargout{15} = str2double(string(reshape(hdr_vardata(1+ns*112:ns*120),...
    8,ns).'));

% Extract digital minimum
varargout{16} = str2double(string(reshape(hdr_vardata(1+ns*120:ns*128),...
    8,ns).'));

% Extract digital maximum
varargout{17} = str2double(string(reshape(hdr_vardata(1+ns*128:ns*136),...
    8,ns).'));

% Extract prefiltering
varargout{18} = strtrim(string(reshape(hdr_vardata(1+ns*136:ns*216),...
    80,ns).'));

% Extract number of samples in each data record
varargout{19} = str2double(string(reshape(hdr_vardata(1+ns*216:ns*224),...
    8,ns).'));

% Extract reserved field
varargout{20} = strtrim(string(reshape(hdr_vardata(1+ns*224:ns*256),...
    32,ns).'));

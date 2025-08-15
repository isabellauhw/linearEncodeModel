function[esttype,reassign,faxisloc,threshold,timeDimension,args] = getSpectrogramOptions(varargin)
%MATLAB Code Generation Private Function

%   Copyright 2019 The MathWorks, Inc.
%#codegen
isInMATLAB = coder.target('MATLAB');
if ~isInMATLAB
    coder.inline('always');
    idxArray = true(1,nargin);
    faxisloc = 'xaxis';
    reassign = false;
    nreassign = 0;
    nthres = 0;
    nesttype = 0;
    ntimeDim = 0;
    nfaxis = 0;
    for i = coder.unroll(1:nargin)
        if ischar(varargin{i})
            if strcmpi(varargin{i},'reassigned')
                reassign = true;
                nreassign = nreassign + 1;
                idxArray(i) = false;
            end

            if strcmpi(varargin{i},'MinThreshold')
                coder.internal.errorIf(isempty({varargin{i+1:end}}),'signal:spectrogram:thresNotSpecified');
                validateattributes(varargin{i+1},{'numeric'},{'scalar','real','nonnan'},'','MinThreshold');
                threshold = varargin{i+1}(1);
                threshold = 10^(0.1*threshold);
                nthres = nthres + 1;
                idxArray(i) = false;
                idxArray(i+1) = false;
            end

            if strcmpi(varargin{i},'OutputTimeDimension')
                coder.internal.errorIf(isempty({varargin{i+1:end}}),'signal:spectrogram:timeDimNotSpecified');
                validStrings = {'acrosscolumns','downrows'};
                timeDimension = validatestring(varargin{i+1},validStrings,'spectrogram','OutputTimeDimension');
                ntimeDim = ntimeDim + 1;
                idxArray(i) = false;
                idxArray(i+1) = false;
            end

            if strcmpi(varargin{i},'psd') || strcmpi(varargin{i},'power')
                esttype = varargin{i};
                nesttype = nesttype + 1;
                idxArray(i) = false;
            end

            if strcmpi(varargin{i},'xaxis') || strcmpi(varargin{i},'yaxis')
                faxisloc = varargin{i};
                nfaxis = nfaxis + 1;
                idxArray(i) = false;
            end
        end
    end
    coder.internal.errorIf(nreassign > 1,'signal:spectrogram:duplicateOption','reassigned');
    coder.internal.errorIf(nthres    > 1,'signal:spectrogram:duplicateOption','MinThreshold');
    coder.internal.errorIf(ntimeDim  > 1,'signal:spectrogram:duplicateOption','OutputTimeDimension');
    coder.internal.errorIf(nesttype  > 1,'signal:spectrogram:duplicateOption','SpectrumType');
    coder.internal.errorIf(nfaxis    > 1,'signal:spectrogram:duplicateOption','FrequencyLocation');

    % Assign default values
    if ntimeDim == 0
        timeDimension = 'acrosscolumns';
    end

    if nesttype == 0
        esttype = 'psd';
    end

    if nthres == 0
        threshold = 0;
    end
    % Copy the contents of varargin to the cell array args but exclude the name
    % value pairs and the flags 'reassigned', 'psd/power', 'xaxis/yaxis'
    nargs = sum(idxArray);
    args = cell(1,nargs);
    k = 1;
    for i  = coder.unroll(1:nargin)
        if idxArray(i)
            args{k} = varargin{i};
            k = k + 1;
        end
    end

else
    reassign = false;
    i = 1;
    while i <= numel(varargin)
        if ischar(varargin{i}) && strncmpi(varargin{i},'reassigned',strlength(varargin{i}))
            reassign = true;
            varargin(i)=[];
        else
            i = i+1;
        end
    end

    faxisloc = 'xaxis';
    i = 1;
    while i <= numel(varargin)
        if ischar(varargin{i}) && strncmpi(varargin{i},'xaxis',strlength(varargin{i}))
            faxisloc = 'xaxis';
            varargin(i)=[];
        elseif ischar(varargin{i}) && strncmpi(varargin{i},'yaxis',strlength(varargin{i}))
            faxisloc = 'yaxis';
            varargin(i)=[];
        else
            i = i+1;
        end
    end

    threshold = 0;

    i = 1;
    while i<numel(varargin)
        if ischar(varargin{i}) && strncmpi(varargin{i},'MinThreshold',strlength(varargin{i}))...
                && isnumeric(varargin{i+1}) && isscalar(varargin{i+1})
            threshold = 10^(varargin{i+1}/10);
            varargin([i i+1]) = [];
        else
            i = i+1;
        end
    end

    timeDimension = 'acrosscolumns';
    validStrings = {'acrosscolumns','downrows'};
    i = 1;
    while i<numel(varargin)
        if ischar(varargin{i}) ...
                && strncmpi(varargin{i},'OutputTimeDimension',strlength(varargin{i}))
            timeDimension = varargin{i+1};
            timeDimension = validatestring(timeDimension,validStrings,'spectrogram','OutputTimeDimension');
            varargin([i i+1]) = [];
        else
            i = i+1;
        end
    end
    [esttype, args] = signal.internal.psdesttype({'psd','power'},'psd',varargin);
end



% LocalWords:  dup xaxis yaxis Faxisloc Minthreshold thres Notspecified
% LocalWords:  acrosscolumns downrows

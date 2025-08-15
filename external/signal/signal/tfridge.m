function varargout = tfridge(tfm,f,varargin)
%TFRIDGE Extract time-frequency ridges
%   FRIDGE = TFRIDGE(TFM,F) extracts the maximum energy time-frequency
%   ridge, FRIDGE, from the time-frequency matrix, TFM, and the frequency
%   vector, F. The length of F should be equal to the number of rows of
%   TFM. FRIDGE contains the frequencies corresponding to the maximum
%   energy time-frequency ridge at each sample, and has a length equal to
%   the number of columns of TFM.
%
%   [FRIDGE,IRIDGE] = TFRIDGE(TFM,F) returns the row indices in TFM
%   corresponding to the maximum time-frequency ridge at each sample.
%
%   [FRIDGE,IRIDGE,LRIDGE] = TFRIDGE(TFM,F) returns the linear indices,
%   LRIDGE, such that TFM(LRIDGE) returns the values of the maximum
%   time-freqency ridge.
%
%   [...] = TFRIDGE(TFM,F,PENALTY) penalizes changes in frequency by
%   scaling the squared distance between frequency bins by the nonnegative
%   scalar PENALTY. If unspecified, PENALTY defaults to 0.
%
%   [...] = TFRIDGE(...,'NumRidges',NR) extracts the NR highest energy
%   time-frequency ridges. NR is a positive integer. If NR is greater than
%   1, TFRIDGE iteratively determines the maximum energy time-frequency
%   ridge by removing the previously computed ridges +/- 4 frequency bins.
%   FRIDGE, IRIDGE, and LRIDGE are N-by-NR matrices, where N is the number
%   of time samples (columns) in SST. The first column of the matrices
%   contains the frequencies or indices for the maximum energy
%   time-frequency ridge in TFM. Subsequent columns contain the frequencies
%   or indices for the time-frequency ridges in decreasing energy order.
%   You can specify the name-value pair NumRidges anywhere in the input
%   argument list after the time-frequency matrix, TFM.
%
%   [...] = TFRIDGE(...,'NumRidges',NR,'NumFrequencyBins',NBINS) specifies
%   the number of adjacent frequency bins to remove from TFM when
%   extracting multiple ridges. NBINS is a positive integer less than or
%   equal to round(size(TFM,1)/4). Specifying NBINS is only valid when you
%   extract more than one ridge. After extracting the highest-energy ridge,
%   TFRIDGE removes it +/- NBINS from TFM before extracting the next ridge.
%   If the index of the time-frequency ridge +/- NBINS exceeds the number
%   of frequency bins at any time step, TFRIDGE truncates the removal
%   region at the first or last frequency bin. If unspecified, NBINS
%   defaults to 4.
%
%   % Example
%   %   Extract the instantaneous frequency of the modes of a
%   %   multicomponent signal using Fourier synchrosqueezing and
%   %   plot the result.
%   fs = 3000;
%   t=0:1/fs:1-1/fs;
%   x1 = 2*chirp(t,500,t(end),1000);
%   x2 = chirp(t,400,t(end),800);
%   [sst,f] = fsst(x1+x2,fs,kaiser(512,10));
%   fridge = tfridge(sst,f,10,'NumRidges',2);
%   plot(t,fridge)
%   xlabel('Time (s)'), ylabel('Frequency (Hz)')
%   title('Instantaneous Frequency')
%   legend('Chirp 1','Chirp 2')
%
%   See also SPECTROGRAM, IFSST, FSST.

%   Copyright 2015-2019 The MathWorks, Inc.

%#codegen

narginchk(2,7);
nargoutchk(0,3);

[tfm,freq,penalty,numRidges,numBins] = parseValidateInputs(tfm,f,varargin{:});

% Call ExtractRidges
iridge = signalwavelet.internal.tfridge.extractRidges(tfm,penalty,numRidges,numBins);

if nargout == 0
    outputCell{1} = freq(iridge);
else
    outputCell = cell(nargout,1);
    for idx = 1:nargout
        if idx == 1
            outputCell{idx} = freq(iridge);
        end
        if idx == 2
            outputCell{idx} = iridge;
        end
        if idx == 3        
            outputCell{idx} = iridge + repmat(((0:size(tfm,2)-1)'*size(tfm,1)),1,size(iridge,2));
        end
    end
end

[varargout{1:nargout}] = outputCell{:};

end

%--------------------------------------------------------------------------
function [tfm,freq,penalty,numRidges,numBins] = parseValidateInputs(tfm,f,varargin)
% parseValidateInputs : Parse the tfridge inputs

isMATLAB = coder.target('MATLAB');
initIdx = 1;
defaultNumRidges = 1;
defaultNumFreqBins = 4;

% tfm : time frequency matrix
validateattributes(tfm,{'single','double'},...
    {'nonsparse','finite','nonempty','nonnan','2d'},'tfridge','TFM',1);

% f : frequency vector
validateattributes(f,{'single','double'},...
    {'real','finite','nonnan','vector'},'tfridge','F',2);
freq = f(:);

% Penalty
if ~isempty(varargin) && isnumeric(varargin{1})
    validateattributes(varargin{1},{'numeric'},...
        {'finite','nonnan','nonempty','nonnegative'},'tfridge','PENALTY',3);
    % Datatype of penalty is changed to match the datatype of tfm. This is
    % ensure data match during code generation.
    if isa(tfm,'single')
        penalty = single(varargin{1});
    else
        penalty = double(varargin{1});
    end
    penalty = penalty(1);
    initIdx = 2;
else
    penalty = zeros(1,class(tfm));
end

% copy the varargin from 'strtIdx to end' to another cell array
inpCell = cell(1,numel(varargin)-(initIdx-1));
[inpCell{:}] = varargin{initIdx:end};
coder.internal.errorIf(~isempty(inpCell) && (~(ischar(inpCell{1}) || isStringScalar(inpCell{1}))),...
    'signal:tfridge:UnrecognizedInput',(initIdx + 2));

% Parse and validate Name value pairs
if isMATLAB
    p = inputParser;
    addParameter(p,'NumRidges',defaultNumRidges,@(x)validateattributes(x,{'numeric'},...
        {'finite','nonnan','nonempty','positive','integer'},'tfridge','NR'));
    addParameter(p,'NumFrequencyBins',[],@(x)validateattributes(x,{'numeric'},...
        {'finite','nonnan','positive','integer'},'tfridge','NBINS'));
    
    parse(p,inpCell{:});
    
    numRidges = p.Results.NumRidges;
    numBins = p.Results.NumFrequencyBins;
    
    % Assign default numBins if numRidges is greater than 1
    if isempty(numBins) && numRidges > 1 
        numBins = defaultNumFreqBins;
    end
    % Warn if numBins is specified and numRidges is 1
    if numRidges == 1 && ~(isempty(numBins))
        warning(message('signal:tfridge:nbinsIgnored'));
    end
    
else % Codegen
    % Define the parameter names either using a struct
    parms  = struct(...
        'NumRidges', zeros(1,3),...
        'NumFrequencyBins', zeros(1,3));
    % Select parsing options
    poptions = struct(...
        'CaseSensitivity',false, ...
        'PartialMatching','unique', ...
        'StructExpand',false, ...
        'IgnoreNulls',true,...
        'RepValues',[1 1]);
    % Parse the inputs
    pstruct = signalwavelet.internal.util.parseArgumentsOpt(parms,poptions,inpCell{:});
    
    % Retrieve parameter values
    numRidges   = signalwavelet.internal.util.getParameterValue(pstruct.NumRidges(2),...
        defaultNumRidges,inpCell{:});
    numRidges = numRidges(1);
    
    if pstruct.NumFrequencyBins(1) == 0 && numRidges > 1 
        % Assign default numBins if numRidges is greater than 1
        numBins = defaultNumFreqBins;
    else
        numBins  = signalwavelet.internal.util.getParameterValue(pstruct.NumFrequencyBins(2),...
            defaultNumFreqBins,inpCell{:});
        numBins = numBins(1);
        if numRidges == 1
            % Warn if numBins is specified and numRidges is 1
            coder.internal.warning('signal:tfridge:nbinsIgnored');
        end
    end
    
    % Validate numRidges & numBins
    validateattributes(numRidges,{'numeric'},...
        {'real','finite','nonnan','nonempty','positive','integer'},'tfridge','NR');
    validateattributes(numBins,{'numeric'},...
        {'real','finite','nonnan','positive','integer'},'tfridge','NBINS');
    
end
end

% LocalWords:  TFM IRIDGE LRIDGE freqency NBINS multicomponent synchrosqueezing
% LocalWords:  fs sst fsst IFSST tfm nonsparse nonnan strt nbins numRidges

function [kgram, f, w, L, fc, wc, BW, maxNode] = computeKurtogram(x, fs, level)
%COMPUTEKURTOGRAM fast kurtogram algorithm implementation
% This function is only for internal use

%   Copyright 2017-2019 The MathWorks, Inc.

%#codegen
isInMATLAB = coder.target('MATLAB');
isSingle = isa(x, 'single');

% Generate filter bank, define parameters for prototype filters
[binaryFilter, tenaryFilter] = filterBank(isSingle, isInMATLAB);

% Max meaningful level depends on the length of the prototype FIR filters.
% This is the hard limit the level can go to: 
% nfir2 = size(binaryFilter,2);
% nfir3 = size(tenaryFilter,2);
% maxLevelTemp = min([floor(log2(length(x)/(3*(nfir3+1)))+2), floor(log2(length(x)/(nfir2+1)))]);
% maxLevelTemp = max([0, maxLevel]);

% To be more conservative, the maximum level is chosen to guarantee at
% least 64 data points in each frequency bin
maxLevelTemp = max([0 floor(log2(length(x))-6)]);

if isa(level, 'single')
    maxLevel = single(maxLevelTemp);
else
    maxLevel = maxLevelTemp;
end

if level < 0
    level = maxLevel;
elseif level > maxLevel
    if isInMATLAB
        warning(message('signal:kurtogram:beyondMaxLevel', num2str(level), num2str(maxLevel), num2str(length(x))));
    else
        coder.internal.warning('signal:kurtogram:beyondMaxLevel', ...
            signal.internal.utilities.coderInt2Str(level), ...
            signal.internal.utilities.coderInt2Str(maxLevel), ...
            signal.internal.utilities.coderInt2Str(length(x)));
    end
    level = maxLevel;
end

% Demean signal
x = x - mean(x);

% Compute kurtogram
if isSingle
    rootNode = struct('level', single(0), ...
        'num', single(1), ...
        'coef', x, ...
        'kurtosis', signal.internal.skurtosis.utilComplexKurtosis(x)-1);
else
    rootNode = struct('level', 0, ...
        'num', 1, ...
        'coef', x, ...
        'kurtosis', signal.internal.skurtosis.utilComplexKurtosis(x)-1);
end

maxNode = struct('level', rootNode.level, ...
    'num', rootNode.num, ...
    'kurtosis', rootNode.kurtosis);

level = level(1);
if level == 0
    kgram = zeros(1, 3, class(x));
else
    kgram = zeros(2*level, 3*2^level, class(x));
end
kgram(1, :) = rootNode.kurtosis;

if level > 0
    [kgram, maxNode] = recursiveKurtogram(kgram, ...
        rootNode, maxNode, level, binaryFilter, tenaryFilter, isInMATLAB, isSingle);
end

% For now, we do not change negative values to 0
% kgram(kgram<0) = 0;

% Compute other output arguments
if isSingle
    [f, w, L, fc, wc, BW] = computeOutputParameters(maxNode, single(level), single(fs));
else
    [f, w, L, fc, wc, BW] = computeOutputParameters(maxNode, double(level), double(fs));
end
end


function [kgram, maxNode] = recursiveKurtogram(kgram, parentNode, maxNode, ...
    levelToGrow, binaryFilter, tenaryFilter, isInMATLAB, isSingle)
% Recursive Implementation of fast kurtogram
if levelToGrow == 1
    % Only grow binary nodes in the last level
    [kgram, maxNode, ~] = binaryDecomp(kgram, parentNode, maxNode, binaryFilter, isInMATLAB, isSingle);
else
    % Grow binary nodes and tenary nodes
    [kgram, maxNode, childNode] = binaryDecomp(kgram, parentNode, maxNode, binaryFilter, isInMATLAB, isSingle);
    [kgram, maxNode] = tenaryDecomp(kgram, parentNode, maxNode, tenaryFilter, isInMATLAB, isSingle);
    
    % clear the memory taken by coef in parent node
    parentNode.coef = [];
    
    % Recursively Grow next level
    [kgram, maxNode] = recursiveKurtogram(kgram, ...
        childNode(1), maxNode, levelToGrow-1, binaryFilter, tenaryFilter, isInMATLAB, isSingle);
    [kgram, maxNode] = recursiveKurtogram(kgram, ...
        childNode(2), maxNode, levelToGrow-1, binaryFilter, tenaryFilter, isInMATLAB, isSingle);
end
end


function [kgram, maxNode, childNode] = binaryDecomp(kgram, parentNode, maxNode, binaryFilter, isInMATLAB, isSingle)
%BINARYDECOMP decomposes parent node into two child nodes and updates kgram
%   It filters the coefficient in parentNode into a low pass sequence
%   and a high pass sequence given the binaryFilter bank, and stores them
%   as child node coefficients. The function will update kurtogram matrix
%   kgram and the maxNode where maximal spectral kurtosis is located at the
%   same time.

% Type cast to utilize mex code for speedup
if isSingle
    downSample = single(2);
    initCoef = single(complex((downSample:downSample:length(parentNode.coef))'));
    initNode = struct('level', single(0), ...
                  'num', single(1), ...
                  'coef', initCoef, ...
                  'kurtosis', single(0));
else
    downSample = 2;
    initCoef = complex((downSample:downSample:length(parentNode.coef))');
    initNode = struct('level', 0, ...
                  'num', 1, ...
                  'coef', initCoef, ...
                  'kurtosis', 0);
end

childNode = [initNode; initNode];

ncol = size(kgram, 2);
for i = 1:2
    % Compute the properties of childNode
    childNode(i).level = parentNode.level + 1;
    childNode(i).num = 2*(parentNode.num - 1) + i;
    
    % Use different functions in different environment
    if isInMATLAB
        if isSingle
            childNode(i).coef = signal.internal.skurtosis.cg_utilFilterDownSample_single(...
                parentNode.coef, binaryFilter(i, :), downSample);
        else
            childNode(i).coef = signal.internal.skurtosis.cg_utilFilterDownSample_double(...
                parentNode.coef, binaryFilter(i, :), downSample);
        end
    else
        childNode(i).coef = signal.internal.skurtosis.utilFilterDownSample(...
            parentNode.coef, binaryFilter(i, :), downSample);
    end
    
    if i == 2
        % Multiply (-1)^n for high pass filtered signal
        childNode(i).coef = childNode(i).coef.*(-1).^(1:numel(childNode(i).coef)).';
    end
    
    % Use different functions in different environment
    if isInMATLAB
        if isSingle
            childNode(i).kurtosis = signal.internal.skurtosis.cg_utilComplexKurtosis_single(...
                childNode(i).coef(size(binaryFilter(i, :), 2):end));
        else
            childNode(i).kurtosis = signal.internal.skurtosis.cg_utilComplexKurtosis_double(...
                childNode(i).coef(size(binaryFilter(i, :), 2):end));
        end
    else
        childNode(i).kurtosis = signal.internal.skurtosis.utilComplexKurtosis(...
            childNode(i).coef(size(binaryFilter(i, :), 2):end));
    end
    
    % Update kgram
    step = ncol/2.^childNode(i).level;
    kgram(2*childNode(i).level, ...
        ((childNode(i).num-1)*step+1) : childNode(i).num*step) ...
        = childNode(i).kurtosis;
    
    % Update node with maximum kurtosis
    if childNode(i).kurtosis > maxNode.kurtosis
        maxNode = struct('level', childNode(i).level, ...
                         'num', childNode(i).num, ...
                         'kurtosis', childNode(i).kurtosis);
    end
end
end

function [kgram, maxNode] = tenaryDecomp(kgram, parentNode, maxNode, tenaryFilter, isInMATLAB, isSingle)
%TENARYDECOMP decomposes parent node into three child nodes and updates kgram
%   It filters the coefficient in parentNode into three sequences in low,
%   mid, high frequency bands given the tenaryFilter bank, and stores them 
%   as child node coefficients. The function will update kurtogram matrix
%   kgram and the maxNode where maximal spectral kurtosis is located at the
%   same time.
              
if isSingle
    downSample = single(3);
    initCoef = single(complex((downSample:downSample:length(parentNode.coef))'));
    initNode = struct('level', single(0), ...
                  'num', single(1), ...
                  'coef', initCoef, ...
                  'kurtosis', single(0));
else
    downSample = 3;
    initCoef = complex((downSample:downSample:length(parentNode.coef))');
    initNode = struct('level', 0, ...
                  'num', 1, ...
                  'coef', initCoef, ...
                  'kurtosis', 0);
end

childNode = [initNode; initNode; initNode];

ncol = size(kgram, 2);
for i = 1:3
    % Compute the properties of childNode
    childNode(i).level = parentNode.level + log2(3);
    childNode(i).num = 3*(parentNode.num - 1) + i;
    
    % Use different functions in different environment
    if isInMATLAB
        if isSingle
            childNode(i).coef = signal.internal.skurtosis.cg_utilFilterDownSample_single(...
                parentNode.coef, tenaryFilter(i, :), downSample);
            childNode(i).kurtosis = signal.internal.skurtosis.cg_utilComplexKurtosis_single(...
                childNode(i).coef(size(tenaryFilter(i, :), 2):end));
        else
            childNode(i).coef = signal.internal.skurtosis.cg_utilFilterDownSample_double(...
                parentNode.coef, tenaryFilter(i, :), downSample);
            childNode(i).kurtosis = signal.internal.skurtosis.cg_utilComplexKurtosis_double(...
                childNode(i).coef(size(tenaryFilter(i, :), 2):end));
        end
    else
        childNode(i).coef = signal.internal.skurtosis.utilFilterDownSample(...
            parentNode.coef, tenaryFilter(i, :), downSample);
        childNode(i).kurtosis = signal.internal.skurtosis.utilComplexKurtosis(...
                childNode(i).coef(size(tenaryFilter(i, :), 2):end));
    end
    
    % Update kgram
    step = ncol/(3*2.^parentNode.level);
    kgram(2*(parentNode.level+1)+1, ...
        ((childNode(i).num-1)*step+1) : childNode(i).num*step) ...
        = childNode(i).kurtosis;
    
    % Update node with maximum kurtosis
    if childNode(i).kurtosis > maxNode.kurtosis
        maxNode = struct('level', childNode(i).level, ...
                         'num', childNode(i).num, ...
                         'kurtosis', childNode(i).kurtosis);
    end
end
end

function [binaryFilter, tenaryFilter] = filterBank(isSingle, isInMATLAB)
% Parameters for prototype FIR filters
nfir2 = 16;
fc2 = 0.4;
nfir3 = 24;
fc3 = 2/3*fc2;

% Filter Bank for the binary decomposition
h = fir1(nfir2, fc2);
h1 = h.*exp(1/4*1i*pi*(0:nfir2));
h2 = h.*exp(3/4*1i*pi*(0:nfir2));

% Filter Bank for 1/3-decomposition
g = fir1(nfir3, fc3);
g1 = g.*exp(1/6*1i*pi*(0:nfir3));
g2 = g.*exp(3/6*1i*pi*(0:nfir3));
g3 = g.*exp(5/6*1i*pi*(0:nfir3));

% Convert precision to utilize mex code for speedup
if isInMATLAB
    if isSingle
        h1 = single(h1);
        h2 = single(h2);
        g1 = single(g1);
        g2 = single(g2);
        g3 = single(g3);
    end
end

% change them to matrix
binaryFilter = [h1; h2];
tenaryFilter = [g1; g2; g3];
end

function [f, w, lvl, fc, wc, BW] = computeOutputParameters(maxNode, level, fs)
% Compute frequency vector f
deltaFmin = 1/(3*2^level)*fs/2;
f = (deltaFmin/2:deltaFmin:(fs/2-deltaFmin/2))';

% Compute window vector w
L = 1:level;
L = [L; L-1+log2(3)];
L = L(:);
lvl = [0; L(1:end-1)];
w = round(2.^(lvl+1));

% Compute fc, wc, and BW
deltaFc = 1/2^maxNode.level*fs/2;
fc = (maxNode.num-1/2)*deltaFc;
wc = 2^(maxNode.level+1);
% BW = deltaFc*2;
BW = deltaFc;   % Keep consistent with the published results
end

% LocalWords:  kurtogram nfir tenary coef kgram BINARYDECOMP TENARYDECOMP fc
% LocalWords:  wc BW

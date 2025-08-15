function [X, Y] = normaliseAndRecentre(X, Y)
% *normaliseAndRecentre*: Normalises and optionally recentres X and Y matrices
% INPUT:
% X        - design matrix [nFrames x nPredictors]
% Y        - output matrix [nFrames x nOutputs]

% OUTPUT:
% X, Y     - normalised and recentered matrices

[~, p] = size(X);
pY = size(Y, 2);

% Compute means and stds
XStd = std(X, 0, 1);
X = bsxfun(@rdivide, X, XStd);  % always normalise

XMean = mean(X, 1);
YMean = mean(Y, 1);
X = bsxfun(@minus, X, XMean);
Y = bsxfun(@minus, Y, YMean);

% Prepare XTX, ep, renorm, betas
% XTX = X' * X;
% ep = eye(p);
% renorm = XStd';
% betas = NaN(p, pY);

end



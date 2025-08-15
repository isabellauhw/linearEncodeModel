function [B,G] = sgolay(order,framelen,weights)
%MATLAB Code Generation Library Function

%   Limitations:
%   For code generation, if not all inputs are constant, ORDER and FRAMELEN
%   can be any numeric type.

%   Copyright 1988-2020 The MathWorks, Inc.
%#codegen

narginchk(2,3);

% For backward compatibility, dispatch to MATLAB to compute constant
% outputs if inputs are all constants.
if nargin == 2
    coder.internal.prefer_const(order,framelen);
    CONSTANT_INPUTS = ...
        coder.internal.isConst(order) && ...
        coder.internal.isConst(framelen);
else
    coder.internal.prefer_const(order,framelen,weights);
    CONSTANT_INPUTS = ...
        coder.internal.isConst(order) && ...
        coder.internal.isConst(framelen) && ...
        coder.internal.isConst(weights);
end
if CONSTANT_INPUTS && coder.internal.isCompiled
    if nargin < 3
        weights = [];
    end
    if nargout == 2
        [B,G] = coder.const(@feval,mfilename,order,framelen,weights);
    else
        B = coder.const(@feval,mfilename,order,framelen,weights);
    end
    return
end

% Casting size inputs to double precision serves no purpose for code
% generation. We just check to see if the inputs are valid.
coder.internal.assert(isnumeric(framelen) && ...
    coder.internal.isConst(isscalar(framelen)) && isscalar(framelen) && ...
    (isinteger(framelen) || framelen == floor(framelen)), ...
    'signal:sgolay:FrameMustBeInteger');
coder.internal.assert(isnumeric(order) && ...
    coder.internal.isConst(isscalar(order)) && isscalar(order) && ...
    (isinteger(order) || order == floor(order)), ...
    'signal:sgolay:DegreeMustBeInteger');

% Construct the Vandermonde matrix directly, with no temporary vectors
% or use of the double precision COLON function.
ONE = coder.internal.indexInt(1);
iFrameLen = coder.internal.indexInt(max(0,framelen));
coder.internal.assert(eml_bitand(iFrameLen,ONE) == ONE, ...
    'signal:sgolay:InvalidDimensions'); % iframeLen must be odd.
iOrder = coder.internal.indexInt(order);
coder.internal.assert(iOrder <= iFrameLen - 1, ...
    'signal:sgolay:DegreeGeLength');

S = flippedVander(iFrameLen,iOrder);

if nargin >= 3 && ~isempty(weights)
    % Cast to enforce Precision Rules
    dWeights = signal.internal.sigcasttofloat(weights, ...
        'double','sgolay','W','allownumeric');
    % Check WEIGHTS is real.
    coder.internal.assert(isreal(dWeights), ...
        'signal:sgolay:NotReal');
    % Check for right length of W
    coder.internal.assert(length(dWeights) == iFrameLen, ...
        'signal:sgolay:MismatchedDimensions');
    % Check to see if all elements are positive
    coder.internal.assert(min(dWeights(:)) > 0, ...
        'signal:sgolay:WVMustBePos');
    wS = bsxfun(@times,sqrt(dWeights(:)),S);
    % Compute QR decomposition with optional weight
    [~,R] = qr(wS,0);
    % Compute the projection matrix B
    if nargout == 2
        % Find the matrix of differentiators
        RR = R'*R;
        G = S/RR;
        % Compute the projection matrix B
        B = G*S';
    else
        % Compute the projection matrix B
        T = S/R;
        B = T*T';
    end
    % Perform B = bsxfun(@times,dweights(:)',B), but write the loop
    % explicitly to avoid creating a temporary array and matrix copy.
    for j = 1:size(B,2)
        for i = 1:size(B,1)
            B(i,j) = B(i,j)*dWeights(j);
        end
    end
else
    % Compute QR decomposition
    [Q,R] = qr(S,0);
    % Compute the projection matrix.
    B = Q*Q';
    if nargout == 2
        % Find the matrix of differentiators
        G = Q/R';
    end
end

%--------------------------------------------------------------------------

function S = flippedVander(n,order)
% Compute S = v.^(0:order), where v = (-(n-1)/2:(n-1)/2)' without the COLON
% operator and without temporary arrays. Note that the output is the
% equivalent to V = fliplr(vander(v)) followed by S = V(:,1:order+1).
% Assumes n is odd. This is not checked.
if order >= 0 && n >= 1
    S = coder.nullcopy(zeros(n,order + 1));
    for i = 1:n
        S(i,1) = 1;
    end
    nd2 = eml_rshift(n,coder.internal.indexInt(1));
    for j = 2:order + 1
        for i = 1:nd2
            t = S(i,j - 1)*double(i - 1 - nd2);
            S(i,j) = t;
            S(n - i + 1,j) = abs(t);
        end
        S(nd2 + 1,j) = 0;
    end
else
    S = zeros(max(0,n),max(0,order+1));
end

%--------------------------------------------------------------------------

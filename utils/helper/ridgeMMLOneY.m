function [L, flag] = ridgeMMLOneY(q, d2, n, YVar, alpha2, timeoutSec)
    % - *ridgeMMLOneY*: a helper function that estimates the optimal
    % ridge regularisation parameter λ (lambda) for a single output variable using
    % the marginal maximum likelihood (MML) approach described in Karabatsos (2017).
    
    % INPUT:
    % - *obj*: (unused) object instance of linearEncodeModel
    % - *q*: number of valid singular values
    % - *d2*: [q×1] squared singular values of X
    % - *n*: number of observations
    % - *YVar*: variance of output variable (norm squared)
    % - *alpha2*: [q×1] squared SVD-projected output values
    % - *timeoutSec*: (optional) time limit in seconds for the search. Default = inf.
    
    % OUTPUT:
    % - *L*: optimal lambda
    % - *flag*: convergence flag from fminbnd (1 = success, 0 = fail, 2 = timeout)

smooth = 7; stepSwitch = 25; stepDenom = 100;
smBuffer = NaN(1, smooth); testValsL = NaN(1, smooth);
smBufferI = 0;
NLLFunc = @(L) -(q * log(L) - sum(log(L + d2(1:q))) ...
    - n * log(YVar - sum(alpha2(1:q) ./ (L + d2(1:q)))));

done = false; NLL = Inf;
t0 = tic;

% --- Early stopping setup ---
patience = 3;
noImprovement = 0;
bestNLL = Inf;
bestK = NaN;

for k = 0:stepSwitch * 4
    if toc(t0) > timeoutSec
        warning('Timeout reached during lambda search');
        [~, idx] = min(smBuffer);
        L = testValsL(idx);
        flag = 2; % timeout but best-so-far
        return;
    end

    currentL = k / 4;
    smBufferI = mod(smBufferI, smooth) + 1;
    prevNLL = NLL;
    NLL = NLLFunc(currentL);
    smBuffer(smBufferI) = NLL;
    testValsL(smBufferI) = currentL;

    % Early stopping: patience mechanism
    if NLL < bestNLL
        bestNLL = NLL;
        bestK = currentL;
        noImprovement = 0;
    else
        noImprovement = noImprovement + 1;
    end

    if noImprovement >= patience
        minL = max(0, bestK - 1);
        maxL = bestK + 1;
        done = true;
        break;
    end
end

if ~done
    L = k / 4;
    NLL = mean(smBuffer);
    while ~done
        if toc(t0) > timeoutSec
            warning('Timeout reached during extended lambda search');
            L = 1; flag = 0;
            return;
        end
        L = L + L / stepDenom;
        smBufferI = mod(smBufferI, smooth) + 1;
        prevNLL = NLL;
        smBuffer(smBufferI) = NLLFunc(L);
        testValsL(smBufferI) = L;
        NLL = mean(smBuffer);

        if NLL > prevNLL
            smBufferI = smBufferI - (smooth - 1) / 2;
            smBufferI = smBufferI + smooth * (smBufferI < 1);
            maxL = testValsL(smBufferI);
            smBufferI = smBufferI - 2;
            smBufferI = smBufferI + smooth * (smBufferI < 1);
            minL = testValsL(smBufferI);
            done = true;
        end
    end
end

opts = optimset('Display', 'off', 'MaxIter', 500, 'MaxFunEvals', 500);
[L, ~, flag] = fminbnd(NLLFunc, max(0, minL), maxL, opts);
end
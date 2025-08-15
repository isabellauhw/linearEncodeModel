function [lambda, betas, convergenceFailures] = ridgeMML(X, Y, lambda, verbose, timeoutSec)
    % *ridgeMML*: a function that runs the ridge Regression with
    % marginal maximum likelihood (MML) - approach described in Karabatsos (2017).
    
    % INPUT:
    % - *obj*: (can be kept empty) the *object instance* of the class linearEncodeModel
    % that was previously created, in MATLAB this is just a syntax
    % to call the function as it belongs to the method of the class
    % linearEncodeModel()
    % - *X*: (matrix; in double) the time-lagged design matrix with
    % the dimension [frames x (number of lags x number of regressors)]
    % - *Y*: (vector; in double): the outcome of the design matrix,
    % with the dimension of [frames x 1], which the 1st dimension
    % must match with *X*
    % - *L*: (optional) initial lambdas (optional)
    % - *verbose*: (optional) print progress every 10 regressions (default: true)
    % - *timeoutSec*: (optional) timeout in seconds per column (optional)
    
    % OUTPUT:
    % - *lambda*: (double) a value that shows the optimal ridge regularisation parameter
    % λ (lambda) for a single output variable using the marginal maximum likelihood (MML)
    % - *betas*: (vector, double) [frames x 1] the beta values
    % associated with each frame
    % - *convergenceFailures*: (vector, logical) whether the fminbnd failed to converge
    % for each column of y (this happens frequently).

if size(Y, 1) ~= size(X, 1)
    error('X and Y must have the same number of rows');
end

computeL = isempty(lambda) || isnan(lambda(1));

pY = size(Y, 2);

% Compute optimal lambda if needed
if computeL
    [U, S, V] = svd(X, 0);
    d = diag(S);
    n = size(X, 1);
    p = size(V, 2);
    q = sum(d' > eps(U(1)) * (1:p));
    d2 = d .^ 2;
    alph = S * U' * Y;
    alpha2 = alph .^ 2;
    YVar = sum(Y .^ 2, 1);
    lambda = NaN(1, pY);
    convergenceFailures = false(1, pY);

    for i = 1:pY
        tStart = tic;
        [lambda(i), flag] = ridgeMMLOneY(q, d2, n, YVar(i), alpha2(:, i), timeoutSec);
        convergenceFailures(i) = (flag < 1);

        if verbose && mod(i, 10) == 0
            fprintf('[%s] Processed %d/%d responses (%.2f sec)\n', ...
                datestr(now,'HH:MM:SS'), i, pY, toc(tStart));
        end
    end
else
    p = size(X, 2);
end

% Ridge regression solution
X = [ones(size(X, 1), 1), X];  % add intercept
p = size(X, 2);
XTX = X' * X;
ep = eye(p); ep(1, 1) = 0;    % no regularization on intercept
XTY = X' * Y;

betas = NaN(p, pY);
for i = 1:pY
    betas(:, i) = (XTX + lambda(i) * ep) \ XTY(:, i);
end

% No renormalisation since X is already standardized
betas(isnan(betas)) = 0;

end

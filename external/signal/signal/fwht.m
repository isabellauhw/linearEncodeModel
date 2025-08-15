function y = fwht(x,N,ordering)
%FWHT Fast Discrete Walsh-Hadamard Transform
%   Y = FWHT(X) is the discrete Walsh-Hadamard transform of vector X. The
%   transform coefficients are stored in Y. If X is a matrix, the function
%   operates on each column.
%
%   Y = FWHT(X,N) is the N-point discrete Walsh-Hadamard transform of the
%   vector X where N must be a power of two. X is padded with zeros if it
%   has less than N points and truncated if it has more. The default value
%   of N is equal to the length of the vector X if it is a power of two or
%   the next power of two greater than the signal vector length. The
%   function errors out if N is not equal to a power of two.
%
%   Y = FWHT(X,N,ORDERING) or FWT(X,[],ORDERING) specifies the order of the
%   Walsh-Hadamard transform coefficients. ORDERING can be 'sequency',
%   'hadamard' or 'dyadic'. Default ORDERING type is 'sequency'.
%
%
%   EXAMPLES:
%
%   % Example 1: Walsh-Hadamard transform of a signal made up of Walsh
%                % functions
%                w1 = [1 1 1 1 1 1 1 1];
%                w2 = [1 1 1 1 -1 -1 -1 -1];
%                w3 = [1 1 -1 -1 -1 -1 1 1];
%                w4 = [1 1 -1 -1 1 1 -1 -1];
%                x = w1 + w2 + w3 + w4; % signal formed by adding Walsh
%                                       % functions
%                y = fwht(x); % first four values of y should be non-zero
%                             % equal to one
%
%   % Example 2: Walsh-Hadamard transform - 'hadamard' function and ordering
%                w = hadamard(8); % Walsh functions in Hadamard order
%                x = w(:,1) + w(:,2) + w(:,3) + w(:,4);
%                y = fwht(x,[],'hadamard'); % first four values equal to one
%
%   For more information see the <a href="matlab:web(fullfile(docroot,'signal/examples/discrete-walsh-hadamard-transform.html'))">Discrete Walsh-Hadamard Transform Example</a>
%   or enter "doc fwht" at the MATLAB command line.
%   See also IFWHT, FFT, IFFT, DCT, IDCT, DWT, IDWT.

%   Copyright 2008-2019 The MathWorks, Inc.
%#codegen

% error out if number of input arguments is not between 1 and 3
    narginchk(1,3)
    isMATLAB = coder.target('MATLAB');
    if nargin > 2
        orderType = validatestring(ordering,{'sequency', 'hadamard', 'dyadic'},'fwht');
    else
        orderType = 'sequency'; % default ordering is sequency
    end

    validateattributes(x,{'double','single'},{'2d'},'fwht','x',1)

    if isempty(x)
        y = cast([],'like',x);
        return
    end
    % check optional inputs' specifications and/or make default assignments
    if nargin < 2 || (nargin >= 2 && isempty(N))
        if isvector(x)
            N1 = length(x);
        else
            N1 = size(x,1);
        end
        if isMATLAB
            isPowerof2 = bitand(uint64(N1),uint64(N1-1)) == uint64(0);
        else
            isPowerof2 = coder.internal.sizeIsPow2(N1);
        end
        if ~isPowerof2
            N1 = 2^nextpow2(N1);
        end
    else
        % check if transform length is specified correctly - positive scalar and
        % power of two
        validateattributes(N,{'numeric'},{'real','integer','positive','scalar'},'fwht','N',2);
        if isMATLAB
            isPowerof2 = bitand(uint64(N(1)),uint64(N(1)-1)) == uint64(0);
        else
            isPowerof2 = coder.internal.sizeIsPow2(N(1));
        end
        coder.internal.assert(isPowerof2,'signal:fwht:InvalidTransformLength');
        N1 = double(N(1));
    end
    % do pre-processing on input signal if necessary
    [x1,tFlag] = preprocessing(x,N1,orderType);
    % calculate first stage coefficients and store in x
    for i = 1:2:N1-1
        x1(i,:) = x1(i,:)   + x1(i+1,:);
        x1(i+1,:) = x1(i,:) - 2 * x1(i+1,:);
    end
    L = 1;
    % same data type as x to enforce precision rules
    y1 = zeros(size(x1),'like',x1);
    for nStage = 2:log2(N1) % log2(N) = number of stages in the flow diagram
                            % calculate coefficients for the ith stage specified by nStage
        M = 2^L;
        J = 0; K = 1;
        if strcmpi(orderType,'sequency')
            while (K < N1)
                for j = J+1:2:J+M-1
                    y1(K,:)   = x1(j,:)   +  x1(j+M,:);
                    y1(K+1,:) = x1(j,:)   -  x1(j+M,:);
                    y1(K+2,:) = x1(j+1,:) -  x1(j+1+M,:);
                    y1(K+3,:) = x1(j+1,:) +  x1(j+1+M,:);
                    K = K + 4;
                end
                J = J + 2*M;
            end
        else
            while (K < N1)
                for j = J+1:2:J+M-1
                    y1(K,:)   = x1(j,:)   +  x1(j+M,:);
                    y1(K+1,:) = x1(j,:)   -  x1(j+M,:);
                    y1(K+2,:) = x1(j+1,:) +  x1(j+1+M,:);
                    y1(K+3,:) = x1(j+1,:) -  x1(j+1+M,:);
                    K = K + 4;
                end
                J = J + 2*M;
            end
        end
        % store coefficients in x at the end of each stage
        x1 = y1;
        L = L + 1;
    end
    % perform scaling of coefficients
    y1 = x1 ./ N1;
    if tFlag
        y = transpose(y1);
    else
        y = y1;
    end
end


function [x1,tFlag] = preprocessing(x,N,ordering)
% this function performs zero-padding, truncation or input bit-reversal if
% necessary. NROWS amd MCOLS specify the output orientation which is kept
% same as that of input.

    if isrow(x)
        xtemp = reshape(x,[],1);% column vectorizing input sequence
        tFlag = true;
    else
        xtemp = x;
        tFlag = false;
    end
    n = size(xtemp,1);

    if n < N
        x1 = [xtemp ; zeros(N-n,size(xtemp,2))];  % zero-pad
    else
        % truncate
        x1 = xtemp(1:N,:);
    end
    % Re-arrange input in bit-reversed order if ordering is hadamard
    if strcmpi(ordering,'hadamard')
        x1 = bitrevorder(x1);
    end
end
%--------------------------------------------------------------------------

% LocalWords:  FWT sequency walsh IFWHT ith NROWS MCOLS
% LocalWords:  ispowerof nextpow

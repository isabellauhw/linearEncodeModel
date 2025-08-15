function [xrec,xAmp] =  vk(sig,fs,F,r,fOrder,winlen,tol,maxiter)
%#codegen

%   Copyright 2020 The MathWorks, Inc.

    x = sig(:);
    xlen   = coder.internal.indexInt(length(x));
    winLen = coder.internal.indexInt(winlen(1));
    sizeF  = coder.internal.indexInt(size(F));
    numOrd = sizeF(2);
    
    % tol and maxit are optional
    if nargin < 7 || isempty(tol)
        tol = 1e-3; %Default tolerance for pcg
    end
    
    if nargin < 8 || isempty(maxiter)
        maxit = coder.internal.indexInt(5e4);
    else
        maxit = coder.internal.indexInt(maxiter);
    end

    one   =  coder.internal.indexInt(1);
    two   =  coder.internal.indexInt(2);
    three =  coder.internal.indexInt(3);

    if xlen ~= winLen

        if three * winLen + one > two * xlen
            winLen = coder.internal.indexDivide(two*xlen-one,three);
        end

        if ~mod(winLen,two)
            winLen = winLen - one;
        end

        nhop = coder.internal.indexDivide(winLen+one,two);
        noverlap = winLen - nhop;

        xrec = zeros(sizeF,class(x));
        xAmp = zeros(sizeF,class(x));

        [xin,xlast,colidx] = getSegments(x,xlen,winLen,noverlap);

        nrows = coder.internal.indexInt(size(xin,one));
        ncols = coder.internal.indexInt(size(xin,two));

        nrowsLast     = coder.internal.indexInt(length(xlast));

        % Solve for each order waveform separately
        F_in = zeros(numOrd,size(xin,one),size(xin,two));
        F_inlast = zeros(numOrd,length(xlast));

        winIn = hanning(double(winLen));
        winStart = winIn;
        winEnd = ones(nrowsLast,one);
        for i = 1:nhop
            winStart(i) = 1;
            winEnd(i) = winIn(i);
        end

        for j = one:numOrd
            [F_in(j,:,:),F_inlast(j,:)] = getSegments(F(:,j),xlen,winLen,noverlap);
        end

        for i = one:ncols
            if i == one
                win = winStart;
            else
                win = winIn;
            end

            inds = colidx(i):colidx(i) + nrows - one;
            [x0,xMagPhase0] = computevk(xin(:,i),fs,squeeze(F_in(:,:,i))',r,fOrder,tol,maxit);

            for n = one:sizeF(two)
                for m = one:length(inds)
                    xrec(inds(m),n) = xrec(inds(m),n) + x0(m,n)*win(m);
                    xAmp(inds(m),n) = xAmp(inds(m),n) + abs(xMagPhase0(m,n))*win(m);
                end
            end
        end
        [xEnd,xMagPhaseEnd] = computevk(xlast,fs,F_inlast',r,fOrder,tol,maxit);

        idxEnd = colidx(end):sizeF(one);

        for n = one:sizeF(two)
            for m = one:length(idxEnd)
                xrec(idxEnd(m),n) = xrec(idxEnd(m),n) + xEnd(m,n)*winEnd(m);
                xAmp(idxEnd(m),n) = xAmp(idxEnd(m),n) + abs(xMagPhaseEnd(m,n))*winEnd(m);
            end
        end

    else
        if xlen > 5e4
            coder.internal.warning('signal:rpmmap:WarnVKLongInput');
        end
        [xrec,xMagPhase] = computevk(x,fs,F,r,fOrder,tol,maxit);
        xAmp = abs(xMagPhase);
    end
end

function [xrec,xMagPhase] = computevk(x,Fs,F,r,fOrder,tol,maxit)

    filtOrd = coder.internal.indexInt(fOrder(1));
    x = x(:);

    zero  =  coder.internal.indexInt(0);
    one   =  coder.internal.indexInt(1);
    two   =  coder.internal.indexInt(2);
    three =  coder.internal.indexInt(3);

    N = coder.internal.indexInt(length(x));
    K = coder.internal.indexInt(size(F,two));

    e = ones(N,one);
    if filtOrd == one
        numRows = N - two;
        diag1 = [0 1 2];
        S1 = spdiags([e -2*e e],diag1,double(numRows),double(N));
        B0 = S1'*S1;
    else % filtOrd is 2
        numRows = N - three;

        diag2 = [0 1 2 3];
        S2 = spdiags([e -3*e 3*e -e],diag2,double(numRows),double(N));
        B0 = S2'*S2;
    end

    C = exp(1i*2*pi*cumsum(F,1)/Fs);

    b = complex(zeros(K*N,one));
    nbl = coder.internal.indexDivide(K*K - K,two);

    rowidx = coder.nullcopy(zeros(N,nbl,coder.internal.indexIntClass));
    colidx = coder.nullcopy(zeros(N,nbl,coder.internal.indexIntClass));
    upperDiagData = coder.nullcopy(complex(zeros(N,nbl)));
    m = zero;
    for i = one:K
        irow = (one:N)'+ N*(i-one);
        b(irow) = conj(C(:,i)).*x;

        for j = (i+one):K
            m = m + one;
            rowidx(:,m) = irow;
            colidx(:,m) = (one:N)' + N*(j-one);
            upperDiagData(:,m) =  conj(C(:,i)).*C(:,j);
        end
    end

    % revisit: use A = kron(spdiags(r.^2,0,K,K),B0) + speye(N*K) + sparse(0i), when sparse support is
    % available for kron in code generation.
    A = sparse(kron(diag(r.^2),full(B0)))+ speye(N*K) + sparse(0i); % Block diagonal part
    if K > one
        AU = sparse(rowidx,colidx,upperDiagData,K*N,K*N); % upper diagonal part
        A = A + AU + AU'; % lower diagonal part is the conjugate transpose of upper diagonal part
    end
    hIM = @(x) cumsum(cumsum(x),'reverse');
    x0 = double(std(x)/sqrt(2)*ones(K*N,one));

    if filtOrd == one
        hM1 = @(x) hIM(hIM(x));
        [X,flag] = pcg(A,b,tol,maxit,hM1,[],x0);
    else % fOrder is 2
        hM2= @(x) hIM(hIM(hIM(x)));
        [X,flag] = pcg(A,b,tol,maxit,hM2,[],x0);
    end

    if flag
        coder.internal.warning('signal:rpmmap:VKPCGFlag',flag);
    end

    % Construct time-domain waveforms
    if K > one
        xMagPhaseD = 2*reshape(X,N,K);
    else
        xMagPhaseD = 2*X;
    end
    xrec      = cast(real(xMagPhaseD.*C),class(x));
    xMagPhase = cast(xMagPhaseD,class(x));
end

function[xin,xlast,colindex] = getSegments(x,nx,nwin,noverlap)

    one = coder.internal.indexInt(1);
    ncol = coder.internal.indexDivide(nx-noverlap,nwin-noverlap);
    colindex = 1 + (0:(ncol-1))*(nwin-noverlap);
    rowindex = coder.internal.indexInt((1:nwin)');
    xin = coder.nullcopy(zeros(nwin,ncol -1, class(x)));

    for j = one:ncol-1
        for i = one:nwin
            xin(i,j) = x(rowindex(i) + colindex(j) - one);
        end
    end

    xlast = x(colindex(end):end);
end

% LocalWords:  rpmmap Ord spye VKPCG inds xrec nwin ncol xin rowindex colindex
% LocalWords:  maxit

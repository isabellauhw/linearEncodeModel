function varargout = butter(n, Wn, varargin)
%BUTTER Butterworth digital and analog filter design.
%   [B,A] = BUTTER(N,Wn) designs an Nth order lowpass digital
%   Butterworth filter and returns the filter coefficients in length
%   N+1 vectors B (numerator) and A (denominator). The coefficients
%   are listed in descending powers of z. The cutoff frequency
%   Wn must be 0.0 < Wn < 1.0, with 1.0 corresponding to
%   half the sample rate.
%
%   If Wn is a two-element vector, Wn = [W1 W2], BUTTER returns an
%   order 2N bandpass filter with passband  W1 < W < W2.
%   [B,A] = BUTTER(N,Wn,'high') designs a highpass filter.
%   [B,A] = BUTTER(N,Wn,'low') designs a lowpass filter.
%   [B,A] = BUTTER(N,Wn,'stop') is a bandstop filter if Wn = [W1 W2].
%
%   When used with three left-hand arguments, as in
%   [Z,P,K] = BUTTER(...), the zeros and poles are returned in
%   length N column vectors Z and P, and the gain in scalar K.
%
%   When used with four left-hand arguments, as in
%   [A,B,C,D] = BUTTER(...), state-space matrices are returned.
%
%   BUTTER(N,Wn,'s'), BUTTER(N,Wn,'high','s') and BUTTER(N,Wn,'stop','s')
%   design analog Butterworth filters.  In this case, Wn is in [rad/s]
%   and it can be greater than 1.0.
%
%   % Example 1:
%   %   For data sampled at 1000 Hz, design a 9th-order highpass
%   %   Butterworth filter with cutoff frequency of 300Hz.
%
%   Wn = 300/500;                   % Normalized cutoff frequency
%   [z,p,k] = butter(9,Wn,'high');  % Butterworth filter
%   [sos] = zp2sos(z,p,k);          % Convert to SOS form
%   h = fvtool(sos);                % Plot magnitude response
%
%   % Example 2:
%   %   Design a 4th-order butterworth band-pass filter which passes
%   %   frequencies between 0.15 and 0.3.
%
%   [b,a]=butter(2,[.15,.3]);        % Bandpass digital filter design
%   h = fvtool(b,a);                 % Visualize filter
%
%   See also BUTTORD, BESSELF, CHEBY1, CHEBY2, ELLIP, FREQZ,
%   FILTER, DESIGNFILT.

%   Author(s): J.N. Little, 1-14-87
%          J.N. Little, 1-14-88, revised
%          L. Shure, 4-29-88, revised
%          T. Krauss, 3-24-93, revised

%   References:
%     [1] T. W. Parks and C. S. Burrus, Digital Filter Design,
%         John Wiley & Sons, 1987, chapter 7, section 7.3.3.
%   Copyright 1998-2019 The MathWorks, Inc.
%#codegen

    narginchk(2,4);
    if coder.target('MATLAB')
        [varargout{1:nargout}] = butterImpl(n,Wn,varargin{:});
    else
        allConst = coder.internal.isConst(n) && coder.internal.isConst(Wn);
        for ii = 1:length(varargin)
            allConst = allConst && coder.internal.isConst(varargin{ii});
        end
        if allConst && coder.internal.isCompiled
            [varargout{1:nargout}] = coder.const(@feval,'butter',n,Wn,varargin{:});
        else
            [varargout{1:nargout}] = butterImpl(n,Wn,varargin{:});
        end
    end
end

function varargout = butterImpl(n,Wn,varargin)
    inputArgs = cell(1,length(varargin));
    if nargin > 2
        [inputArgs{:}] = convertStringsToChars(varargin{:});
    else
        inputArgs = varargin;
    end
    validateattributes(n,{'numeric'},{'scalar','real','integer','positive'},'butter','N');
    validateattributes(Wn,{'numeric'},{'vector','real','finite','nonempty'},'butter','Wn');

    [btype,analog,~,msgobj] = iirchk(Wn,inputArgs{:});
    if ~isempty(msgobj)
        coder.internal.error(msgobj.Identifier,msgobj.Arguments{:});
    end
    % Cast to enforce precision rules
    n1 = double(n(1));
    coder.internal.errorIf(n1 > 500,'signal:butter:InvalidRange')
    % Cast to enforce precision rules
    Wn = double(Wn);
    % step 1: get analog, pre-warped frequencies
    fs = 2;
    if ~analog
        u = 2*fs*tan(pi*Wn/fs);
    else
        u = Wn;
    end

    % step 2: Get N-th order Butterworth analog lowpass prototype
    [zs,ps,ks] = buttap(n1);
    % Transform to state-space
    [a,b,c,d] = zp2ss(zs,ps,ks);
    % step 3: Transform to the desired filter
    if length(Wn) == 1
        % step 3a: convert to low-pass prototype estimate
        Wn1 = u(1);
        Bw = [];
        % step 3b: Transform to lowpass or high pass filter of desired cutoff
        % frequency
        if btype == 1           % Lowpass
            [ad,bd,cd,dd] = lp2lp(a,b,c,d,Wn1);
        else % btype == 3       % Highpass
            [ad,bd,cd,dd] = lp2hp(a,b,c,d,Wn1);
        end
    else % length(Wn) is 2
         % step 3a: convert to low-pass prototype estimate
        Bw = u(2) - u(1);      % center frequency
        Wn1 = sqrt(u(1)*u(2));
        % step 3b: Transform to bandpass or bandstop filter of desired center
        % frequency and bandwidth
        if btype == 2           % Bandpass
            [ad,bd,cd,dd] = lp2bp(a,b,c,d,Wn1,Bw);
        else % btype == 4       % Bandstop
            [ad,bd,cd,dd] = lp2bs(a,b,c,d,Wn1,Bw);
        end
    end
    % step 4: Use Bilinear transformation to find discrete equivalent:
    if ~analog
        [ad,bd,cd,dd] = bilinear(ad,bd,cd,dd,fs);
    end

    if nargout == 4 % Outputs are in state space form
        varargout{1} = ad;          % A
        varargout{2} = bd;          % B
        varargout{3} = cd;          % C
        varargout{4} = dd;          % D
    elseif nargout == 3         % Transform to zero-pole-gain form
        varargout{1} = buttzeros(btype,n1,Wn1,analog); % zeros
        varargout{2} = eig(ad);                        % poles
        zinf = ltipack.getTolerance('infzero',true);
        [~,varargout{3}] = ltipack.sszero(ad,bd,cd,dd(1),[],zinf); %gain
    else % nargout <= 2    % Transform to transfer function form
        den = real(poly(ad));
        num = buttnum(btype,n1,Wn1,Bw,analog,den);
        % num = poly(ad-bd*cd)+(dd-1)*den;
        if nargout > 0
            varargout{1} = num;
        end
        if nargout > 1
            varargout{2} = den;
        end
    end
end

%---------------------------------
function b = buttnum(btype,n,Wn,Bw,analog,den)
% This internal function returns more exact numerator vectors
% for the num/den case.
% Wn input is two element band edge vector
    if analog
        switch btype
          case 1  % lowpass
            b = [zeros(1,n) n^(-n)];
            b = real( b*polyval(den,-1i*0)/polyval(b,-1i*0) );
          case 2  % bandpass
            b = [zeros(1,n) Bw^n zeros(1,n)];
            b = real( b*polyval(den,-1i*Wn)/polyval(b,-1i*Wn) );
          case 3  % highpass
            b = [1 zeros(1,n)];
            b = real( b*den(1)/b(1) );
          case 4  % bandstop
            r = 1i*Wn*((-1).^(0:2*n-1)');
            b = poly(r);
            b = real( b*polyval(den,-1i*0)/polyval(b,-1i*0) );
          otherwise
            coder.internal.error('signal:iirchk:BadFilterType','high','stop','low','bandpass');
        end
    else
        Wn = 2*atan2(Wn,4);
        switch btype
          case 1  % lowpass
            r = -ones(n,1);
            w = 0;
          case 2  % bandpass
            r = [ones(n,1); -ones(n,1)];
            w = Wn;
          case 3  % highpass
            r = ones(n,1);
            w = pi;
          case 4  % bandstop
            r = exp(1i*Wn*( (-1).^(0:2*n-1)' ));
            w = 0;
          otherwise
            coder.internal.error('signal:iirchk:BadFilterType','high','stop','low','bandpass');
        end
        b = poly(r);
        % now normalize so |H(w)| == 1:
        kern = exp(-1i*w*(0:length(b)-1));
        b = real(b*(kern*den(:))/(kern*b(:)));
    end
end

function z = buttzeros(btype,n,Wn,analog)
% This internal function returns more exact zeros.
% Wn input is two element band edge vector
    if analog
        % for lowpass and bandpass, don't include zeros at +Inf or -Inf
        switch btype
          case 1  % lowpass
            z = zeros(0,1);
          case 2  % bandpass
            z = zeros(n,1);
          case 3  % highpass
            z = zeros(n,1);
          case 4  % bandstop
            z = 1i*Wn*((-1).^(0:2*n-1)');
          otherwise
            coder.internal.error('signal:iirchk:BadFilterType','high','stop','low','bandpass');
        end
    else
        Wn = 2*atan2(Wn,4);
        switch btype
          case 1  % lowpass
            z = -ones(n,1);
          case 2  % bandpass
            z = [ones(n,1); -ones(n,1)];
          case 3  % highpass
            z = ones(n,1);
          case 4  % bandstop
            z = exp(1i*Wn*( (-1).^(0:2*n-1)' ));
          otherwise
            coder.internal.error('signal:iirchk:BadFilterType','high','stop','low','bandpass');
        end
    end
end


% LocalWords:  Butterworth Wn th butterworth CHEBY DESIGNFILT btype infzero
% LocalWords:  iirchk Shure Krauss Burrus

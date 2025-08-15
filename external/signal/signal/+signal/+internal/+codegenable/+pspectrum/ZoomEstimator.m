classdef ZoomEstimator < handle
%MATLAB Code Generation Private Function

%   Copyright 2019 The MathWorks, Inc.
%#codegen

    properties (Access = private)
        fstart;
        fstop;
        fs;
        beta;

        nPoints;
        nWindow;
        nfft;

        eIdx;
        nEstimators;
        stride;

        reassign;
        selfAssign;

        % kaiser (besseli(2sqrt(bpos)) argument
        bpos;
        bvel;
        bacc;

        % signal chirp
        Wxpos;
        Wxvel;
        Wxacc;

        % weighting chirp
        Wwpos;
        Wwvel;
        Wwacc;

        % buffer and signal offset indices
        ibuf;
        nSamplesProcessed;
        nSkip;

        % used to compute actual RBW
        ksum;
        ksumsq;

        % used to differentiate window in time domain for frequency  reassignment
        dtpos;
        dtvel;

        % used to differentiate window in frequency domain for time reassignment
        dfpos;
        dfvel;

        % complex weight (aa), signal (bb)
        aa;
        bb;
        bbt; % time reassignment
        bbf; % freq reassignment
        AA;
        BB;
        BBT;
        BBF;

        % upper-right  and lower-left convolutions
        UR;
        LL;
        URT;
        LLT;
        URF;
        LLF;
        ur;
        ll;
        urt;
        llt;
        urf;
        llf;

    end % end of properties
    

    methods (Static)
        
        function bessSqrt = besseli0of2sqrt(x)
            M_SQRT_4OVERPI = 1.1283791670955125738961589031215451716881;
            x = double(x);
            bessSqrt = zeros(size(x));

            for i=1:numel(x)

            if x(i) < 3
              n = 0;
              f = 1;
              s = 1;
              y = 1;
              sn = 0;
            
              while sn < s && n < 60
                sn = s;
                n = n + 1;
                f = f / n.^2;
                y = y * x;
                s = s + f*y;
              end

              bessSqrt(i) = double(s);
            else
                z = 2 * sqrt(x(i));
                rz8 = 1/(8*z);
                w = 1;
                p = 1;

                for idx = 0:8
                    den = double(1+idx);
                    num = (2*den) - 1;
                    frac = (num*num)/den;
                    p = p * rz8 * frac;
                    w = w + p;
                end

                bessSqrt(i) = w * exp(z) * sqrt(rz8) * M_SQRT_4OVERPI;
            end

            end
        end
        
        function dbessSqrt = dbesseli0of2sqrt(x)
            x = double(x);
            dbessSqrt = zeros(size(x));
            M_SQRT_4OVERPI = 1.1283791670955125738961589031215451716881;
            
            for i=1:numel(x)

                if x(i) < 3
                    n = 0;
                    s = 1;
                    p = 1;
                    sn = 0;

                    while sn < s
                        sn = s;
                        n = n + 1;
                        p = p * x(i) * (1/(1+n)) * (1/(2+n));
                        s = s + p;
                    end
                    dbessSqrt(i) = s;
                else
                    z = 2 * sqrt(x(i));
                    rz8 = 1 / (8 * z);
                    w = 1;
                    p = 1;

                    for idx = 0:8
                        den = double(idx + 1);
                        num = 2 * den - 1;
                        frac = -(4 - num*num) / den;
                        p = p * rz8 * frac;
                        w = w + p;
                    end

                    dbessSqrt(i) = w * exp(z) * (sqrt(rz8) / z) * (2 * M_SQRT_4OVERPI);
                end
            end
        
        end

    end


    methods (Access = private)
        
        function allocate(obj)
            % allocate for signal*weight and weight
            obj.aa = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
            obj.bb = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
            obj.AA = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
            obj.BB = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));


            % allocate for upper-right and lower-left convolutions
            obj.UR = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
            obj.LL = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
            obj.ur = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
            obj.ll = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));

            if obj.reassign || true
                % frequency reassignment
                obj.bbf = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
                obj.BBF = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
                obj.URF = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
                obj.LLF = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
                obj.urf = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
                obj.llf = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));

                % time reassignment (skipped when self-assigning in welch mode)
                if ~obj.selfAssign || true
                    obj.bbt = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
                    obj.BBT = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
                    obj.URT = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
                    obj.LLT = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
                    obj.urt = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
                    obj.llt = zeros(obj.nfft, obj.nEstimators, 'like', complex(0));
                end
            end

            obj.bpos = zeros(obj.nEstimators, 1);
            obj.bvel = zeros(obj.nEstimators, 1);
            obj.bacc = zeros(obj.nEstimators, 1);

            obj.Wxpos = zeros(obj.nEstimators, 1, 'like', complex(0));
            obj.Wxvel = zeros(obj.nEstimators, 1, 'like', complex(0));
            obj.Wxacc = zeros(obj.nEstimators, 1, 'like', complex(0));
            
            obj.Wwpos = zeros(obj.nEstimators, 1, 'like', complex(0));
            obj.Wwvel = zeros(obj.nEstimators, 1, 'like', complex(0));
            obj.Wwacc = zeros(obj.nEstimators, 1, 'like', complex(0));

            obj.ibuf = zeros(obj.nEstimators, 1);
            obj.nSamplesProcessed = uint32(zeros(obj.nEstimators, 1));

            obj.ksum = zeros(obj.nEstimators, 1);
            obj.ksumsq = zeros(obj.nEstimators, 1);
            obj.dtpos = zeros(obj.nEstimators, 1);
            obj.dtvel = zeros(obj.nEstimators, 1);
            obj.dfpos = zeros(obj.nEstimators, 1);
            obj.dfvel = zeros(obj.nEstimators, 1);
        end

        function reset(obj, idx)
            % clear out time vectors
            obj.aa(:, idx) = zeros(obj.nfft, 1, 'like', complex(0));
            obj.bb(:, idx) = zeros(obj.nfft, 1, 'like', complex(0));

            % clear out upper right and lower left triangular work matrices
            obj.UR(:, idx) = zeros(obj.nfft, 1, 'like', complex(0));
            obj.LL(:, idx) = zeros(obj.nfft, 1, 'like', complex(0));

            if obj.reassign
                obj.bbf(:, idx) = zeros(obj.nfft, 1, 'like', complex(0));
                obj.URF(:, idx) = zeros(obj.nfft, 1, 'like', complex(0));
                obj.LLF(:, idx) = zeros(obj.nfft, 1, 'like', complex(0));

                if ~obj.selfAssign
                    obj.bbt(:, idx) = zeros(obj.nfft, 1, 'like', complex(0));
                    obj.URT(:, idx) = zeros(obj.nfft, 1, 'like', complex(0));
                    obj.LLT(:, idx) = zeros(obj.nfft, 1, 'like', complex(0));
                end
            end

            % setup bessel argument
            m = double(obj.nWindow - 1);
            b = double(obj.beta * obj.beta) / (m * m);
            obj.bpos(idx) = 0;
            obj.bvel(idx) = b * (m - 1);
            obj.bacc(idx) = -2 * b;

            k0 = double(obj.fstart) / double(obj.fs);
            dk = double(obj.fstart - obj.fstop) / double((obj.nPoints - 1) * obj.fs);

            % setup signal chirp; TODO: do we have 128 bit float in MATLAB?
            obj.Wxpos(idx) = complex(1,0);
            obj.Wxvel(idx) = exp(1i * pi * (dk - 2 * k0));
            obj.Wxacc(idx) = exp(1i * pi * 2 * dk);

            % setup weighting chirp
            obj.Wwpos(idx) = exp(-1i * pi * dk * double(obj.nPoints-1) * double(obj.nPoints-1));
            obj.Wwvel(idx) = exp(1i * pi * dk * double(2 * obj.nPoints - 3));
            obj.Wwacc(idx) = exp(-2i * pi * dk);

            % setup initial values
            obj.ibuf(idx) = 0; 
            obj.nSamplesProcessed(idx) = uint32(0);
            
            obj.ksum(idx) = 0;
            obj.ksumsq(idx) = 0;

            % setup constants for frequency reassignment
            obj.dtpos(idx) = m * b;
            obj.dtvel(idx) = -2 * b;

            % setup frequency ramp for time reassignment
            obj.dfpos(idx) = 0;
            if obj.fs > 0
                obj.dfpos(idx) = -m / double(2 * obj.fs);
            end

            obj.dfvel(idx) = 0;
            if obj.fs > 0
                obj.dfvel(idx) =  1 / double(obj.fs);
            end

            % perform initial weight FFT
            obj.retractWw(idx);

        end

        function accumulateResult(obj, nEst, spectObj)

            obj.ur(:, nEst) = ifft(obj.UR(:, nEst)) * double(obj.nfft);
            obj.ll(:, nEst) = ifft(obj.LL(:, nEst)) * double(obj.nfft);

            if obj.reassign && obj.selfAssign
                obj.urf(:, nEst) = ifft(obj.URF(:, nEst)) * double(obj.nfft);
                obj.llf(:, nEst) = ifft(obj.LLF(:, nEst)) * double(obj.nfft);

                binWidth = double(obj.fstop - obj.fstart) / double(obj.nPoints - 1);
                for i = 1:obj.nPoints
                    obj.assignPower(nEst, i, binWidth, spectObj);
                end
            else
                for i = 1:obj.nPoints
                    spectObj.Pxx(i) = spectObj.Pxx(i) + obj.power(nEst, i);
                end
            end

            spectObj.nAvg = spectObj.nAvg + 1;
        end
        
        function retractWw(obj, nEst)

            for i = 1:obj.nPoints
                obj.aa(obj.nPoints - i + 1, nEst) = obj.Wwpos(nEst);
                obj.Wwpos(nEst) = obj.Wwpos(nEst) * obj.Wwvel(nEst);
                obj.Wwvel(nEst) = obj.Wwvel(nEst) * obj.Wwacc(nEst);
            end
            
            obj.AA(:, nEst) = fft(obj.aa(:, nEst));

        end

        function processBlock(obj, nEst)
            obj.BB(:, nEst) = fft(obj.bb(:, nEst));
            obj.UR(:, nEst) = obj.UR(:, nEst) + obj.AA(:, nEst) .* obj.BB(:, nEst);
                
            if obj.reassign
                obj.BBF(:, nEst) = fft(obj.bbf(:, nEst));
                obj.URF(:, nEst) = obj.URF(:, nEst) + obj.AA(:, nEst) .* obj.BBF(:, nEst);

                if ~obj.selfAssign
                    obj.BBT(:, nEst) = fft(obj.bbt(:, nEst));
                    obj.URT(:, nEst) = obj.URT(:, nEst) + obj.AA(:, nEst) .* obj.BBT(:, nEst);
                end
            end

            obj.retractWw(nEst);
            obj.LL(:, nEst) = obj.LL(:, nEst) + obj.AA(:, nEst) .* obj.BB(:, nEst);

            if obj.reassign
                obj.LLF(:, nEst) = obj.LLF(:, nEst) + obj.AA(:, nEst) .* obj.BBF(:, nEst);

                if ~obj.selfAssign
                    obj.LLT(:, nEst) = obj.LLT(:, nEst) + obj.AA(:, nEst) .* obj.BBT(:, nEst);
                end
            end
        end

        function addToBuffer(obj, nEst, x)
            bess = 1;
            if obj.beta ~= 0
                bess = signal.internal.codegenable.pspectrum.ZoomEstimator.besseli0of2sqrt(obj.bpos(nEst));
            end

            obj.ksum(nEst) = obj.ksum(nEst) + bess;
            obj.ksumsq(nEst) = obj.ksumsq(nEst) + (bess * bess);

            y = x * obj.Wxpos(nEst);

            obj.bb(obj.ibuf(nEst) + 1, nEst) = complex(bess * y);

            if obj.reassign
                dtbess = 0;
                if obj.beta ~= 0
                    dtbess = obj.dtpos(nEst) * signal.internal.codegenable.pspectrum.ZoomEstimator.dbesseli0of2sqrt(obj.bpos(nEst));
                end

                obj.bbf(obj.ibuf(nEst) + 1, nEst) = complex(dtbess * y);
                obj.dtpos(nEst) = obj.dtpos(nEst) + obj.dtvel(nEst);

                if ~obj.selfAssign
                    dfbess = obj.dfpos(nEst) * bess;
                    obj.bbt(obj.ibuf(nEst) + 1, nEst) = complex(dfbess * y);
                    obj.dfpos(nEst) = obj.dfpos(nEst) + obj.dfvel(nEst);
                end
            end

            % update kaiser argument
            obj.bpos(nEst) = obj.bpos(nEst) + obj.bvel(nEst);
            obj.bvel(nEst) = obj.bvel(nEst) + obj.bacc(nEst);

            % update chirp positions
            obj.Wxpos(nEst) = obj.Wxpos(nEst) * obj.Wxvel(nEst);
            obj.Wxvel(nEst) = obj.Wxvel(nEst) * obj.Wxacc(nEst);

            obj.ibuf(nEst) = obj.ibuf(nEst) + 1;
            if obj.ibuf(nEst) == obj.nPoints
                obj.processBlock(nEst);
                obj.ibuf(nEst) = 0;
            end
        end

        function zeroPad(obj, nEst)
            while (obj.ibuf(nEst) < obj.nPoints)
                obj.bb(obj.ibuf(nEst) + 1, nEst) = complex(0);

                if obj.reassign
                    obj.bbf(obj.ibuf(nEst) + 1, nEst) = complex(0);

                    if ~obj.selfAssign
                        obj.bbt(obj.ibuf(nEst) + 1, nEst) = complex(0);
                    end
                end

                obj.ibuf(nEst) = obj.ibuf(nEst) + 1;
            end

            obj.processBlock(nEst);
            obj.ibuf(nEst) = 0;
        end

        function finalizeSpectrum(obj, nEst)
            if (obj.nSamplesProcessed(nEst) > 0) || (obj.ksum(nEst) == 0)
                while (obj.nSamplesProcessed(nEst) < obj.nWindow)
                    bess = 1.0;
                    if obj.beta ~= 0
                        bess = signal.internal.codegenable.pspectrum.ZoomEstimator.besseli0of2sqrt(obj.bpos(nEst));
                    end

                    obj.ksum(nEst) = obj.ksum(nEst) + bess;
                    obj.ksumsq(nEst) = obj.ksumsq(nEst) + (bess * bess);

                    % update kaiser argument
                    obj.bpos(nEst) = obj.bpos(nEst) + obj.bvel(nEst);
                    obj.bvel(nEst) = obj.bvel(nEst) + obj.bacc(nEst);
                    obj.nSamplesProcessed(nEst) = obj.nSamplesProcessed(nEst) + 1;
                end
            end
        end

        function p = power(obj, nEst, idx)
            X = obj.ur(idx, nEst) + obj.ll(idx + obj.nPoints, nEst);
            p = (real(X) * real(X)) + (imag(X) * imag(X));
        end

        function f = frequencyCorrection(obj, nEst, idx)
            
            X = obj.ur(idx, nEst) + obj.ll(idx + obj.nPoints, nEst);
            XF = obj.urf(idx, nEst) + obj.llf(idx + obj.nPoints, nEst);
            deltaK = -imag( XF / X );
            
            f = deltaK * obj.fs / (2 * pi);
        end

        function tCorrection = timeCorrection(obj, nEst, idx)

            X = obj.ur(idx, nEst) + obj.ll(idx + obj.nPoints, nEst);
            XT = obj.urt(idx, nEst) + obj.llt(idx + obj.nPoints, nEst);
            
            tCorrection = real( XT / X );
        end

       
        function assignPower(obj, nEst, idx, binWidth, spectObj)

            X = obj.ur(idx, nEst) + obj.ll(idx + obj.nPoints, nEst);
            pxx = (real(X) * real(X)) + (imag(X) * imag(X));
            XF = obj.urf(idx, nEst) + obj.llf(idx + obj.nPoints, nEst);
            
            deltaK = -imag( XF / X );
            deltaF = deltaK * obj.fs / (2 * pi);

            outBin = round(double(idx - 1) + double(deltaF / binWidth));
            if outBin > 0 &&  outBin < double(obj.nPoints)
                outIdx = coder.internal.indexInt(outBin);
                spectObj.Pxx(outIdx + 1) = spectObj.Pxx(outIdx + 1) + pxx;
            end
        end


        function setup(obj, nwindow, Fs, f1, f2, npts, bta, eidx, nestimators, stride, reassign, selfAssign)
            obj.fstart = double(f1);
            obj.fstop = double(f2);
            obj.fs = double(Fs);
            obj.beta = double(bta);
            obj.nPoints = uint32(npts);
            obj.nWindow = uint32(nwindow);
            obj.nfft = uint32(pow2(double(nextpow2(2*npts - 1))));
            obj.eIdx = uint32(eidx);
            obj.nEstimators = uint32(nestimators);
            obj.stride = double(stride);
            obj.reassign = logical(reassign);
            obj.selfAssign = logical(selfAssign);

            % initialize
            obj.nSamplesProcessed = uint32(zeros(nestimators, 1)); 
            obj.nSkip = int32(round(double(eidx) * stride));
            
            obj.allocate();
        end
    end

    methods (Access = public)
                
        function obj = ZoomEstimator(varargin)
            if ~isempty(varargin)
                nwindow = varargin{1};
                Fs = varargin{2};
                f1 = varargin{3};
                f2 = varargin{4};
                npts = varargin{5};
                bta = varargin{6};
                nestimators = varargin{8};
                eidx = 0:(nestimators-1);
                stride = varargin{9};
                reassign = varargin{10};
                selfAssign = varargin{11};
                obj.setup(nwindow, Fs, f1, f2, npts, bta, eidx, nestimators, stride, reassign, selfAssign);
            else
                obj.nSkip = int32(0);
                obj.nSamplesProcessed = uint32(0);
                obj.nfft = uint32(0);
                obj.reassign = false;
                obj.selfAssign = false;
                obj.nWindow = uint32(0);
                obj.beta = 0;
                obj.fstart = 0;
                obj.fstop = 0;
                obj.fs = 0;
                obj.nPoints = uint32(0);
                obj.bpos = 0;
                obj.bvel = 0;
                obj.bacc = 0;
                obj.ksum = 0;
                obj.ksumsq = 0;

                obj.Wxpos = complex(0);
                obj.Wxvel = complex(0);
                obj.Wxacc = complex(0);
                
                obj.Wwpos = complex(0);
                obj.Wwvel = complex(0);
                obj.Wwacc = complex(0);

                obj.ibuf = 0;
                obj.dtpos = 0;
                obj.dtvel = 0;
                obj.dfpos = 0;
                obj.dfvel = 0;
                
                obj.stride = 0;
                
                obj.eIdx = uint32(0);
                obj.nEstimators = uint32(0);
                
                obj.bbf = zeros(obj.nfft, 1, 'like', complex(0));
                obj.BBF = zeros(obj.nfft, 1, 'like', complex(0));
                obj.URF = zeros(obj.nfft, 1, 'like', complex(0));
                obj.LLF = zeros(obj.nfft, 1, 'like', complex(0));
                obj.urf = zeros(obj.nfft, 1, 'like', complex(0));
                obj.llf = zeros(obj.nfft, 1, 'like', complex(0));
                obj.bbt = zeros(obj.nfft, 1, 'like', complex(0));
                obj.BBT = zeros(obj.nfft, 1, 'like', complex(0));
                obj.URT = zeros(obj.nfft, 1, 'like', complex(0));
                obj.LLT = zeros(obj.nfft, 1, 'like', complex(0));
                obj.urt = zeros(obj.nfft, 1, 'like', complex(0));
                obj.llt = zeros(obj.nfft, 1, 'like', complex(0));
                obj.UR = zeros(obj.nfft, 1, 'like', complex(0));
                obj.LL = zeros(obj.nfft, 1, 'like', complex(0));
                obj.ur = zeros(obj.nfft, 1, 'like', complex(0));
                obj.ll = zeros(obj.nfft, 1, 'like', complex(0));
                obj.aa = zeros(obj.nfft, 1, 'like', complex(0));
                obj.bb = zeros(obj.nfft, 1, 'like', complex(0));
                obj.AA = zeros(obj.nfft, 1, 'like', complex(0));
                obj.BB = zeros(obj.nfft, 1, 'like', complex(0));
            end
        end

        function resetMe(obj, nwindow, Fs, f1, f2, npts, bta, ~, nestimators, stride, reassign, selfAssign)
            eidx = 0:(nestimators-1);
            obj.setup(nwindow, Fs, f1, f2, npts, bta, eidx, nestimators, stride, reassign, selfAssign);
        end
        
        function processSample(obj, nEst, x, spectObj)
            if obj.nSkip(nEst) ~= 0
                obj.nSkip(nEst) = obj.nSkip(nEst) - 1;
            else
                if obj.nSamplesProcessed(nEst) == 0
                    obj.reset(nEst);
                end

                obj.addToBuffer(nEst, x);
                
                obj.nSamplesProcessed(nEst) = obj.nSamplesProcessed(nEst) + 1;
                if obj.nSamplesProcessed(nEst) == obj.nWindow
                    if (obj.ibuf(nEst) > 1)
                        obj.zeroPad(nEst);
                    end

                    obj.accumulateResult(nEst, spectObj);
                    obj.nSamplesProcessed(nEst) = uint32(0);

                    % compute number of points to skip before re-enabling
                    lastIdx = uint32(round(obj.stride * double(obj.eIdx(nEst))));
                    nextIdx = uint32(round(obj.stride * double(obj.eIdx(nEst) + obj.nEstimators))); 
                    obj.eIdx(nEst) = obj.eIdx(nEst)  + obj.nEstimators;

                    obj.nSkip(nEst) = int32(nextIdx) - int32(lastIdx) - int32(obj.nWindow);
                end
            end
        end

        function powScale = getPowerScaling(obj, nEst)
            obj.finalizeSpectrum(nEst);

            if obj.reassign
                % correct by RMS power gain of window when using reassignment (since we integrate)
                ifftCorrect = double(obj.nfft);
                powScale = double(obj.ksumsq(nEst) * ifftCorrect * ifftCorrect * double(obj.nPoints));
            else
                % correct by DC power gain of window otherwise (to get a spectral peak to appear 
                windowGain = obj.ksum(nEst) * double(obj.nfft);
                powScale = double(windowGain * windowGain);
            end
        end

        function psdScale = getPSDScaling(obj, nEst)
            obj.finalizeSpectrum(nEst);

            % correct by RMS power gain of window (we do not expect reassignment with a 'psd' option)
            ifftCorrect = double(obj.nfft);
            psdScale = obj.fs * obj.ksumsq(nEst) * ifftCorrect * ifftCorrect;
        end

        
        function df = getFrequencyAssignment(obj, nEst)
            df = zeros(obj.nPoints, 1);

            if obj.reassign && ~obj.selfAssign
                obj.urf(:, nEst) = ifft(obj.URF(:, nEst)) * double(obj.nfft);
                obj.llf(:, nEst) = ifft(obj.LLF(:, nEst)) * double(obj.nfft);

                for i = 1:obj.nPoints
                    df(i) = obj.frequencyCorrection(nEst, i);
                end
            end
        end

        function dt = getTimeAssignment(obj, nEst)
            dt = zeros(obj.nPoints, 1);

            if obj.reassign && ~obj.selfAssign
                obj.urt(:, nEst) = ifft(obj.URT(:, nEst)) * double(obj.nfft);
                obj.llt(:, nEst) = ifft(obj.LLT(:, nEst)) * double(obj.nfft);

                for i = 1:obj.nPoints
                    dt(i) = obj.timeCorrection(nEst, i);
                end
            end
        end

        function nSamples = getNumSamplesProcessed(obj, nEst)
            nSamples = uint32(obj.nSamplesProcessed(nEst));
        end

        function flush(obj, nEst, spectObj)
            if obj.nSamplesProcessed(nEst) ~= 0
                obj.zeroPad(nEst);
                obj.accumulateResult(nEst, spectObj);
            end
        end

        function rbw = getRBW(obj, nEst)
            rbw = double( obj.fs * obj.ksumsq(nEst) / (obj.ksum(nEst) * obj.ksum(nEst)));
        end
    end
end

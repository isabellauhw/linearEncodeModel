classdef ZoomSpectrum < handle
%MATLAB Code Generation Private Function

%   Copyright 2019 The MathWorks, Inc.
%#codegen

    properties (Access = public)
        % user supplied properties
        t1
        t2
        f1
        f2
        beta
        nPoints
        t0
        fs
        maxFs
        targetRBW
        autoZoom
        reassigning

        % work storage for spectrum
        nAvg
        Pxx
        Estimators
        nExpected
        nSkip
        nRemaining
        nWindow
        nEstimators
        nProcessed
        nSegments
    end
         
    methods (Static)
        function l = preventEmptyLength(len)
            if len == 0
                l = uint32(1);
            else
                l = uint32(len(1));
            end
        end

        function dstSpectrum = performFreqReassignment(dstSpectrum, originalSpectrum, df, f1, f2, convertToDB)
            spectrumSize = length(originalSpectrum);

            if length(dstSpectrum) ~= spectrumSize
                dstSpectrum = zeros(spectrumSize, 1);
            end
            
            for j = 1:spectrumSize
                fOffset = double(df(j));
                % Calculate the array index where the reassignment will happen
                jFreq = double(round(double(j - 1) + fOffset * double(spectrumSize - 1) / double(f2 - f1)));

                if jFreq >= 0 && jFreq < spectrumSize
                    jj = coder.internal.indexInt(floor(jFreq) + 1);
                    dstSpectrum(jj) = dstSpectrum(jj) + originalSpectrum(j);
                end
            end

            if convertToDB
                for idx = 1:spectrumSize
                    dstSpectrum(idx) = 10 * log10(dstSpectrum(idx));
                end
            end
        end

        function enbwE = enbwEstimate(beta)
            poly1 = [-7.42100220301407e-05,  0.0010951661775193,  -0.00601630113184729,  0.0135330207063678, ...
                -0.00553286257981127,   0.00188967508127851, -0.000245892879902476, 1.00000397846243];

            poly2 = [5.69809789173636e-06, -0.000159680213659123, 0.00182733327457552, -0.0104618197432362, ...
                0.0265970133409903, 0.00682196582785356, -0.0609769138391775, 1.04788712768061];
            
            poly3 = [7.68603379795731e-12, -1.66807848853759e-09, 1.5594811121591e-07, -8.2806698857875e-06, ...
                0.000279922339315112, -0.00665206774673593, 0.161004938614092, 0.690887010063724];


            if (beta <= 2.9)
                poly = poly1;
            else
                if (beta <= 4.9)
                    poly = poly2;
                else
                    poly = poly3;
                end
            end

            result = 0;
            for idx = 1:8
                result = result * double(beta) + poly(idx);
            end
            
            enbwE = double(result);
        end
        
    end

    methods (Access = private)
        
        function processSample(obj, x)
            for idx = 1:obj.nEstimators
                obj.Estimators.processSample(idx, x, obj);
            end
        end

        function configureCZT(obj)
            % configure CZT using approximate esitmate of enbw
            estENBW = signal.internal.codegenable.pspectrum.ZoomSpectrum.enbwEstimate(obj.beta);

            % determine window length
            obj.nWindow = uint32(round(obj.fs * estENBW / obj.targetRBW));

            % don't ever let the window length be zero or overrun the expected number of samples between t1 and t2
            obj.nWindow = signal.internal.codegenable.pspectrum.ZoomSpectrum.preventEmptyLength(min(obj.nWindow, obj.nExpected));

            % compute target stride
            stride = double(obj.nWindow) / double(2 * estENBW - 1);
            stride = max(stride, 1);

            % quantize number of segments between t1 and t2
            obj.nSegments = uint32(1 + ceil(double(obj.nExpected - obj.nWindow)/stride));

            if obj.nSegments > 1 && obj.nWindow > 1
                % recompute stride based upon quantized number of segments
                stride = double(obj.nExpected - obj.nWindow) / double(obj.nSegments - 1);
                obj.nEstimators = uint32(ceil(double(obj.nWindow - 1) / stride));
            else
                stride = double(obj.nWindow);
                obj.nEstimators = uint32(1);
            end

            % perform self-reassignment only when using Welch estimation
            selfAssign = (obj.nSegments ~= 1);
                        
            ZeObj = signal.internal.codegenable.pspectrum.ZoomEstimator(obj.nWindow, obj.fs, obj.f1, obj.f2, obj.nPoints, ...
                obj.beta, 0, obj.nEstimators, stride, obj.reassigning, selfAssign);
            obj.Estimators = ZeObj;
        end

        function gain = finalizeSpectrum(obj)
            pwrScaling = 0;
            % attempt to get power scaling for complete segment
            for idx = 1:obj.nEstimators
                if pwrScaling ~= 0
                    break;
                end

                if obj.Estimators.getNumSamplesProcessed(idx) == 0
                    pwrScaling = obj.Estimators.getPowerScaling(idx);
                end
            end

            if obj.nRemaining ~= 0
                % find largest outstanding segment
                maxNumSamplesProcessed = uint32(0);
                for idx = 1:obj.nEstimators
                    maxNumSamplesProcessed = max(maxNumSamplesProcessed, obj.Estimators.getNumSamplesProcessed(idx));
                end

                % process it
                if maxNumSamplesProcessed > 0
                    for idx = 1:obj.nEstimators
                        if maxNumSamplesProcessed == obj.Estimators.getNumSamplesProcessed(idx)
                            % include this segment in computation
                            obj.Estimators.flush(idx, obj);

                            % grab the power scaling if needed
                            if pwrScaling == 0
                                pwrScaling = obj.Estimators.getPowerScaling(idx);
                            end

                            break;
                        end 
                    end
                end
            end

            gain = NaN;
            if obj.nEstimators > 0
                gain = double(pwrScaling * double(obj.nAvg));
            end

            if obj.nProcessed > 1 && obj.nExpected > 1 && ...
                obj.nProcessed < obj.nExpected

                gain = gain * double(double(obj.nProcessed) / double(obj.nExpected));
            end
        end

        function dstSpectrum = fetchSpectrum(obj, convertToDB, gain, dstSpectrum)
            if length(dstSpectrum) < obj.nPoints
                dstSpectrum = zeros(obj.nPoints, 1);
            end

            if convertToDB
                dBgain = double(10 * log10(gain));

                for idx = 1:obj.nPoints
                    dstSpectrum(idx) = 10 * log10(obj.Pxx(idx)) - dBgain;
                end
            else
                for idx = 1:obj.nPoints
                    dstSpectrum(idx) = double(obj.Pxx(idx)) / double(gain);
                end
            end
        end

        function deleteEstimators(obj)
            obj.Estimators = signal.internal.codegenable.pspectrum.ZoomEstimator();
        end

    end % end of private methods
    

    methods 
        function obj = ZoomSpectrum()
            obj.nSkip = uint32(0);
            obj.Estimators = signal.internal.codegenable.pspectrum.ZoomEstimator();
        end

        function setup(obj, inT1, inT2, inF1, inF2, inBeta, inNpoints, inMaxFs, autoZoomFFT, varargin)
            if isempty(varargin)
                reassign = false;
            else
                reassign = logical(varargin{1});
            end
            
            obj.t1 = double(inT1(1));
            obj.t2 = double(inT2(1));
            obj.f1 = double(inF1(1));
            obj.f2 = double(inF2(1));
            obj.maxFs = double(inMaxFs(1));

            if inBeta > 40
                obj.beta = 40;
            else 
                if inBeta >= 0
                    obj.beta = double(inBeta(1));
                else
                    obj.beta = 0;
                end
            end

            obj.nPoints = uint32(inNpoints(1));
            obj.autoZoom = logical(autoZoomFFT(1));

            obj.reassigning = logical(reassign(1));
            
            estENBW = signal.internal.codegenable.pspectrum.ZoomSpectrum.enbwEstimate(obj.beta);

            if obj.autoZoom
                fspan = double(abs(obj.f2 - obj.f1));
            else
                fspan = obj.maxFs;
            end

            obj.targetRBW = max(estENBW / (abs(obj.t2 - obj.t1) + eps), fspan / double(obj.nPoints - 1));
        end

        function resetEstimator(obj, tFirstSample, inFs, tSignalStart, tSignalEnd)
            obj.t0 = double(tFirstSample);
            obj.fs = double(inFs);

            ts = 1.0 / obj.fs;

            tSignalStart = double(tSignalStart);
            tSignalEnd = double(tSignalEnd);

            % set expectations
            t1Seg = double(max(tSignalStart, obj.t1));
            t2Seg = double(min(tSignalEnd, obj.t2));

            obj.nExpected = signal.internal.codegenable.pspectrum.ZoomSpectrum.preventEmptyLength(uint32(abs((t2Seg - t1Seg) * obj.fs)));
            obj.nRemaining = obj.nExpected;

            obj.nProcessed = 0;
            obj.nSkip = uint32(0);

            if obj.t0 < t1Seg
                % we need to skip all points before t1
                obj.nSkip = uint32((t1Seg - obj.t0) * obj.fs);
            elseif ((obj.t0 - t1Seg) > ts)
                % we are missing samples
                obj.nRemaining = obj.nRemaining - uint32(obj.fs * (obj.t0 - t1Seg));
            end

            if obj.t0 > t2Seg
                % if no samples are in range, grab the first available sample as a zero-order approximation
                obj.nRemaining = uint32(1);
            end

            % configure CZT using approximate esitmate of enbw
            estENBW = signal.internal.codegenable.pspectrum.ZoomSpectrum.enbwEstimate(obj.beta);
            
            % determine window length
            obj.nWindow = uint32(round(obj.fs * estENBW / obj.targetRBW));

            % don't ever let the window length be zero or overrun the expected number of samples between t1 and t2
            obj.nWindow = signal.internal.codegenable.pspectrum.ZoomSpectrum.preventEmptyLength(min(obj.nWindow, obj.nExpected));

            % compute target stride
            stride = double(obj.nWindow) / double(2 * estENBW - 1);
            stride = max(stride, 1);
            
            % quantize number of segments between t1 and t2
            obj.nSegments = uint32(1 + ceil(double(obj.nExpected - obj.nWindow)/stride));

            if obj.nSegments > 1 && obj.nWindow > 1
                % recompute stride based upon quantized number of segments
                stride = double(obj.nExpected - obj.nWindow) / double(obj.nSegments - 1);
                obj.nEstimators = uint32(ceil(double(obj.nWindow - 1) / stride));
            else
                stride = double(obj.nWindow);
                obj.nEstimators = uint32(1);
            end

            % perform self-reassignment only when using Welch estimation
            selfAssign = (obj.nSegments ~= 1);
            
            obj.Estimators.resetMe(obj.nWindow, obj.fs, obj.f1, obj.f2, obj.nPoints, ...
                    obj.beta, 0, obj.nEstimators, stride, obj.reassigning, selfAssign);
          
            obj.Pxx = zeros(obj.nPoints, 1);
            obj.nAvg = 0;
        end

        function specifyTimeVector(obj, tFirstSample, inFs, tSignalStart, tSignalEnd)
            obj.t0 = double(tFirstSample(1));
            obj.fs = double(inFs(1));

            ts = 1.0 / obj.fs;

            tSignalStart = double(tSignalStart(1));
            tSignalEnd = double(tSignalEnd(1));

            % set expectations
            t1Seg = double(max(tSignalStart, obj.t1));
            t2Seg = double(min(tSignalEnd, obj.t2));

            obj.nExpected = signal.internal.codegenable.pspectrum.ZoomSpectrum.preventEmptyLength(uint32(floor(abs((t2Seg - t1Seg) * obj.fs))));
            obj.nRemaining = obj.nExpected;

            obj.nProcessed = 0;
            obj.nSkip = uint32(0);

            if obj.t0 < t1Seg
                % we need to skip all points before t1
                obj.nSkip = uint32(floor((t1Seg - obj.t0) * obj.fs));
            elseif ((obj.t0 - t1Seg) > ts)
                % we are missing samples
                obj.nRemaining = obj.nRemaining - uint32(floor(obj.fs * (obj.t0 - t1Seg)));
            end

            if obj.t0 > t2Seg
                % if no samples are in range, grab the first available sample as a zero-order approximation
                obj.nRemaining = uint32(1);
            end

            obj.configureCZT();

            obj.Pxx = zeros(obj.nPoints, 1);
            obj.nAvg = 0;
        end

        function anyRemains = processSegment(obj, x)
            nx = uint32(length(x));
            idx = uint32(0);

            while (idx < nx && obj.nSkip ~= 0)
                idx = idx + 1;
                obj.nSkip = obj.nSkip - 1;
            end

            while (idx < nx && obj.nRemaining ~= 0)
                obj.processSample(x(idx+1));
                idx = idx + 1;
                obj.nRemaining = obj.nRemaining - 1;
                obj.nProcessed = obj.nProcessed + 1;
            end

            anyRemains = (obj.nRemaining ~= 0);
        end

        function bWidth = getActualResolutionBandwidth(obj)
            bWidth = NaN;
            if obj.nEstimators > 0
                bWidth = obj.Estimators.getRBW(1);
            end
        end

        function bWidth = getTargetResolutionBandwidth(obj)
            bWidth = obj.targetRBW;
        end

        function dstSpectrum = fetchOneSidedSpectrum(obj, convertToDB)
            % Scale all bins by two
            % Note that regions within the kernel width of DC (and Nyqyuist) bin will be overcompensated:
            % A natural way to fix this would be to compute and remove the DC component from the signal,
            % perform spectrum (scaling by two), then restore the removed components without scaling.
            % we would need to perform this step during setup.
            
            gain = obj.finalizeSpectrum() / 2;

            if isempty(convertToDB)
                convertToDB = true;
            end
            
            dstSpectrum = zeros(obj.nPoints, 1);
            dstSpectrum = obj.fetchSpectrum(convertToDB, gain, dstSpectrum);
        end
        
        function dstSpectrum = fetchOneSidedReassignedSpectrum(obj, convertToDB)
            originalSpectrum = obj.fetchOneSidedSpectrum(false);
            
            df = obj.fetchFrequencyReassignment();

            dstSpectrum = zeros(obj.nPoints, 1);
            dstSpectrum = signal.internal.codegenable.pspectrum.ZoomSpectrum.performFreqReassignment(dstSpectrum, originalSpectrum, df, obj.f1, obj.f2, convertToDB);
        end

        function dstSpectrum = fetchTwoSidedSpectrum(obj, convertToDB)
            gain = obj.finalizeSpectrum();

            if isempty(convertToDB)
                convertToDB = true;
            end

            dstSpectrum = zeros(obj.nPoints, 1);
            dstSpectrum = obj.fetchSpectrum(convertToDB, gain, dstSpectrum);
        end

        
        function dstSpectrum = fetchTwoSidedReassignedSpectrum(obj, convertToDB)
            originalSpectrum = obj.fetchTwoSidedSpectrum(false);
            
            df = obj.fetchFrequencyReassignment();
            
            dstSpectrum = zeros(obj.nPoints, 1);
            dstSpectrum = signal.internal.codegenable.pspectrum.ZoomSpectrum.performFreqReassignment(dstSpectrum, originalSpectrum, df, obj.f1, obj.f2, convertToDB);
        end

        function f = fetchFrequencyVector(obj)
            f = zeros(obj.nPoints, 1);

            % compute frequency spacing between the points
            dF = double(obj.f2 - obj.f1) / double(obj.nPoints - 1);

            for idx = 1:obj.nPoints
                f(idx) = obj.f1 + double(idx - 1) * dF; 
            end
        end

        function dt = fetchTimeReassignment(obj)
            dt = zeros(obj.nPoints, 1);

            if obj.nEstimators == 1
                dt = obj.Estimators.getTimeAssignment(1);
            end
        end

        function df = fetchFrequencyReassignment(obj)
            df = zeros(obj.nPoints, 1);

            if obj.nEstimators == 1
                df = obj.Estimators.getFrequencyAssignment(1);
            end
        end
    
    end % end of public methods

end



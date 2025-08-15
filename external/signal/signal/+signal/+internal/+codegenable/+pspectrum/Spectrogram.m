classdef Spectrogram < handle
%MATLAB Code Generation Private Function

%   Copyright 2019 The MathWorks, Inc.
%#codegen

    properties (Access = private)
        bIncludeInZlimitsCalculation;
        spectrogramData;
        spectrogramDataLen;
        mStftMatrix;
        mStftTimeCorrections;
        mStftFreqCorrections;
        frequencyVector;
        timeVector;

        % create buffer to store data and time
        dataTimeBuffer;
        dataTimeBufferIm;
        winStartIndex;

        % parameter required for spectrogram computation
        timeResolution;
        timeResolutionSamples;
        actualOverlapPercentage;
        overlap;
        overlapSamples;
        totalSignalSamples;
        totalInputSignalSamples;
        totalWindows;
        timeFactor;

        % parameter required by zoomSpectrum
        fs;
        signalBeginTime;
        signalEndTime;
        t1;
        t2;
        f1;
        f2;
        beta;
        nPoints;
        maxFs;
        bComputeZLimits;
        useZoomFFT;
        useReassignement;
        bIsTwoSided;
        bIsConvertToDB;

        %output properties
        zMin;
        zMax;
        tgtRBW;
        LastWindowTEnd;
    end

    methods (Static)
        function numOfWindows = computeTotalNumberOfWindows(totalSignalSamples, timeResolutionSamples, overlapSamples)
            % We use totalInputSignalSamples instead of totalSignalSamples because size of matrix required will be less
            % totalInputSignalSamples = length of signal reqwuested, totalSignalSamples = length of entire signal in samples
            % if we use totalSignalSamples then memory will be reserved for storing entire spectrogram instead of the spectrogram we computed.
            % So use totalInputSignalSamples  and reserve the memory only for spectrogram windows we compute.
            
            if totalSignalSamples < timeResolutionSamples
                numOfWindows = uint32(1);
            else
                numOfWindows = uint32(ceil((double(totalSignalSamples - overlapSamples)) / (double(timeResolutionSamples - overlapSamples)))) + uint32(1);
            end
        end

        function [overlapSamples, perOverlap] = computeOverlapSamples(perOverlap, timeResolutionSamples)
            % we take floor value to ensure that overlapSamples less than timeResolution
            overlapSamples = uint32(floor((double(perOverlap) / 100) * double(timeResolutionSamples)));
            perOverlap = (100 * double(overlapSamples)) / double(timeResolutionSamples);
        end

        function numberOfWindowSamples = calculateTimeResolutionSamples(numberOfSignalSamples)
            numberOfWindowSamples = uint32(numberOfSignalSamples); %#ok<NASGU>

            if numberOfSignalSamples >= 16384
                numberOfWindowSamples = uint32(ceil(double(numberOfSignalSamples) / 128.0));
            elseif numberOfSignalSamples >= 8192
                numberOfWindowSamples = uint32(ceil(double(numberOfSignalSamples) / 64.0));
            elseif numberOfSignalSamples >= 4096
                numberOfWindowSamples = uint32(ceil(double(numberOfSignalSamples) / 32.0));
            elseif numberOfSignalSamples >= 2048
                numberOfWindowSamples = uint32(ceil(double(numberOfSignalSamples) / 16.0));
            elseif numberOfSignalSamples >= 64
                numberOfWindowSamples = uint32(ceil(double(numberOfSignalSamples) / 8.0));
            else
                numberOfWindowSamples = uint32(ceil(double(numberOfSignalSamples) / 2.0));
            end
        end

        function [minValue, maxValue] = getFiniteExtrema(v, minValue, maxValue)
            % Get min and max Y values and avoid Inf and NaN values
            for idx = 1:numel(v)
                value = v(idx);
                if isfinite(value)
                    if value < minValue
                        minValue = value;
                    end

                    if value > maxValue
                        maxValue = value;
                    end
                end
            end
        end

    end

    methods (Access = private)
        function timeCorrections = getTimeCorrectionsMatrix(obj)
            timeCorrections = obj.mStftTimeCorrections;
        end

        function freqCorrections = getFreqCorrectionsMatrix(obj)
            freqCorrections = obj.mStftFreqCorrections;
        end

        function performReassignment(obj)
            srcDataWidth = coder.internal.indexInt(obj.totalWindows);
            srcDataHeight = coder.internal.indexInt(obj.nPoints);

            for i = 1:srcDataWidth
                for j = 1:srcDataHeight
                    tOffset = double(obj.mStftTimeCorrections(i,j));
                    fOffset = double(obj.mStftFreqCorrections(i,j));
                    iTime = round(double(i - 1) + tOffset * double(srcDataWidth - 1) / (obj.t2 - obj.t1));
                    jFreq = round(double(j - 1) + fOffset * double(srcDataHeight - 1) / (obj.f2 - obj.f1));

                    if iTime >= 0 && iTime < srcDataWidth && ...
                        jFreq >= 0 && jFreq < srcDataHeight
                        ii = coder.internal.indexInt(iTime);
                        jj = coder.internal.indexInt(jFreq);
                        obj.spectrogramData(ii * srcDataHeight + jj + 1) = ...
                            obj.spectrogramData(ii * srcDataHeight + jj + 1) + obj.mStftMatrix(i,j);
                    end
                end
            end
        end

        function createSpectrogramData(obj, bAddEps)
            obj.totalWindows = obj.winStartIndex;

            if obj.useReassignement
                obj.spectrogramData = zeros(obj.totalWindows * obj.nPoints, 1, 'like', double(0));
                obj.spectrogramDataLen = uint32(numel(obj.spectrogramData));
                obj.performReassignment();
                dataMin = Inf;
                dataMax = -Inf;

                for i = 1:length(obj.spectrogramData)
                    if bAddEps
                        obj.spectrogramData(i) = obj.spectrogramData(i) + eps;
                    end
                    if obj.bIsConvertToDB
                        obj.spectrogramData(i) = 10 * log10(obj.spectrogramData(i));
                    end

                    jdx = coder.internal.indexInt(double(i - 1) / double(obj.nPoints));
                    if isfinite(obj.spectrogramData(i)) && obj.bIncludeInZlimitsCalculation(jdx + 1)
                        dataMin = min(dataMin, obj.spectrogramData(i));
                        dataMax = max(dataMax, obj.spectrogramData(i));
                    end
                end

                if obj.bComputeZLimits
                    % For reassigned spectrogram , we set ZMin and ZMax here
                    obj.zMax = dataMax;
                    obj.zMin = dataMin;
                end
            else
                % in not using reassignment, convert MATLAB_EPS_VALUE to dB only if it was requested for data 
                isConvertToDBFlag = ~obj.useReassignement && obj.bIsConvertToDB;
                % This variable hold the Matlab Eps value if we are requesting data from the app 
                dataOffsetValue = 0; %#ok<NASGU>

                bZMinSet = false;
                bZMaxSet = false;

                obj.spectrogramData = zeros(obj.totalWindows * obj.nPoints, 1,'like', double(0));
                spectrogramDataPos = 0;

                for i = 1:obj.totalWindows
                    for j = 1:obj.nPoints
                        spectrogramDataPos = spectrogramDataPos + 1;

                        if bAddEps && isConvertToDBFlag
                            dataOffsetValue = eps;
                            if isfinite(obj.zMax) && ~bZMaxSet
                                obj.zMax = 10 * log10(power(10, (obj.zMax / 10)) + dataOffsetValue);
                                bZMaxSet = true;
                            elseif ~bZMaxSet
                                % When we are computing for spectrogram domain,  if zMax id not finite then we need to set is as esp, if addEps is requested
                                % This is to replicate the functionality of Matlab functions
                                obj.zMax = 10 * log10(dataOffsetValue);
                                bZMaxSet = true;
                            end

                            if isfinite(obj.zMin) && ~bZMinSet
                                obj.zMin = 10 * log10(power(10, (obj.zMin / 10)) + dataOffsetValue);
                                bZMinSet = true;
                            elseif ~bZMinSet
                                % When we are computing for spectrogram domain,  if zMax id not finite then we need to set is as eps, if addEps is requested
                                % This is to replicate the functionality of Matlab functions
                                obj.zMin = 10 * log10(dataOffsetValue);
                                bZMinSet = true;
                            end

                            obj.spectrogramData(spectrogramDataPos) = ...
                                10 * log10(power(10, (obj.mStftMatrix(i, j) / 10) + dataOffsetValue));
                        elseif bAddEps 
                            dataOffsetValue = eps;
                            if ~bZMaxSet
                                obj.zMax = obj.zMax + dataOffsetValue;
                                bZMaxSet = true;
                            end
                            if ~bZMinSet
                                obj.zMin = obj.zMin + dataOffsetValue;
                                bZMinSet = true;
                            end

                            obj.spectrogramData(spectrogramDataPos) = obj.mStftMatrix(i,j) + dataOffsetValue;
                        else
                            obj.spectrogramData(spectrogramDataPos) = obj.mStftMatrix(i, j);
                        end
                    end
                end
            end

            obj.spectrogramDataLen = uint32(numel(obj.spectrogramData));

            if isinf(obj.zMin)
                % if zMin in not finite then set it as the minimum possible value
                % because when we compute spectrogram for persistence domain we don't add eps
                obj.zMin = 10 * log10(1.175494351e-38);
            end

            if isinf(obj.zMax)
                % if zMax in not finite then set it as the maximum possible value
                % because when we compute spectrogram for persistence domain we don't add eps
                obj.zMax = 10 * log10(3.402823466e+38);
            end

            if obj.zMin == obj.zMax
                % if zMin and zMax are equal then add 1% buffer to the max value
                % This condition only occurs when all value in matrix are same
                obj.zMin = obj.zMin - (0.01 * abs(obj.zMin));
                obj.zMax = obj.zMax + (0.01 * abs(obj.zMax));
            end
        end
    end

    methods (Access = public)
        function obj = Spectrogram()
            obj.spectrogramDataLen = uint32(0);
            obj.dataTimeBuffer = signal.internal.codegenable.pspectrum.WindowDataBuffer();
            obj.tgtRBW = Inf;
            obj.zMin = Inf;
            obj.zMax = -Inf;
        end

        function spectData = getSpectrogramData(obj)
            if obj.spectrogramDataLen == 0
                obj.createSpectrogramData(true);
            end
            spectData = obj.spectrogramData;
        end

        function spectMatrix = getSpectrogramMatrix(obj)
            if obj.spectrogramDataLen == 0
                obj.createSpectrogramData(true);
            end
            spectMatrix = reshape(obj.spectrogramData, obj.getNPoints(), obj.getTotalWindows());
        end

        function tend = getTEnd(obj)
            tend = obj.LastWindowTEnd;
        end

        function trbw = getTargetResolutionBandwidth(obj)
            trbw = obj.tgtRBW;
        end

        function zmax = getZMax(obj)
            zmax = obj.zMax;
        end

        function zmin = getZMin(obj)
            zmin = obj.zMin;
        end

        function timeResolution = getTimeResolution(obj)
            timeResolution = obj.timeResolution / obj.timeFactor;
        end

        function timeResolutionSamples = getTimeResolutionSamples(obj)
            timeResolutionSamples = obj.timeResolutionSamples;
        end

        function overlapPerc = getActualOverlapPercentage(obj)
            overlapPerc = obj.actualOverlapPercentage;
        end

        function totalWin = getTotalWindows(obj)
            totalWin = obj.totalWindows;
        end

        function npoints = getNPoints(obj)
            npoints = obj.nPoints;
        end

        function setup(obj, bComputeTimeResolution, timeResolutionIn, OverlapPercentIn, totalSignalSamplesIn, ...
            totalInputSignalSamplesIn, timeFactorIn, fsIn, ...
            signalBeginTimeIn, signalEndTimeIn, t1In, ...
            t2In, f1In, f2In, betaIn, nPointsIn, maxFsIn, ...
            bComputeZLimitsIn, useZoomFFTIn, useReassignementIn, isConvertToDBIn, isTwoSidedIn)

            assert(f2In > f1In, 'f2IN must be greater than f1IN');
            assert(totalInputSignalSamplesIn ~= 0, 'totalInputSignalSamplesIN cannot be zero');
            assert(totalSignalSamplesIn ~= 0, 'totalSignalSamples cannot be zero');

            if logical(bComputeTimeResolution)
                % caluclate time resolution based on whole signal
                obj.timeResolutionSamples = uint32(signal.internal.codegenable.pspectrum.Spectrogram.calculateTimeResolutionSamples(totalSignalSamplesIn));
            else
                if timeFactorIn ~= 1
                    % ensure that timeResolution is always multiple of sample values
                    obj.timeResolutionSamples = uint32(floor(timeResolutionIn));
                else
                    % ensure that never get timeResolutionIn = 0
                    obj.timeResolutionSamples = uint32(floor(timeResolutionIn * fsIn));
                end
            end

            if obj.timeResolutionSamples == uint32(0)
                obj.timeResolutionSamples = uint32(1);
            end

            timeResolutionIn = double(obj.timeResolutionSamples) / fsIn;
            assert(timeResolutionIn(1) ~= 0, 'timeResolution cannot be zero');

            % when we compute oversamplesin, computeOverlapSamples() modifies the OverlapPercentIn to the correct OverlapPercent used for calculation
            [ovlpSamples, OverlapPercentIn] = signal.internal.codegenable.pspectrum.Spectrogram.computeOverlapSamples(OverlapPercentIn, obj.timeResolutionSamples);
            obj.overlapSamples = ovlpSamples(1);
            assert(obj.timeResolutionSamples(1) > obj.overlapSamples(1), 'timeResolution must be greater than Overlap');

            obj.timeResolution = double(timeResolutionIn(1));
            obj.actualOverlapPercentage = double(OverlapPercentIn);
            obj.overlap = double(obj.overlapSamples) / fsIn;
            obj.totalSignalSamples = uint32(totalSignalSamplesIn(1));
            obj.totalInputSignalSamples = uint32(totalInputSignalSamplesIn(1));
            obj.timeFactor = double(timeFactorIn(1));
            obj.fs = double(fsIn(1));
            obj.signalBeginTime = double(signalBeginTimeIn(1) * obj.timeFactor);
            obj.signalEndTime = double(signalEndTimeIn(1) * obj.timeFactor);
            obj.t1 = double(t1In(1));
            obj.t2 = double(t2In(1));
            obj.f1 = double(f1In(1));
            obj.f2 = double(f2In(1));
            obj.beta = double(betaIn(1));
            obj.nPoints = uint32(nPointsIn(1));
            obj.maxFs = double(maxFsIn(1));
            obj.bComputeZLimits = logical(bComputeZLimitsIn(1));
            obj.zMin = Inf;
            obj.zMax = -Inf;
            obj.useZoomFFT = logical(useZoomFFTIn(1));
            obj.useReassignement = logical(useReassignementIn(1));
            totalWins = signal.internal.codegenable.pspectrum.Spectrogram.computeTotalNumberOfWindows(obj.totalInputSignalSamples, obj.timeResolutionSamples, ...
                    obj.overlapSamples);
            obj.totalWindows = totalWins(1);
            obj.winStartIndex = uint32(0);
            obj.LastWindowTEnd = double(obj.signalBeginTime);
            obj.mStftMatrix = zeros(obj.totalWindows, obj.nPoints, 'like', double(0));
            obj.mStftTimeCorrections = zeros(obj.totalWindows, obj.nPoints, 'like', double(0));
            obj.mStftFreqCorrections = zeros(obj.totalWindows, obj.nPoints, 'like', double(0));
            obj.frequencyVector = zeros(obj.nPoints, 1, 'like', double(0));
            obj.timeVector = zeros(obj.totalWindows, 1, 'like', double(0));
            obj.bIsTwoSided = logical(isTwoSidedIn);
            obj.bIsConvertToDB = logical(isConvertToDBIn);

            %if obj.useReassignement
                obj.bIncludeInZlimitsCalculation = false(obj.totalWindows, 1);
            %end
        end

        function computeSpectrogramCore(obj, dataRe, dataIm, dataBeginTime, isLastData, numOfWin, bAddEps)
            if obj.winStartIndex < obj.totalWindows && ...
                obj.LastWindowTEnd < obj.signalEndTime + (1 / (obj.fs))

                dataBeginTime = dataBeginTime * obj.timeFactor;
                
                for idx = obj.winStartIndex:(obj.winStartIndex + uint32(numOfWin))
                    tStart = double(dataBeginTime +  double(idx - obj.winStartIndex) * double(obj.timeResolution - obj.overlap));
                    tEnd = tStart + obj.timeResolution;
                    obj.timeVector(idx + 1) = tStart + (tEnd - tStart) / 2;
                    lZoomSpectrum = signal.internal.codegenable.pspectrum.ZoomSpectrum;
                    lZoomSpectrum.setup(tStart, tEnd, obj.f1, obj.f2, obj.beta, obj.nPoints, obj.maxFs, obj.useZoomFFT, obj.useReassignement);
                    lZoomSpectrum.specifyTimeVector(dataBeginTime, obj.fs, obj.signalBeginTime, obj.signalEndTime);

                    % note isZoomSpectrumDone should always be done
                    if obj.bIsTwoSided
                        isZoomSpectrumDone = ~lZoomSpectrum.processSegment(complex(dataRe, dataIm)); %#ok<NASGU>
                    else
                        isZoomSpectrumDone = ~lZoomSpectrum.processSegment(dataRe); %#ok<NASGU>
                    end

                    % If reassignment is on then defer converting to dB to after reassignment is done
                    % otherwise convert to dB only if it has been requested
                    isConvertToDBFlag = ~obj.useReassignement && obj.bIsConvertToDB;
                    if obj.bIsTwoSided
                        dstSpectrum = lZoomSpectrum.fetchTwoSidedSpectrum(isConvertToDBFlag);
                    else
                        dstSpectrum = lZoomSpectrum.fetchOneSidedSpectrum(isConvertToDBFlag);
                    end

                    if isinf(obj.tgtRBW)
                        obj.tgtRBW = lZoomSpectrum.getTargetResolutionBandwidth();
                    end

                    if obj.bComputeZLimits && ~obj.useReassignement && ...
                        ~((tStart < obj.t1 * obj.timeFactor && tEnd < obj.t1 * obj.timeFactor) ...
                        || (tStart > obj.t2 * obj.timeFactor && tEnd > obj.t2 * obj.timeFactor))
                        % window lies within the visible spectrogram region 
                        % we need negative logic because we can have windows which are not completely in visible region
                        [obj.zMin, obj.zMax] = signal.internal.codegenable.pspectrum.Spectrogram.getFiniteExtrema(dstSpectrum, obj.zMin, obj.zMax);
                    elseif obj.bComputeZLimits && obj.useReassignement && ...
                        ~((tStart < obj.t1 * obj.timeFactor && tEnd < obj.t1 * obj.timeFactor) ...
                        || (tStart > obj.t2 * obj.timeFactor && tEnd > obj.t2 * obj.timeFactor))
                        % Since we compute zMin and zMax after reassignment we need to keep track which window need to be in the zLimits calculation
                        obj.bIncludeInZlimitsCalculation(idx + 1) = obj.bComputeZLimits;
                    end

                    obj.mStftMatrix(idx + 1, :) = dstSpectrum;

                    if (obj.useReassignement)
                        dt = lZoomSpectrum.fetchTimeReassignment();
                        df = lZoomSpectrum.fetchFrequencyReassignment();
                        obj.mStftTimeCorrections(idx + 1, :) = dt;
                        obj.mStftFreqCorrections(idx + 1, :) = df;
                    end
                end

                obj.LastWindowTEnd = dataBeginTime + double(numOfWin - uint32(1)) * (obj.timeResolution * obj.overlap) + obj.timeResolution;

                % we need to track winStartIndex because we get data in chunks
                obj.winStartIndex = obj.winStartIndex + numOfWin;
            end

            if isLastData
                obj.createSpectrogramData(bAddEps);
            end
        end        

        function computeSpectrogram(obj, data, timeVector, isLastData)
            dataRe = real(data);
            dataIm = imag(data);
            
            obj.dataTimeBuffer.setupBufferParams(uint32(obj.timeResolutionSamples), uint32(obj.overlapSamples));
            obj.dataTimeBuffer.addData(dataRe, dataIm, timeVector);

            numberOfWindows = uint32(0); %#ok<NASGU>

            if obj.dataTimeBuffer.haveWindows() && ~isLastData
                [numberOfWindows, outputDataRe, outputDataIm, outputTime] = obj.dataTimeBuffer.getWindowData();
                obj.computeSpectrogramCore(outputDataRe, outputDataIm, outputTime(1), isLastData, numberOfWindows, false);
            elseif isLastData
                [numberOfWindows, outputDataRe, outputDataIm, outputTime] = obj.dataTimeBuffer.flush();
                obj.computeSpectrogramCore(outputDataRe, outputDataIm, outputTime(1), isLastData, numberOfWindows, false);
            end
        end

        function freqVector = fetchFrequencyVector(obj)
            freqVector = zeros(obj.nPoints, 1, 'like', 0);

            dF = (obj.f2 - obj.f1) / (double(obj.nPoints - 1));

            for idx = 1:obj.nPoints
                freqVector(idx) = obj.f1 + double(idx - 1) * dF;
            end
        end

        function timeVector = fetchTimeVector(obj)
            timeVector = obj.timeVector(1:obj.totalWindows);
        end
    end
end


classdef WindowDataBuffer < handle
%MATLAB Code Generation Private Function

%   Copyright 2019 The MathWorks, Inc.
%#codegen

    properties (Access = private)
        dataRe;
        dataIm;
        time;
        windowSampleLength;
        overlapSampleLength;
    end

    methods (Access = public)
        function obj = WindowDataBuffer(~)
        end

        function hasWindows = haveWindows(obj)
            hasWindows = logical(numel(obj.dataRe) > numel(obj.windowSampleLength) && ...
                numel(obj.time) > numel(obj.windowSampleLength));
        end

        function [numOfWindow, windowDataRe, windowDataIm, windowTime] = getWindowData(obj)
            totalDataSampleLength = uint32(numel(obj.dataRe));
            if totalDataSampleLength <= uint32(0)
                % if we don't have data then return;
                windowDataRe = [];
                windowDataIm = [];
                windowTime = [];
                numOfWindow = uint32(0);
                return;
            end

            % if number of Datapoints in data is greater than number of windowSampleLength than we have at least one window
            % so we can fetch data from [0, windowSampleLength)
            numOfWindow = uint32(1);
            windowEndIdx = obj.windowSampleLength;
            nextWindowStartIdx = 0 + obj.windowSampleLength - obj.overlapSampleLength;

            % now loop over to see if we have more windows
            while (windowEndIdx + obj.windowSampleLength - obj.overlapSampleLength <= totalDataSampleLength)
                nextWindowStartIdx = nextWindowStartIdx + obj.windowSampleLength - obj.overlapSampleLength;
                windowEndIdx = windowEndIdx + obj.windowSampleLength - obj.overlapSampleLength;
                numOfWindow = numOfWindow + 1;
            end

            windowDataRe = obj.dataRe(1:(windowEndIdx + 1));
            obj.dataRe(1:nextWindowStartIdx + 1) = [];

            if ~isempty(obj.dataIm)
                windowDataIm = obj.dataIm(1:(windowEndIdx + 1));
                obj.dataIm(1:nextWindowStartIdx + 1) = [];
            end

            windowTime = obj.time(1:(windowEndIdx + 1));
            obj.time(1:nextWindowStartIdx + 1) = [];

        end

        function [numOfWindow, windowDataRe, windowDataIm, windowTime] = flush(obj)
            if isempty(obj.dataRe)
                % if we don't have any remaining data then return
                windowDataRe = [];
                windowDataIm = [];
                windowTime = [];
                numOfWindow = uint32(0);
                return;
            end

            numOfWindow = uint32(0);
            if numel(obj.dataRe) > int32(obj.windowSampleLength - obj.overlapSampleLength)
                numOfWindow = uint32(1);
                windowEndIdx = uint32(obj.windowSampleLength);
                nextWindowStartIdx = uint32(0 + obj.windowSampleLength - obj.overlapSampleLength);
                % now loop over to see if we have more windows
                while uint32(windowEndIdx) < numel(obj.dataRe)
                    nextWindowStartIdx = nextWindowStartIdx + obj.windowSampleLength - obj.overlapSampleLength;
                    windowEndIdx = windowEndIdx + obj.windowSampleLength - obj.overlapSampleLength;
                    numOfWindow = numOfWindow + uint32(1);
                end
            else
                numOfWindow = uint32(1);
            end

            windowDataRe = obj.dataRe;
            if ~isempty(obj.dataIm)
                windowDataIm = obj.dataIm;
            else
                windowDataIm = zeros(size(obj.dataRe), 'like', obj.dataRe);
            end

            windowTime = obj.time;
            obj.dataIm = [];
            obj.dataRe = [];
            obj.time = [];
        end

        function setupBufferParams(obj, windowSamplesIn, overlapSamplesIn)
            assert(windowSamplesIn(1) ~= 0, 'invalid input windowSamplesIn');
            assert(overlapSamplesIn(1) < windowSamplesIn(1), 'invalid input overlapSamplesIn, overlapSamplesIn must be < windowSamplesIn');
            obj.windowSampleLength = uint32(windowSamplesIn(1));
            obj.overlapSampleLength = uint32(overlapSamplesIn(1));
        end

        function addData(obj, dataInRe, dataInIm, timeIn)
            assert(numel(dataInRe) == numel(timeIn), 'invalid real input data size');
            if ~isempty(dataInIm)
                assert(numel(dataInIm) == numel(timeIn), 'invalid imaginary input data size');
                obj.dataIm = dataInIm;
            else
                obj.dataIm = zeros(size(dataInRe), 'like', dataInRe);
            end
            obj.dataRe = dataInRe;
            obj.time = timeIn;
        end
    end

end

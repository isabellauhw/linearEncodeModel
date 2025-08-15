classdef PersistenceSpectrum < handle
%MATLAB Code Generation Private Function

%   Copyright 2019 The MathWorks, Inc.
%#codegen

    properties (Access = private)
        f1;
        f2;
        NFreqBin;
        magMax;
        magMin;
        NMagBin;
        spectrum;
        temp;
    end

    methods (Access = public)
        function obj = PersistenceSpectrum()
            obj.f1 = 0;
            obj.f2 = 0;
            obj.NFreqBin = uint32(0);
            obj.magMax = 0;
            obj.magMin = 0;
            obj.NMagBin = uint32(0);
            obj.spectrum = 0;
            obj.temp = uint32(0);
        end

        function NFreqBin = getNFreqBin(obj)
            NFreqBin = obj.NFreqBin;
        end

        function NMagBin = getNMagBin(obj)
            NMagBin = obj.NMagBin;
        end

        function setup(obj, f1In, f2In, NFreqBin, magMinIn, magMaxIn, NMagBinIn)
            obj.f1 = double(f1In(1));
            obj.f2 = double(f2In(1));
            obj.NFreqBin = uint32(NFreqBin(1));
            obj.magMin = double(magMinIn(1));
            obj.magMax = double(magMaxIn(1));
            obj.NMagBin = uint32(NMagBinIn(1));
            % resize spectrum to required size  and initialize to 0;
            obj.spectrum = zeros(obj.NFreqBin * obj.NMagBin, 1, 'like', 0);
            obj.temp = zeros(obj.NFreqBin * obj.NMagBin, 1, 'like', uint32(0));
        end

        function retval = computeSpectrum(obj, x)
            binWidth = (obj.magMax - obj.magMin) / double(obj.NMagBin);
            numOfWin = uint32( numel(x) / double(obj.NFreqBin));

            for idx = 1:obj.NFreqBin
                index = coder.internal.indexInt((idx - 1) * obj.NMagBin);
                for jdx = 1:numOfWin
                    srcIndex = coder.internal.indexInt((idx - 1) + (jdx - 1) * obj.NFreqBin);
                    kdx = coder.internal.indexInt(0); %#ok<NASGU>
                    for kdx = 1:obj.NMagBin
                        minBinValue = double(obj.magMin + double(kdx - 1) * binWidth);
                        maxBinValue = double(obj.magMin + double(kdx) * binWidth);

                        if x(srcIndex + 1) >= minBinValue && ...
                            x(srcIndex + 1) <= maxBinValue
                            obj.temp(uint32(index) + kdx) = obj.temp(uint32(index) + kdx) + uint32(1);
                            break;
                        end
                    end
                end
            end

            for idx = 1:numel(obj.temp)
                obj.spectrum(idx) = double(obj.temp(idx));
                obj.temp(idx) = uint32(0);
            end

            retval = true;
        end

        function Xout = fetchPersistenceSpectrum(obj)
            Xout = obj.spectrum;
        end

        function spectrum2D = fetchPersistenceSpectrum2D(obj)
            spectrum2D = reshape(obj.spectrum, obj.getNMagBin(), obj.getNFreqBin());
        end

        function Fout = fetchFrequencyVector(obj)
            Fout = zeros(obj.NFreqBin, 1, 'like', 0);
            % compute frequency spacing between points

            dF = double((obj.f2 - obj.f1) / double(obj.NFreqBin - 1) );

            for idx = 1:obj.NFreqBin
                Fout(idx) = obj.f1 + double(idx - 1) * dF;
            end
        end

        function Mout = fetchMagnitudeVector(obj)
            Mout = zeros(obj.NMagBin, 1, 'like', 0);

            % compute magnitude spacing between points
            dM = double((obj.magMax - obj.magMin) / double(obj.NMagBin));
            magStart = double( obj.magMin + dM/2);

            for idx = 1:obj.NMagBin
                Mout(idx) = magStart + double(idx - 1) * dM;
            end
        end
    end
end
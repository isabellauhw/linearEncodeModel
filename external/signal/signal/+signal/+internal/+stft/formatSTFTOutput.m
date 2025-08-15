function [Sout,Fout] = formatSTFTOutput(S,F,opts)
%formatSTFTOutput formats the layouts of STFT transform S and frequency
%   vector F according to the value of opt.FreqRange. This function is for
%   internal use only. It may be removed in the future.
%
%   Copyright 2020 The MathWorks, Inc.
%#codegen

switch opts.FreqRange
    case 'centered'
        Sout = signal.internal.spectral.centerest(S);
        Fout = signal.internal.spectral.centerfreq(F);
    case 'twosided'
        Sout = S;
        Fout = F;
    otherwise
        if size(S,1) ~= opts.NumFreqSamples
            Sout = S(1:opts.NumFreqSamples,:,:);            
        else
            Sout = S;
        end
        if size(F,1) ~= opts.NumFreqSamples
            Fout = F(1:opts.NumFreqSamples);
        else
            Fout = F;
        end
end
end


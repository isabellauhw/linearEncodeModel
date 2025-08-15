function sout = formatISTFTInput(s,opts)
%formatISTFTInput formats the layout of input STFT s according to the
%   value of opt.FreqRange. This function is for internal use only. It may
%   be removed in the future.
%
%   Copyright 2020 The MathWorks, Inc.
%#codegen

n = opts.FFTLength;

switch opts.FreqRange
    case 'centered'
        if signalwavelet.internal.iseven(n)
            % even (nyquist is at end of spectrum)
            sout = circshift(s,-(n/2-1));
        else
            % odd
            sout = ifftshift(s,1);
        end
    case 'twosided'
        sout = s;
    otherwise
        sout = zeros(n,size(s,2),size(s,3),'like',s);
        sout(1:opts.NumFreqSamples,:,:) = s;
        if signalwavelet.internal.iseven(n)
            sout(end:-1:opts.NumFreqSamples+1,:,:) = conj(s(2:opts.NumFreqSamples-1,:,:));
        else
            sout(end:-1:opts.NumFreqSamples+1,:,:) = conj(s(2:opts.NumFreqSamples,:,:));
        end
end
end



%==========================================================================
%                            computeMap
%==========================================================================
function [Sx,Fx,Tx,Px] = computeMap(opts)
    x = opts.DataVector;
    fs = opts.Fs;

    if strcmpi(opts.Method,'stft')
        % Compute the time-frequency representation of the signal
        [Sx,Fx,Tx] = pspectrum(x,fs,'spectrogram',...
            'FrequencyResolution',opts.FrequencyResolution);
        % Power map
        % Note that when the method is stft, the output of pspectrum with type
        % 'spectrogram' is absolute square of the short-time Fourier transform.
        Px = 10*log10(Sx+eps);
    else
        % Compute the time-frequency representation of the signal
        [Sx,Fx,Tx] = fsst(x,fs,opts.Window);
        % Power map
        Px = 10*log10(abs(Sx).^2+eps);
        % The Tx returned by fsst is a row vector so convert it to a column
        % vector
        Tx = Tx(:);
    end

end

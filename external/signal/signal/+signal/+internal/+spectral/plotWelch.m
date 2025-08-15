function plotWelch(Pxx, w, Pxxc, esttype, noverlap, L, winName, winParam, units, options)
%PLOTWELCH Generate plots for welch based functions: pwelch, cpsd, mscohere, and tfestimate.
% This function is for internal use only. It may be removed.

%   Copyright 2020 The MathWorks, Inc.

% Gather remote inputs if any.
[Pxx,w,Pxxc] = gather(Pxx,w,Pxxc);

% Add sample rate to the frequency vector.
w = {w};
if strcmpi(units,'Hz')
    w = [w,{'Fs',options.Fs}];
end

% Create a spectrum object to store in the Data object's metadata.
percOverlap = (noverlap/L)*100;
hspec = spectrum.welch({winName,winParam},L,percOverlap); %#ok<DWELCH>

switch lower(esttype)
    case {'tfe','tfeh2'}
        if strcmpi(options.range,'onesided')
            range='half';
        else
            range='whole';
        end
        h = dspdata.freqz(Pxx,w{:},'SpectrumRange',range);
    case 'mscohere'
        if strcmpi(options.range,'onesided')
            range='half';
        else
            range='whole';
        end
        h = dspdata.magnitude(real(Pxx),w{:},'SpectrumRange',range);
    case 'cpsd'
        h = dspdata.cpsd(Pxx,w{:},'SpectrumType',options.range);
    case {'ms','power'}
        h = dspdata.msspectrum(Pxx,w{:},'SpectrumType',options.range); %#ok<DMSSPEC>
    otherwise
        h = dspdata.psd(Pxx,w{:},'SpectrumType',options.range); %#ok<DPPSD>
end
h.Metadata.setsourcespectrum(hspec);

% plot the confidence levels if conflevel is specified.
if ~isempty(Pxxc)
    h.ConfLevel = options.conflevel;
    h.ConfInterval = Pxxc;
end
% center dc component if specified
if options.centerdc
    centerdc(h);
end
plot(h);
if strcmp(esttype,'power')
    title(getString(message('signal:welch:WelchPowerSpectrumEstimate')));
end
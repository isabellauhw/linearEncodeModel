function val = convertmagunits(val, source, target, band)
%CONVERTMAGUNITS   Convert magnitude values to different units
%   CONVERTMAGUNITS(VAL, SRC, TRG, BAND) Convert VAL from SRC units to TRG
%   units in the filter band BAND.  SRC and TRG can be 'linear', 'squared'
%   or 'db'.  BAND can be 'pass' or 'stop'.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.

narginchk(4,4);

known = false;

switch source
    case 'linear'
        switch target
            case 'linear'
                switch band
                    case 'pass'
                         % NO OP, same target as source.
                    case 'stop'
                    case 'amplitude', val = abs(val);
                    otherwise,   error(message('signal:convertmagunits:unknownBand', band, '''pass''', '''stop'''));  
                end
            case 'db'
                switch band
                    case 'pass', val = 20*log10((1+val)/(1-val));
                    case 'stop', val = -20*log10(val);
                    case 'amplitude', val = 20*log10(abs(val));
                    otherwise,   error(message('signal:convertmagunits:unknownBand', band, '''pass''', '''stop'''));
                end
            case 'squared'
                switch band
                    case 'pass', val = ((1-val)/(1+val))^2;
                    case 'stop', val = val^2;
                    case 'amplitude', val = val.^2;
                    otherwise,   error(message('signal:convertmagunits:unknownBand', band, '''pass''', '''stop'''));
                end
            case 'zerophase'  
                switch band
                    case 'amplitude'
                        % No Op.
                    otherwise
                        error(message('signal:convertmagunits:unknownTarget', target, '''linear''', '''squared''', '''db'''));
                end
            otherwise
                error(message('signal:convertmagunits:unknownTarget', target, '''linear''', '''squared''', '''db'''));
        end
    case 'squared'
        switch target
            case 'squared'
                % NO OP, same target as source
            case 'db'
                switch band
                    case {'pass', 'stop'}, val = 10*log10(1/val);
                    otherwise,             error(message('signal:convertmagunits:unknownBand', band, '''pass''', '''stop'''));
                end
            case 'linear'
                switch band
                    case 'pass', val = (1-sqrt(val))/(1+sqrt(val));
                    case 'stop', val = sqrt(val);
                    otherwise,   error(message('signal:convertmagunits:unknownBand', band, '''pass''', '''stop'''));
                end
            otherwise
                error(message('signal:convertmagunits:unknownTarget', target, '''linear''', '''squared''', '''db'''));
        end
    case 'db'
        switch target
            case 'db'
                % NO OP, same target as source
            case 'squared'
                switch band
                    case {'pass', 'stop'}, val = 1/(10^(val/10));
                    otherwise,             error(message('signal:convertmagunits:unknownBand', band, '''pass''', '''stop'''));
                end
            case 'linear'
                switch band
                    case 'pass', val = (10^(val/20) - 1)/(10^(val/20) + 1);
                    case 'stop', val = 10^(-val/20);
                    case 'amplitude', val = 10.^(val/20);
                    otherwise,   error(message('signal:convertmagunits:unknownBand', band, '''pass''', '''stop'''));
                end
            otherwise
                error(message('signal:convertmagunits:unknownTarget', target, '''linear''', '''squared''', '''db'''));
        end
    otherwise
        error(message('signal:convertmagunits:unknownSource', source));
end

% [EOF]

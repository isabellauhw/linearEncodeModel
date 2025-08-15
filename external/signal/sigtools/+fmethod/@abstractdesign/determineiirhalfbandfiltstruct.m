function [filtstruct,mfiltstruct] = determineiirhalfbandfiltstruct(this,desmode,filtstruct)
%DETERMINEIIRHALFBANDFILTSTRUCT Determine appropriate structure for
%   singlerate and multirate iirhalfband designs  

%   Copyright 1999-2017 The MathWorks, Inc.

mfiltstruct = [];
switch lower(desmode)
    case 'singlerate'
        switch lower(filtstruct)
            case {'iirdecim','iirinterp'}
                mfiltstruct = filtstruct;
                filtstruct = 'cascadeallpass';
            case {'iirwdfdecim','iirwdfinterp'}
                mfiltstruct = filtstruct;
                filtstruct = 'cascadewdfallpass';
            otherwise
                % Do nothing
        end
    case 'decimator'
        switch  lower(filtstruct)
            case 'cascadeallpass'
                mfiltstruct = 'iirdecim';
            case 'cascadewdfallpass'
                mfiltstruct = 'iirwdfdecim';
            case 'iirdecim'
                mfiltstruct = filtstruct;
                filtstruct = 'cascadeallpass';
            case 'iirwdfdecim'
                mfiltstruct = filtstruct;
                filtstruct = 'cascadewdfallpass';
            otherwise
                error(message('signal:fmethod:abstractdesign:determineiirhalfbandfiltstruct:invalidStructure'));
        end
    case 'interpolator'
        switch  lower(filtstruct)
            case 'cascadeallpass'
                mfiltstruct = 'iirinterp';
            case 'cascadewdfallpass'
                mfiltstruct = 'iirwdfinterp';
            case 'iirinterp'
                mfiltstruct = filtstruct;
                filtstruct = 'cascadeallpass';
            case 'iirwdfinterp'
                mfiltstruct = filtstruct;
                filtstruct = 'cascadewdfallpass';
            otherwise
                error(message('signal:fmethod:abstractdesign:determineiirhalfbandfiltstruct:invalidStructure'));
        end
end


% [EOF]

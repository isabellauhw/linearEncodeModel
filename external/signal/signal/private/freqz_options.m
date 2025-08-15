function [options,msg,msgobj] = freqz_options(varargin)
% [options,msg,nfft,Fs,w,range,fvflag] = freqz_options(varargin)
%FREQZ_OPTIONS   Parse the optional arguments to FREQZ.
%   FREQZ_OPTIONS returns a structure with the following fields:
%   options.nfft         - number of freq. points to be used in the computation
%   options.fvflag       - Flag indicating whether nfft was specified or a vector was given
%   options.w            - frequency vector (empty if nfft is specified)
%   options.Fs           - Sampling frequency (empty if no Fs specified)
%   options.range        - 'half' = [0, Nyquist); 'whole' = [0, 2*Nyquist)

% Copyright 2009-2017 The MathWorks, Inc.

% Set up defaults

if ~coder.target('MATLAB')
    % Initialize nfft with correct size for codegen
    sizeNFFT = [1 1];
    for i=1:length(varargin)
        if ~ischar(varargin{i})
            sizeNFFT = size(varargin{i});
            break;
        end
    end
    if sizeNFFT(1) > 1 || sizeNFFT(2) > 1
        options.nfft = coder.nullcopy(zeros(sizeNFFT));
    else
        options.nfft = 512;
    end
else
     options.nfft   = 512;
end

options.Fs     = [];
options.w      = [];
options.range  = 'onesided';
options.fvflag = 0;
isreal_x       = []; % Not applicable to freqz

[options,msg,msgobj] = psdoptions(isreal_x,options,varargin{:});

if any(size(options.nfft)>1)
   % frequency vector given, may be linear or angular frequency
   options.w = options.nfft;
   options.fvflag = 1;
end


function varargout = rpmfreqmap(x,fs,rpm,varargin)
%RPMFREQMAP Frequency analysis with frequency-rpm map  
%   MAP = RPMFREQMAP(X,Fs,RPM) performs frequency analysis on input vector
%   X and returns a frequency map matrix, MAP of root-mean-square (RMS)
%   amplitudes. RPMFREQMAP analyzes the spectral content of X using
%   short-time Fourier transforms (STFT). Rows of MAP correspond to the
%   different frequencies, and columns correspond to the different RPM
%   values at which MAP was computed. Fs is the sample rate of X in Hertz.
%   X is measured at a set of rotational speeds in revolutions per minute
%   specified in vector RPM.
%
%   MAP = RPMFREQMAP(X,Fs,RPM,RES) specifies the resolution bandwidth RES
%   in units of Hertz. RES must be positive. If RES is not specified, the
%   default resolution is set to the sampling rate divided by 128. If the
%   length of the input signal is not large enough to achieve this
%   resolution, RPMFREQMAP computes a single frequency estimate using the
%   entire input signal length.
%
%   MAP = RPMFREQMAP(...,'Amplitude',AMP) returns a frequency map, MAP,
%   with values corresponding to root-mean-squared (rms) amplitudes when
%   AMP is set to 'rms', peak amplitudes when AMP is set to 'peak', and
%   power levels when AMP is set to 'power'. If 'Amplitude' is not
%   specified, the default is 'rms'.
%
%   MAP = RPMFREQMAP(...,'Scale',SCALE) expresses MAP in linear units if
%   SCALE is set to 'linear' and in decibels if SCALE is set to 'dB'. If
%   not specified, 'Scale' defaults to 'linear'.
%   
%   MAP = RPMFREQMAP(...,'Window',NAME) specifies the analysis window in
%   NAME. NAME can be one of the following strings: 'flattopwin', 'rectwin',
%   'hann', 'hamming', 'chebwin', or 'kaiser'. The default is 'hann'.
%     * For 'chebwin', you can specify a sidelobe attenuation in decibels
%     using a cell array such as {'chebwin',60}. The attenuation must be
%     greater than 45 dB; if not specified, it defaults to 100 dB.
%     * For 'kaiser', you can specify a beta parameter using a cell array
%     such as {'kaiser',2}. The beta parameter must be a positive scalar;
%     if not specified, it defaults to 0.5.
%
%   MAP = RPMFREQMAP(...,'OverlapPercent',OP) specifies the signal
%   segment overlap percentage, OP, as a scalar between 0 and 100. A
%   larger value of OP produces a smoother map but increases the
%   computation time. If OP is 0, adjacent signal segments do not
%   overlap. If OP is 100, adjacent signal segments are shifted by one
%   sample. If OP is not specified, it defaults to 50.
%
%   [MAP,FREQ,RPM,TIME,RES] = RPMFREQMAP(...) returns a vector of
%   frequencies, FREQ, a vector of rpm values, RPM, a vector of time
%   values, TIME, and the resolution bandwidth, RES, at which MAP was
%   computed. RES is in units of Hertz. The output rpm and time values
%   correspond to the values at the centers of the windows used to compute
%   each short-time Fourier transform.
%   
%   RPMFREQMAP(...) with no output arguments plots the frequency map as a
%   function of rpm and time on an interactive figure.
%   
%   % EXAMPLE 1:
%   %   Load a vibration data set
%   load('helidata.mat');
% 
%   % Remove the DC bias from the vibration signal
%   vib = vib - mean(vib);
% 
%   % Compute and visualize an rpm-frequency map
%   rpmfreqmap(vib,fs,rpm);
% 
%   % EXAMPLE 2: 
%   %   Load a vibration data set
%   load('helidata.mat');
% 
%   % Remove the DC bias from the vibration signal
%   vib = vib - mean(vib);
% 
%   % Compute the rpm-frequency map
%   [map,freq,rpmOut,time] = rpmfreqmap(vib,fs,rpm);
% 
%   % Visualize the map
%   figure;
%   imagesc(time,freq,map);
%   set(gca,'ydir','normal');
%   xlabel('Time (s)');
%   ylabel('Frequency (Hz)');
%   title('Frequency Map');
% 
%   % EXAMPLE 3:
%   %   Visualize frequency map of a chirp with 4 orders
%   Fs = 600; % signal sample rate
%   t = (0:1/Fs:5)';     
%   f0 = 10; % order 1 instantaneous frequency at 0 seconds
%   f1 = 40; % order 1 instantaneous frequency at 5 seconds
% 
%   % RPM profile
%   rpm = 60*linspace(f0,f1,length(t))';
% 
%   % Generate a signal containing 4 chirps that are harmonically related
%   phase = 2*pi*cumsum(rpm/60/Fs);
%   x = sum(sin([phase, 0.5*phase, 4*phase, 6*phase]),2); 
% 
%   % Visualize the frequency map
%   rpmfreqmap(x,Fs,rpm);
%   
%   See also RPMORDERMAP, SPECTROGRAM, TACHORPM, ORDERSPECTRUM

% Copyright 2015-2019 The MathWorks, Inc.
%#codegen

narginchk(3,12);
nargoutchk(0,5);
[varargout{1:nargout}] = rpmmap(x,fs,rpm,'frequency',varargin{:});

% LocalWords:  Fs RMS STFT rms sidelobe helidata vib fs ydir RPMORDERMAP
% LocalWords:  TACHORPM ORDERSPECTRUM

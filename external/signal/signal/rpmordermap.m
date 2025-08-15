function varargout = rpmordermap(x,fs,rpm,varargin)
%RPMORDERMAP Order analysis with order-rpm map  
%   MAP = RPMORDERMAP(X,Fs,RPM) performs order analysis on input vector X
%   and returns an order map matrix, MAP of root-mean-square (RMS)
%   amplitudes. RPMORDERMAP resamples X to a constant samples per cycle rate
%   and analyzes the spectral content of this resampled signal using
%   short-time Fourier transforms (STFT). Rows of MAP correspond to the
%   different orders, and columns correspond to the different RPM values at
%   which MAP was computed. Fs is the sample rate of X in Hertz. X is
%   measured at a set of rotational speeds in revolutions per minute
%   specified in vector RPM.
%
%   MAP = RPMORDERMAP(X,Fs,RPM,RES) specifies the resolution bandwidth RES
%   in orders. RES must be positive. If RES is not specified, the default
%   order resolution is set to the sampling rate of the resampled input
%   signal (i.e. a constant samples per cycle rate signal) divided by 256.
%   If the length of the resampled input signal is not large enough to
%   achieve this resolution, RPMORDERMAP computes a single order
%   estimate using the entire resampled input signal length.
%
%   MAP = RPMORDERMAP(...,'Amplitude',AMP) returns an order map, MAP, with
%   values corresponding to root-mean-squared (rms) amplitudes when AMP is
%   set to 'rms', peak amplitudes when AMP is set to 'peak', and power
%   levels when AMP is set to 'power'. If 'Amplitude' is not specified, the
%   default is 'rms'.
%
%   MAP = RPMORDERMAP(...,'Scale',SCALE) expresses MAP in linear units if
%   SCALE is set to 'linear' and in decibels if SCALE is set to 'dB'. If
%   not specified, 'Scale' defaults to 'linear'.
%
%   MAP = RPMORDERMAP(...,'Window',NAME) specifies the analysis window in
%   NAME. NAME can be one of the following strings: 'flattopwin', 'rectwin',
%   'hann', 'hamming', 'chebwin', or 'kaiser'. The default is 'flattopwin'.
%     * For 'chebwin', you can specify a sidelobe attenuation in decibels
%     using a cell array such as {'chebwin',60}. The attenuation must be
%     greater than 45 dB; if not specified, it defaults to 100 dB. 
%     * For 'kaiser', you can specify a beta parameter using a cell array
%     such as {'kaiser',2}. The beta parameter must be a positive scalar;
%     if not specified, it defaults to 0.5.
%
%   MAP = RPMORDERMAP(...,'OverlapPercent',OP) specifies the resampled
%   signal segment overlap percentage, OP, as a scalar between 0 and 100. A
%   larger value of OP produces a smoother map but increases the
%   computation time. If OP is 0, adjacent signal segments do not overlap.
%   If OP is 100, adjacent signal segments are shifted by one sample. If OP
%   is not specified, it defaults to 50.
%
%   [MAP,ORDER,RPM,TIME,RES] = RPMORDERMAP(...) returns a vector of orders,
%   ORDER, a vector of rpm values, RPM, a vector of time values, TIME, and
%   the order resolution, RES, at which MAP was computed. RES is in units
%   of orders. The output rpm and time values correspond to the values at
%   the centers of the windows used to compute each short-time Fourier
%   transform.
%   
%   RPMORDERMAP(...) with no output arguments plots the order map as a
%   function of rpm and time on an interactive figure.
%
%   % EXAMPLE 1:
%   %   Load a vibration data set
%   load('helidata.mat');
% 
%   % Remove the DC bias from the vibration signal
%   vib = detrend(vib);
% 
%   % Compute and visualize an rpm-order map
%   rpmordermap(vib,fs,rpm,0.005);
% 
%   % EXAMPLE 2: 
%   %   Load a vibration data set
%   load('helidata.mat');
% 
%   % Remove the DC bias from the vibration signal
%   vib = detrend(vib);
% 
%   % Compute the rpm-order map
%   [map,order,rpmOut,time] = rpmordermap(vib,fs,rpm,0.005);
% 
%   % Visualize the map
%   figure;
%   imagesc(time,order,map);
%   set(gca,'ydir','normal');
%   xlabel('Time (s)');
%   ylabel('Order');
%   title('Order Map');
% 
%   % EXAMPLE 3:
%   %   Visualize order map of a chirp with 4 orders
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
%   % Visualize the order map
%   rpmordermap(x,Fs,rpm);
%   
%   See also RPMFREQMAP, SPECTROGRAM, TACHORPM, ORDERTRACK, ORDERWAVEFORM

% Copyright 2015-2019 The MathWorks, Inc.
%#codegen

narginchk(3,12);
nargoutchk(0,5);
[varargout{1:nargout}] = rpmmap(x,fs,rpm,'order',varargin{:});

% LocalWords:  Fs RMS resamples resampled STFT rms sidelobe helidata vib fs
% LocalWords:  ydir RPMFREQMAP TACHORPM ORDERTRACK ORDERWAVEFORM

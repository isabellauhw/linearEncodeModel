function varargout = modalfrf(varargin)
%MODALFRF Frequency-response functions for modal analysis
%   FRF = MODALFRF(X,Y,Fs,WINDOW) estimates the matrix of
%   frequency-response functions, FRF, from excitation X and response Y.
%   The sample rate, Fs, is in Hz. FRF is an H1 estimate computed from
%   the cross-power spectral densities of X and Y using Welch's averaged,
%   modified periodogram method.
%
%   When WINDOW is a vector, MODALFRF divides each column of X and Y into
%   overlapping segments of length equal to the length of WINDOW and then
%   windows each segment with the specified vector. If WINDOW is an
%   integer, then each column of X and Y is divided into segments of length
%   WINDOW, and each segment is windowed with a rectangular window of that
%   length.
%
%   X and Y can be vectors or matrices and must have the same number of
%   rows. If X or Y is a matrix, each column contains a signal. By default,
%   FRF is a P-by-M-by-N matrix, where P is the number of frequency bins, M
%   is the number of response channels, and N is the number of excitation
%   channels.
%
%   The frequency-response function matrix, FRF, is computed in terms of
%   dynamic flexibility, and the system output signal, Y, is taken to be
%   proportional to acceleration.
%
%   FRF = MODALFRF(X,Y,Fs,WINDOW,NOVERLAP) uses NOVERLAP samples of overlap
%   from segment to segment. NOVERLAP must be smaller than the length of
%   WINDOW if WINDOW is a vector, or smaller than WINDOW if WINDOW is an
%   integer. If NOVERLAP is omitted or specified as empty, it defaults to
%   0.
% 
%   FRF = MODALFRF(X,Y,...,'Measurement',MT) specifies the measurement
%   configuration as one of 'fixed', 'rovinginput', or 'rovingoutput': 
%     'fixed' - there are multiple fixed excitation and response locations.
%     'rovinginput' - there are multiple excitation locations and a fixed
%         response location.
%     'rovingoutput' - there are multiple response locations and a fixed
%         excitation location.
%   For the last two options, the number of excitation and response
%   channels must be equal. If MT is not specified, it defaults to 'fixed'.
%
%   FRF = MODALFRF(X,Y,...,'Sensor',SE) specifies the type of sensor as one
%   of 'dis','vel', or 'acc':
%     'dis' - output signal is proportional to displacement.
%     'vel' - output signal is proportional to velocity.
%     'acc' - output signal is proportional to acceleration.
%   If SE is not specified, it defaults to 'acc'.
%
%   FRF = MODALFRF(X,Y,...,'Estimator',ES) computes FRF using an estimator
%   specified by ES. ES can be 'H1', 'H2', 'Hv', or 'subspace'. If ES is
%   not specified, it defaults to 'H1'.
%   * If ES is 'H2', then the number of excitation and response channels
%     must be the same. 
%   * If ES is 'Hv', and MT is neither 'rovinginput' nor 'rovingoutput',
%     then there must be one excitation channel and one response channel. 
%   * If ES is 'subspace', then NOVERLAP is ignored.
%
%   FRF = MODALFRF(X,Y,...,'Order', NX) specifies the order of the
%   state-space model used for  computing the FRF. Specify NX as a positive
%   integer or a row vector of integers (for example 1:10). When NX is a
%   row vector, the function picks an optimal order from the specified
%   range. If NX is not specified, it defaults to 1:10. This name-value
%   pair applies only if 'Estimator' is specified as 'subspace'.
%
%   FRF = MODALFRF(X,Y,...,'Feedthrough', FT) specifies the presence (FT =
%   true) or absence (FT = false) of feedthrough in the state-space model.
%   If FT is not specified, it defaults to false. This name-value pair
%   applies only if 'Estimator' is specified as 'subspace'.
%
%   [FRF,F] = MODALFRF(X,Y,Fs,...) returns the frequency vector, F,
%   corresponding to each frequency-response function. 
%
%   [FRF,F,COH] = MODALFRF(X,Y,Fs,...) returns the (multiple) coherence
%   matrix COH. COH has one column for each response signal.
%
%   MODALFRF(X,Y,Fs,...) with no output arguments plots frequency-response
%   functions for the first four excitation and response channels in the
%   current figure.
%
%   Identified Model-based syntaxes (require System Identification Toolbox)
%   
%     [FRF,F] = MODALFRF(SYS) computes the frequency response of an
%     identified model SYS. SYS can be created using estimation commands
%     such as SSEST, N4SID and TFEST on the signals X and Y.
%  
%     [FRF, F] = MODALFRF(SYS, F) specifies the frequency vector in Hz for
%     the computation of the FRF.
%
%     [FRF, F] = MODALFRF(SYS,..., 'Sensor', SE) specifies if the output
%     channel of model SYS represents acceleration (SE = 'acc'), velocity
%     (SE = 'vel') or displacement (SE = 'dis') response. If SE is not
%     specified, it defaults to 'acc'.
%
%   % Example 1
%   %   Visualize the frequency-response function of a 
%   %   single-input/single-output hammer excitation.
%   load modaldata
%
%   % Plot the input excitation and output acceleration signals.
%   figure
%   subplot(2,1,1)
%   plot(thammer,Xhammer(:))
%   xlabel('Time (s)')
%   ylabel('Force (N)')
%   subplot(2,1,2)
%   plot(thammer,Yhammer(:))
%   xlabel('Time (s)')
%   ylabel('Acceleration (m/s^2)')
%
%   % Compute and display the frequency-response function.
%   figure
%   winlen = size(Xhammer,1);
%   modalfrf(Xhammer(:),Yhammer(:),fs,winlen,'Sensor','dis')
%   xlim([0 .6])
%
%   % Example 2 
%   %   Compute frequency-response functions and generate a stabilization 
%   %   diagram for a three-input/one-output roving hammer excitation.
%   load modaldata
%   winLen = 10110;
%   [FRF,f] = modalfrf(XhammerMISO1,YhammerMISO1,fs,winLen,...
%       'Measurement','rovinginput','Sensor','dis');
% 
%   % Visualize the stabilization diagram to identify physical modes.
%   figure
%   modalsd(FRF,f,fs,'MaxModes',10,'SCriteria',[0.005 0.01])
%   
%   % Example 3
%   %   Use the subspace method to compute the frequency-response function
%   %   for a two-input/six-output steel frame. 
%   load modaldata SteelFrame
%   X = SteelFrame.Input; 
%   Y = SteelFrame.Output; 
%   fs = SteelFrame.Fs;
%   [FRF,f] = modalfrf(X,Y,fs,1000,'Estimator','subspace','Order',36);
%
%   % Visualize the stabilization diagram
%   modalsd(FRF,f,fs,'MaxModes',15)
%
%   See also MODALFIT, MODALSD, TFESTIMATE, TFEST, N4SID, SSEST.

%   Copyright 2016-2018 The MathWorks, Inc.

% Quick return for identified model based syntax
if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if isa(varargin{1},'idParametric')
   [varargout{1:nargout}] = modalfrf_(varargin{:});
   return
end

narginchk(4,15);
nargoutchk(0,3);
[x,y,fs,window] = deal(varargin{1:4});
varargin = varargin(5:end);

% Parse and validate inputs
[opts,window] = parseOptions(window,varargin{:});
opts = validateInputs(x,y,fs,window,opts);

% Cast to enforce precision rules.
fs = double(fs);

% Compute sizes of function inputs
winlen = length(window);

% Compute frequency response functions
[FRF,f] = signal.internal.modal.computeFRF(x,y,window,winlen,fs,opts);

% Convert to dynamic flexibility
FRF = signal.internal.modal.toDynamicFlex(FRF,f,opts.se);

% Compute (multiple) coherence
if nargout > 2 || nargout == 0
   % If the number of segments is less than the number of input channels,
    % coherence is not defined. Warn and return NaN.
    k = fix((size(x,1)-opts.noverlap)./(winlen-opts.noverlap)); % Segments
    if k > size(x,2)
      if strcmpi(opts.mt,'fixed')
        coh = mscohere(x,y,window,opts.noverlap,winlen,fs,'mimo');
      else
        coh = mscohere(x,y,window,opts.noverlap,winlen,fs);
      end
    else
      warning(message('signal:modalfrf:UndefinedCoh')); 
      coh = nan(size(FRF,1),size(FRF,2));
    end
end

if nargout == 0
  signal.internal.modal.plotFRF(FRF,f,true(size(f)),'Coherence',coh,'Opts',opts)
end

if nargout > 0
  varargout{1} = FRF;
end
if nargout > 1
  varargout{2} = f;
end
if nargout > 2
  varargout{3} = coh;
end
%--------------------------------------------------------------------------
function [opts,window] = parseOptions(window,varargin)

% Parse Name-value pairs
p = inputParser;
p.addOptional('noverlap',0);
p.addParameter('Sensor','A');
p.addParameter('Estimator','H1');
p.addParameter('Measurement','fixed');
p.addParameter('Order',1:10);
p.addParameter('Feedthrough',false);

parse(p,varargin{:});
opts.noverlap = p.Results.noverlap;
opts.se = p.Results.Sensor;
opts.est = p.Results.Estimator;
opts.mt = p.Results.Measurement;
opts.nx = p.Results.Order;
opts.ft = p.Results.Feedthrough;

% Validate string arguments
opts.se = validatestring(opts.se,{'dis','vel','acc'});
opts.est = validatestring(opts.est,{'h1','h2','hv','subspace'});
opts.mt = validatestring(opts.mt,{'rovinginput','rovingoutput','fixed'});

if isscalar(window)
  window = rectwin(window);
end
%--------------------------------------------------------------------------
function opts = validateInputs(x,y,fs,window,opts)

validateattributes(x,{'single','double'},...
   {'real','nonsparse','finite','nonnan','2d'},'modalfrf','X');
validateattributes(y,{'single','double'},...
   {'real','nonsparse','finite','nonnan','2d'},'modalfrf','Y');
validateattributes(fs,{'single','double'},...
   {'real','positive','nonsparse','finite','nonnan','scalar'},'modalfrf','Fs');
validateattributes(window,{'single','double'},...
   {'real','nonsparse','finite','nonnan','vector'},'modalfrf','WINDOW');
if ~strcmp(opts.est,'subspace')
   validateattributes(opts.noverlap,{'single','double'},...
      {'real','nonnegative','nonsparse','finite','nonnan','scalar',...
      '<=',length(window)-1},'modalfrf','NOVERLAP');
end

validateattributes(opts.nx,{'single','double'},...
  {'real','nonnegative','nonsparse','finite','row','nonempty'},'modalfrf','ORDER');
validateattributes(opts.ft, {'numeric','logical'},...
   {'binary','scalar'},'modalfrf','Feedthrough');

% Error out if the number of input and output channels are different and
% the measurement is 'rovinginput' or 'rovingoutput'.
if ~isequal(size(x,2),size(y,2)) && ...
    (isequal(opts.mt,'rovinginput') || isequal(opts.mt,'rovingoutput'))
  error(message('signal:modalfrf:MustBeFixed'));
end

% Error out if hv is chosen and the data is not SISO
isSISO = (size(x,2) == size(y,2) && ~strcmp(opts.mt,'fixed')) || ...
  (size(x,2) == 1 && size(y,2) == 1);
if strcmp(opts.est,'hv') && ~isSISO
  error(message('signal:modalfrf:MustBeSISOHv'));
end

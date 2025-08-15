function varargout = orderspectrum(varargin)
%ORDERSPECTRUM Average spectrum versus order for a vibration signal
%   SPEC = ORDERSPECTRUM(X,Fs,RPM) computes an average order magnitude
%   spectrum vector, SPEC, for the signal vector, X. X has a sample rate of
%   Fs in hertz and is measured at a set of rotational speeds in
%   revolutions per minute specified in the vector RPM. By default, values
%   of SPEC correspond to root-mean-square (RMS) amplitudes given in linear
%   scale. To compute the spectrum, the function windows a constant-phase
%   resampled version of X using a flattop window.
%
%   [SPEC,ORDER] = ORDERSPECTRUM(X,Fs,RPM) returns the vector of orders,
%   ORDER, corresponding to each average spectrum value in SPEC.
%
%   [...] = ORDERSPECTRUM(MAP,ORDER) computes an average order magnitude
%   spectrum, SPEC, based on an order map matrix, MAP, and order vector,
%   ORDER, which may be computed using the RPMORDERMAP function. MAP must
%   have linear scale, and root-mean-squared amplitude is assumed. The
%   length of ORDER must match the number of rows of MAP. SPEC has the same
%   amplitude and scaling as MAP.
%
%   [...] = ORDERSPECTRUM(MAP,ORDER,'Amplitude',AMP) computes an average
%   order magnitude spectrum based on an order map matrix, MAP, with
%   root-mean-squared amplitudes when AMP is set to 'rms', peak
%   amplitudes when AMP is set to 'peak', and power levels when AMP is set
%   to 'power'. If AMP is not specified, the default is 'rms'.
%
%   ORDERSPECTRUM(...) with no output arguments plots the averge order
%   spectrum on the current figure.
%
%   % EXAMPLE:
%   %   Compute and plot an order spectrum for simulated helicopter 
%   %   vibration data.
%   load('helidata.mat')
% 
%   % Remove the DC bias from the vibration signal.
%   vib = detrend(vib);
% 
%   % Compute and visualize the order spectrum with the default resolution.
%   orderspectrum(vib,fs,rpm)
%
%   % Compute an rpm-order map with a resolution of 0.005 orders.
%   [map,order] = rpmordermap(vib,fs,rpm,0.005);
%
%   % Plot the order spectrum with a resolution of 0.005 orders.
%   hold on
%   orderspectrum(map,order)
%   legend('Spectrum from signal','Spectrum from map')
%
%   See also RPMORDERMAP, ORDERTRACK, TACHORPM, ORDERWAVEFORM

%   References:
%     [1] Brandt, Anders. Noise and Vibration Analysis: Signal Analysis 
%         and Experimental Procedures. Chichester, UK: John Wiley & Sons,
%         2011.

% Copyright 2015-2019 The MathWorks, Inc.
%#codegen

narginchk(2,4);
nargoutchk(0,2);

inpArgs = cell(size(varargin));
[inpArgs{:}] = convertStringsToChars(varargin{:});

if nargin == 4 || nargin == 2    % Map input
  map = inpArgs{1};
  orderInput = inpArgs{2};
  validateMapInputs(map,orderInput);
  order = orderInput(:);
  if nargin == 4
      validatestring(inpArgs{3},{'Amplitude'},'orderspectrum','',3);
      amp = validatestring(inpArgs{4},{'power','peak','rms'},...
                          'orderspectrum','AMPLITUDE',4);
  else
      amp = 'rms';
  end
else % Signal input, use rpmordermap to compute map and order
  x   = inpArgs{1};
  fs  = inpArgs{2};
  rpm = inpArgs{3};
  validateSignalInputs(x,fs,rpm);
  amp = 'rms';
  %  compute the map and order vector
  [map,order] = rpmordermap(x,fs(1),rpm);
end

% Compute the order spectrum
spec = coder.nullcopy(zeros(size(map,1),1,'like',map));
switch lower(amp)
  case {'rms','peak'}
    % Square the map, average, then square root. This is equivalent to
    % converting to power, averaging, and converting back for both rms and
    % peak since scaling constants, e.g. sqrt(2), are not affected.
    spec = sqrt(mean(map.^2,2));
  case 'power'
    spec = mean(map,2);
end

if nargout == 0
  coder.internal.assert(coder.target('MATLAB'),'signal:rpmmap:PlottingNotSupported');  
  plot(order,spec);
  grid on;
  xlabel(getString(message('signal:rpmmapplot:onumber')))
  switch lower(amp)
    case 'rms'
      yLabString = getString(message('signal:rpmmapplot:orderrms'));
    case 'power'
      yLabString = getString(message('signal:rpmmapplot:orderpower'));
    case 'peak'
      yLabString = getString(message('signal:rpmmapplot:orderpeak'));
  end
  ylabel(yLabString);
  title(getString(message('signal:rpmmapplot:aorderspectrum')))
  grid on;
elseif nargout == 1
  varargout{1} = spec;
else
  varargout{1} = spec;
  varargout{2} = order;
end
%--------------------------------------------------------------------------
function validateSignalInputs(x,fs,rpm)
validateattributes(x,{'single','double'},...
    {'real','nonsparse','finite','vector'},'orderspectrum','X',1);
validateattributes(fs,{'numeric'},...
    {'real','positive','nonsparse','finite','scalar'},'orderspectrum','Fs',2);
validateattributes(rpm,{'numeric'},...
    {'real','positive','nonsparse','finite','vector'},'orderspectrum','RPM',3);

% Check rpm and x have same length
coder.internal.assert(length(x) == length(rpm),'signal:rpmmap:MustBeSameLength');
%--------------------------------------------------------------------------
function validateMapInputs(map,order)
validateattributes(map,{'single','double'},...
    {'real','nonsparse','finite','nonempty'},'orderspectrum','MAP',1);
validateattributes(order,{'single','double'},...
    {'real','nonnegative','nonsparse','finite','vector'},...
    'orderspectrum','ORDER',2);

% Check map and order have consistent dimensions
coder.internal.assert(size(map,1) == length(order),'signal:rpmmap:OrderMatchMap');

% Check that order has at least two elements.
coder.internal.assert(length(order) >= 2,'signal:rpmmap:OrderLength');


% LocalWords:  Fs RMS resampled RPMORDERMAP rms averge helidata vib fs
% LocalWords:  rpmordermap ORDERTRACK TACHORPM ORDERWAVEFORM Chichester rpmmap
% LocalWords:  rpmmapplot onumber orderrms orderpower orderpeak aorderspectrum
% LocalWords:  nonsparse

function varargout = freqz(b,a,varargin) %#codegen
%MATLAB Code Generation Library Function

% Limitations:
% The third through fifth input arguments must be constant when input is in transfer function form (B,A).
% The second through fourth input arguments must be constant when input is in SOS matrix form.
% If nfft is specified, it must be a power of two.

% Copyright 2009-2018 The MathWorks, Inc.

coder.extrinsic('sigprivate');
coder.extrinsic('freqz_freqvec');

% Parse inputs
eml_lib_assert(nargin>=1,'signal:freqz:notEnoughInputs','Not enough input arguments.');
eml_lib_assert(nargin<=5,'signal:freqz:tooManyInputs',  'Too many input arguments.');

coder.internal.assert(coder.internal.isConst(size(b)), ...
    'Coder:toolbox:InputMustBeFixedSize',1);

if all(size(b)>[1 1])
  % Input is a matrix, check if it is a valid SOS matrix
  eml_lib_assert(size(b,2) == 6 && isfloat(b),'signal:freqz:invalidinputsosmatrix',...
    'When first input is a matrix, it must have exactly 6 columns to be a valid SOS matrix. Otherwise, the first input must be a vector.');
  isTF = false; % SOS instead of transfer function
else
  isTF = true; % True if dealing with a transfer function
end

if isTF   
  % PV-pairs are in varargin
  if nargin == 1
     aDen = 1;
  else
    aDen = a;
  end
  
  eml_lib_assert(isvector(aDen), ...
    'signal:freqz:inputnotsupported',...
    'The numerator and denominator of the transfer function must be stored in vectors.');

  eml_lib_assert(isfloat(aDen) && isfloat(b),...
    'signal:freqz:inputNotFloatingPoint',...
    'Inputs must be floating point.');  

  coder.internal.assert(coder.internal.isConst(size(aDen)), ...
    'Coder:toolbox:InputMustBeFixedSize',2);
else
  % PV-pairs are in [a varargin], do not overwrite a
  aDen = 1;  
end

if isTF
  % Transfer function
  % Coefficients are in b and a inputs. PV-pairs are in varargin
  if nargin>=3
    eml_lib_assert(eml_is_const(varargin{1}),...
      'signal:freqz:input3NotConst',...
      'The third input to FREQZ must be constant.');
  end
  if nargin>=4
    eml_lib_assert(eml_is_const(varargin{2}),...
      'signal:freqz:input4NotConst',...
      'The fourth input to FREQZ must be constant.');
  end
  if nargin>=5
    eml_lib_assert(eml_is_const(varargin{3}),...
      'signal:freqz:input5NotConst',...
      'The fifth input to FREQZ must be constant.');
  end      
else
  % SOS input
  % Coefficients are in b input (SOS matrix). PV-pairs are in [a varargin]
  if nargin>=2
    eml_lib_assert(eml_is_const(a),...
      'signal:freqz:input3NotConst',...
      'The second input to FREQZ must be constant.');
  end
  if nargin>=3
    eml_lib_assert(eml_is_const(varargin{1}),...
      'signal:freqz:input4NotConst',...
      'The third input to FREQZ must be constant.');
  end
  if nargin>=4
    eml_lib_assert(eml_is_const(varargin{2}),...
      'signal:freqz:input5NotConst',...
      'The fourth input to FREQZ must be constant.');
  end        
end

if isTF || nargin == 1
  % PV-pairs are in varargin
  [options,msg] = sigprivate('freqz_options',varargin{:});
else
  % PV-pairs are in [a varargin]
  [options,msg] = sigprivate('freqz_options',a,varargin{:});
end  
options = coder.internal.const(options);
msg = coder.internal.const(msg);

eml_lib_assert(isempty(msg), 'signal:freqz:SigErr', msg)
nfft   = options.nfft;
Fs     = options.Fs;
range  = options.range;
fvflag = options.fvflag;  % True means a frequency vector was input.
if fvflag
  w = options.w;
  npoints = length(w);
else
  % freqvector not specified, use nfft and RANGE in calculation
  switch range
    case 'twosided'
      sided_switch = 1;
      npoints = nfft;
    otherwise % 'onesided'
      % One-sided has twice as many points because they will be trimmed to nfft at the end.
      sided_switch = 2;
      npoints = 2*nfft;
  end
  w = freqz_freqvec(cast(nfft,class(b)), cast(Fs,class(b)), sided_switch).';
  w = coder.internal.const(w);
end

% Compute the frequency response
if isTF
  if length(aDen) == 1
    hh = firfreqz(b/aDen,Fs,w,fvflag,npoints);
  else
    hh = iirfreqz(b,aDen,Fs,w,fvflag,npoints);
  end
else
  hh = sosfreqz(b,Fs,w,fvflag,npoints);
end

% When RANGE = 'half', we computed a 2*nfft point FFT, now we take half the result
if ~fvflag && isa(nfft,'numeric') && isscalar(nfft) && nfft<length(hh)
  h = hh(1:nfft);
else
  h = hh;
end

% Generate the default structure to pass to freqzplot
if nargout==0 || nargout>2
  if ~isempty(Fs)
    xunits = 'Hz';
  else
    xunits = 'rad/sample';
  end
  plot_struct = struct('plot','both',...
    'fvflag', fvflag,...
    'yunits', 'db',...
    'xunits', xunits,...
    'Fs', Fs);
end

if nargout == 0
  % Plot when no output arguments are given
  if isTF || nargin == 1
    % PV-pairs are in varargin
    sigprivate('eml_freqz_plot',plot_struct,b,aDen,h,w,isTF,varargin{:});
  else
    % PV-pairs are in [a varargin]
    sigprivate('eml_freqz_plot',plot_struct,b,aDen,h,w,isTF,a,varargin{:});
  end
else
  % Return outputs
  varargout{1} = h;
  if nargout>1, varargout{2} = w;           end
  if nargout>2, varargout{3} = plot_struct; end
  if nargout>3, varargout{4} = options;     end
end

%--------------------------------------------------------------------------
function [h,w] = firfreqz(b_in,Fs,w,fvflag,npoints)

% Make b a row
if size(b_in,1)>1
  b = reshape(b_in,1,numel(b_in));
else
  b = b_in;
end
n  = length(b);

% Actual Frequency Response Computation
if fvflag
  %   Frequency vector specified.  Use Horner's method of polynomial
  %   evaluation at the frequency points and divide the numerator
  %   by the denominator.
  %
  %   Note: we use positive i here because of the relationship
  %            polyval(a,exp(i*w)) = fft(a).*exp(i*w*(length(a)-1))
  %               ( assuming w = 2*pi*(0:length(a)-1)/length(a) )
  %
  if ~isempty(Fs) % Fs was specified, freq. vector is in Hz
    digw = 2.*pi.*w./Fs; % Convert from Hz to rad/sample for computational purposes
  else
    digw = w;
  end
  
  f = exp(1i*digw); % Digital frequency must be used for this calculation
  h = polyval(b,f)./exp(1i*digw*(n-1));
else
  if npoints < n
    % Data is larger than FFT points, wrap modulo s*nfft
    h = fft(datawrap(b,npoints)).';
  else
    h = fft(b,npoints).';
  end
  
end

%--------------------------------------------------------------------------
function h = iirfreqz(b_in,a_in,Fs,w,fvflag,npoints)
nb = length(b_in);
na = length(a_in);
a  = [a_in(:).' zeros(1,nb-na)];  % Make a and b rows of the same length
b  = [b_in(:).' zeros(1,na-nb)];
n  = length(a); % This will be the new length of both num and den

% Actual Frequency Response Computation
if fvflag
  %   Frequency vector specified.  Use Horner's method of polynomial
  %   evaluation at the frequency points and divide the numerator
  %   by the denominator.
  %
  %   Note: we use positive i here because of the relationship
  %            polyval(a,exp(i*w)) = fft(a).*exp(i*w*(length(a)-1))
  %               ( assuming w = 2*pi*(0:length(a)-1)/length(a) )
  %
  if ~isempty(Fs) % Fs was specified, freq. vector is in Hz
    digw = 2.*pi.*w./Fs; % Convert from Hz to rad/sample for computational purposes
  else
    digw = w;
  end
  
  f = exp(1i*digw); % Digital frequency must be used for this calculation
  h = polyval(b,f) ./ polyval(a,f);
else
  if npoints < n
    % Data is larger than FFT points, wrap modulo npoints
    h = (fft(datawrap(b,npoints))./fft(datawrap(a,npoints))).';
  else
    h = (fft(b,npoints)./fft(a,npoints)).';
  end
  
end

%--------------------------------------------------------------------------
function h = sosfreqz(sos,Fs,w,fvflag,npoints)

h = iirfreqz(sos(1,1:3), sos(1,4:6), Fs, w, fvflag, npoints);
for indx = 2:size(sos, 1)
    h = h.*iirfreqz(sos(indx,1:3), sos(indx,4:6), Fs ,w, fvflag, npoints);    
end


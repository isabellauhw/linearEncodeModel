function varargout = modalfit(varargin)
%MODALFIT Modal parameters from frequency-response functions 
%   FN = MODALFIT(FRF,F,Fs,MNUM) estimates the natural frequencies of MNUM
%   modes of a system with measured frequency-response function FRF at
%   frequencies F. Fs is a positive scalar specifying the sample rate of
%   the measurement data. F is a vector having a number of elements equal
%   to the number of rows of FRF.
%
%   FRF is an P-by-M-by-N array, where P is the number of frequency bins, M
%   is the number of response channels, and N is the number of excitation
%   channels.
%
%   By default, FN is a MNUM-element column vector of natural frequencies
%   computed using the least-squares complex exponential (LSCE) algorithm.
%
%   FN = MODALFIT(FRF,F,Fs,MNUM,...,'FitMethod',FM) uses the fitting
%   algorithm specified by FM to estimate modal parameters. FM can be:
%       'pp': peak-picking algorithm
%     'lsce': least-squares complex exponential (LSCE) algorithm (default)
%     'lsrf': least-squares rational function (LSRF) algorithm 
%
%   The size of FN depends on the choice of fitting algorithm. For an FRF
%   computed from N excitation channels and M response channels, FN is a
%   MNUM-by-M-by-N array (one estimate per FRF) for the peak-picking
%   method. For the LSCE and LSRF methods, FN is an MNUM-element column
%   vector.
%
%   FN = MODALFIT(FRF,F,Fs,MNUM,...,'FitMethod','lsrf','Feedthrough', FT)
%   specifies the presence (FT = true) or absence (FT = false) of
%   feedthrough in the estimated transfer function when fit method is
%   'lsrf'.
%
%   FN = MODALFIT(FRF,F,Fs,MNUM,...'FreqRange',FR) estimates modal
%   parameters over the frequency range specified by the two element vector
%   FR. FR must have non-decreasing values contained within the frequency
%   range in F.
%
%   [FN,DR] = MODALFIT(FRF,F,Fs,MNUM,...) returns a damping ratio for each
%   natural frequency in FN.
%
%   [FN,DR,MS] = MODALFIT(FRF,F,Fs,MNUM,...) returns a matrix of mode-shape
%   vectors, MS. MS has MNUM columns, each containing a mode-shape vector.
%   The length of each mode-shape vector is equal to the larger of the
%   number of response channels or the number of excitation channels.
%
%   [FN,DR,MS] = MODALFIT(FRF,F,Fs,MNUM,...,'PhysFreq',PF) specifies
%   natural frequencies for physical modes to include in the analysis. PF
%   is a vector of frequency values within the range of F. For each
%   frequency value specified in PF, the mode with natural frequency
%   closest to that value is included in the analysis. If PF has length M,
%   then FN and DR have M columns each, and MS has M rows. If PF is not
%   specified, all available modes are returned.
%   
%   [FN,DR,MS] = MODALFIT(FRF,F,Fs,MNUM,...,'DriveIndex',DI) specifies the
%   indices of the driving point frequency-response function. DI is a
%   two-element vector of positive integers less than or equal to the size
%   of FRF along the second and third dimensions, respectively. The driving
%   point frequency-response function is used to normalize mode-shape
%   vectors to unity modal. If DI is not specified, it defaults to [1 1].
%
%   [FN,DR,MS,OFRF] = MODALFIT(FRF,F,Fs,MNUM,...) returns a reconstructed
%   frequency-response function array, OFRF, based on the estimated modal
%   parameters. OFRF has the same size as FRF.
%
%   Identified Model-based syntax (requires System Identification Toolbox)    
%     [FN, DR, MS, OFRF] = MODALFIT(SYS, F, MNUM, ...) estimates
%     the modal parameters for the identified model SYS. SYS can be created
%     using estimation commands such as TFEST or SSEST on the measured
%     frequency-response function FRF. Specify values for 'FreqRange',
%     'PhysFreq', and 'DriveIndex' using name-value pairs. 
%
%   % Example 1 
%   %   Compute natural frequencies and display reconstructed response
%   %   functions for a two-input/two-output system excited by random 
%   %   noise.      
%   load modaldata
%
%   % Compute the frequency-response functions.
%   winlen = 2500;
%   [FRF,f] = modalfrf(Xrand,Yrand,fs,hann(winlen),...
%     winlen/2,'Sensor','Dis');
% 
%   % Examining the FRFs, two prominent peaks are present. Extract 
%   % estimates of natural frequency, one for each response function, 
%   % using the peak picking algorithm. Specify 2 modes, one for each peak.
%   fn = modalfit(FRF,f,fs,2,'FitMethod','PP')
% 
%   % Visualize the reconstructed frequency-response functions based on the 
%   % modal fit.
%   figure
%   modalfit(FRF,f,fs,2,'FitMethod','PP');
%   
%   % Example 2
%   %   Compute natural frequencies, damping ratios, and mode shapes for a
%   %   two-input/three-output system excited by burst random noise. 
%   load modaldata
% 
%   % Compute the frequency-response functions. Specify a rectangular 
%   % window with length equal to the burst period in samples.
%   burstLen = 12000;
%   [FRF,f] = modalfrf(Xburst,Yburst,fs,burstLen);
% 
%   % Display a stabilization diagram to determine the physical modes    
%   % present in the response.  
%   fn = modalsd(FRF,f,fs,'MaxModes',20);
%
%   % Compute modal parameters using the LSCE algorithm. Specify a model 
%   % order of six modes and use the physical frequencies for three modes 
%   % determined from the stabilization diagram. Generate one set of 
%   % natural frequencies and damping ratios for each input channel.
%   [fn,dr,ms] = modalfit(FRF,f,fs,6,'PhysFreq',fn(6,1:3));
%
%   % Example 3
%   %   Compute the modal parameters of a three-input/three-output Space
%   %   Station module starting from its frequency-response functions.
%   load modaldata SpaceStationFRF
%   FRF = SpaceStationFRF.FRF; 
%   f = SpaceStationFRF.f; 
%   fs = SpaceStationFRF.Fs;
% 
%   % Extract modal parameters
%   [fn,dr,ms,ofrf] = modalfit(FRF,f,fs,24,'FitMethod','lsrf');
% 
%   % Compare the reconstructed FRF to the measured one
%   for i = 1:3
%      for j = 1:3
%         subplot(3,3,3*(i-1)+j)
%         loglog(f,abs(FRF(:,j,i)),f,abs(ofrf(:,j,i))); 
%         axis tight
%         title(sprintf('In%d->Out%d',i,j))
%         if i==3, xlabel('Frequency (Hz)'); end
%      end
%   end

%   See also MODALFRF, MODALSD, TFEST, SSEST.

%   Copyright 2016-2018 The MathWorks, Inc.

% Quick return for identified model based syntax
if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if isa(varargin{1},'idParametric')
   [varargout{1:nargout}] = modalfit_(varargin{:});
   return
end

narginchk(4,12);
nargoutchk(0,4);
[FRF,f,fs,mnum] = deal(varargin{1:4});
varargin = varargin(5:end);

opts = parseInputs(f,varargin{:});
[mnum, opts] = validateInputs(FRF,f,fs,mnum,opts);

% Cast to enforce precision rules.
fs = double(fs);
f = double(f(:));
mnum = double(mnum);
opts.pf = double(opts.pf);
opts.fr = double(opts.fr);
opts.nx = double(opts.nx);

% Compute the indices of the frequency range requested
fidx = (f >= opts.fr(1) & f <= opts.fr(2));

% Compute poles (natural frequency and damping). 
poles = signal.internal.modal.computePoles(FRF,f,fs,mnum,opts);

% Reduce poles to physical modes if PF is provided.
if ~isempty(opts.pf)
  pm = computePM(poles,opts);
  poles = poles(pm);
elseif strcmpi(opts.fm,'lsrf')
  poles = poles(1:min(mnum,end)); % pick mnum smallest ones
  poles = sort(poles); % sort chosen by natural frequency
end

if nargout > 2 || nargout == 0
  % Compute residues (MNUM by M by N)
  Res = signal.internal.modal.computeResidues(FRF(fidx,:,:),f(fidx),poles,opts.fm);
end

if nargout > 2
  % Compute mode shapes (M by MNUM)
  ms = signal.internal.modal.computeModeShapes(Res,opts.di);
end

if (nargout > 3 || nargout == 0)
  % Reconstruct frequency-response function
  ofrf = signal.internal.modal.computeRFRF(f,fidx,Res,poles,opts.fm);
end

% Plot reconstructed frfs.
if nargout == 0
  signal.internal.modal.plotFRF(FRF,f,fidx,'OutFRF',ofrf);
end

if nargout > 0
  % Compute natural frequency and damping ratio
  [fn,dr] = signal.internal.modal.polesTofd(poles);
  varargout{1} = fn;
end
if nargout > 1
  varargout{2} = dr;
end
if nargout > 2
  varargout{3} = ms;
end
if nargout > 3
  varargout{4} = ofrf;
end
%--------------------------------------------------------------------------
function opts = parseInputs(f,varargin)

% Check that name-value inputs come in pairs
if isodd(numel(varargin))
  error(message('signal:modalfit:NVMustBeEven'));
end

% Parse Name-value pairs
p = inputParser;
p.addParameter('FitMethod','LSCE');
p.addParameter('DriveIndex',[1 1]);
p.addParameter('PhysFreq',[]);
p.addParameter('FreqRange',[f(1) f(end)]);
p.addParameter('Order',[]);
p.addParameter('Feedthrough',false);

parse(p,varargin{:});
opts.di = p.Results.DriveIndex;
opts.fm = p.Results.FitMethod;
opts.pf = p.Results.PhysFreq;
opts.fr = p.Results.FreqRange;
opts.nx = p.Results.Order;
opts.ft = p.Results.Feedthrough;

% Validate string arguments
opts.fm = validatestring(opts.fm,{'pp','lsce','lsrf'});

%--------------------------------------------------------------------------
function [mnum, opts] = validateInputs(FRF,f,fs,mnum,opts)

validateattributes(FRF,{'single','double'},...
  {'nonsparse','finite','nonnan','nonempty','3d'},'modalfit','FRF');
validateattributes(f,{'single','double'},...
  {'real','nonnegative','nonsparse','finite','nonnan','vector','numel',...
  size(FRF,1)},'modalfit','F');
validateattributes(fs,{'single','double'},...
  {'real','positive','nonsparse','finite','nonnan','scalar'},'modalfit','Fs');
validateattributes(mnum,{'single','double'},...
  {'real','positive','integer','nonsparse','finite','nonnan','scalar'},...
  'modalfit','MNUM');
validateattributes(opts.di,{'single','double'},...
  {'real','positive','integer','nonsparse','finite','nonnan','vector',...
  'numel',2},'modalfit','DI');

if ~isempty(opts.nx)
   validateattributes(opts.nx,{'single','double'},...
      {'real','nonnegative','nonsparse','finite','scalar','integer'},'modalfrf','ORDER');
end

validateattributes(opts.ft, {'numeric','logical'},...
   {'binary','scalar'},'modalfrf','Feedthrough');

% Error out if di elements are larger than FRF
if opts.di(1) > size(FRF,2) || opts.di(2) > size(FRF,3)
  error(message('signal:modalfit:MustBeDI'));
end
validateattributes(opts.fr,{'single','double'},...
  {'real','nonnegative','nonsparse','finite','nonnan','vector',...
  'numel',2,'increasing'},'modalfit','FR');
if ~isempty(opts.pf) % This is empty by default
    validateattributes(opts.pf,{'single','double'},...
      {'real','nonnegative','nonsparse','finite','nonnan','vector',...
      '<=',f(end),'>=',f(1)},'modalfit','PF');
end
if numel(opts.pf) > mnum
  error(message('signal:modalfit:MustBePF'));
end

if strcmp(opts.fm,'lsrf')
   if isempty(opts.nx)
      opts.nx = 2*mnum+2;
   elseif opts.nx < 2*mnum
      error(message('signal:modalfit:OrderMnum',2*mnum))
   end
end

if strcmp(opts.fm,'lsce')
  % Compare requested number of modes to the maximum possible
  fidx = (f >= opts.fr(1) & f <= opts.fr(2));
  mmax = signal.internal.modal.computeMaxM(FRF(:,1,1),f,fs,fidx);
  if mnum > mmax
    warning(message('signal:modalfit:MaxM',mmax));
    mnum = mmax;
  end  
end

%--------------------------------------------------------------------------
function pm = computePM(poles,opts)
% Return the linear index of the pole with natural frequency closest to
% each frequency specified in opts.pf.
pm = zeros(numel(opts.pf),size(poles,2),size(poles,3));
fn =  signal.internal.modal.polesTofd(poles);
for i = 1:length(opts.pf)
  for j = 1:size(fn,2)
    for k = 1:size(fn,3)
      [~,iMin] = min(abs(fn(:,j,k)-opts.pf(i)));
      pm(i,j,k) = sub2ind(size(fn),iMin,j,k);
    end
  end
end

function varargout = modalsd(FRF,f,fs,varargin)
%MODALSD Stabilization diagram for modal analysis
%   MODALSD(FRF,F,Fs) generates a stabilization diagram in the current plot
%   from frequency-response functions, FRF. MODALSD estimates the natural
%   frequencies and damping ratios for the first 50 modes by default. The
%   frequency vector, F, has a number of elements equal to the number of
%   rows of FRF, and Fs is a positive scalar specifying the sample rate of
%   the measurement data. The stabilization diagram can be used to
%   differentiate between computational and physical modes.
%
%   MODALSD(FRF,F,Fs,...,'MaxModes',MM) generates a stabilization diagram
%   using a maximum of MM modes.
%
%   MODALSD(FRF,F,Fs,...,'FreqRange',FR) estimates modal parameters
%   over the frequency range specified by the two element vector FR. FR
%   must have non-decreasing values contained within the frequency range in
%   F.
%
%   MODALSD(FRF,F,Fs,...,'SCriteria',SC) specifies the criteria to define
%   stable natural frequencies and damping ratios. SC is a two-element
%   positive vector containing the maximum fractional differences between
%   poles to classify them as stable. The first element of SC applies to
%   natural frequencies and the second to damping ratios. If SC is not
%   specified, it defaults to [0.01 0.05].
%
%   FN = MODALSD(FRF,F,Fs,...,'FitMethod', FM) uses the fitting
%   algorithm specified by FM to estimate modal parameters. FM can be:
%     'lsce': least-squares complex exponential (LSCE) algorithm
%     'lsrf': least-squares rational function (LSRF) algorithm
%   When FM is not specified, it defaults to 'lsce'.
%
%   FN = MODALSD(FRF,F,Fs,...) returns a matrix of natural frequencies, FN,
%   identified as stable. The first I elements of the Ith row contain
%   natural frequencies. Poles that are nonphysical or not stable in
%   frequency are returned as NaNs.
%
%   % Example 1
%   %   Compute frequency response functions and generate a stabilization
%   %   diagram for a two-input/two-output system excited by random noise.
%   %   Output measurements are proportional to displacement.
%   load modaldata
%   winlen = 1200;
%   [FRF,f] = modalfrf(Xrand,Yrand,fs,hann(winlen),winlen/2,'Sensor','Dis');
%
%   % Visualize the stabilization diagram to identify physical modes. Use
%   % the LSRF method.
%   figure
%   modalsd(FRF,f,fs,'MaxModes',20,'FitMethod','lsrf')
%
%   % Example 2
%   %   Generate a stabilization diagram for a two-input/three-output
%   %   system excited by burst random noise.
%   load modaldata
%
%   % Compute the frequency response functions. Specify a rectangular window
%   % with length equal to the burst period in samples.
%   burstLen = 12000;
%   [FRF,f] = modalfrf(Xburst,Yburst,fs,burstLen);
%
%   % Visualize a stabilization diagram and return stable natural
%   % frequencies. Specify a maximum model order of 30 modes.
%   figure
%   fn = modalsd(FRF,f,fs,'MaxModes',30);
%
%   % Three modes appear in the stabilization diagram. Examine the
%   % frequencies corresponding to stable poles in fn.
%   fn(8,[1 3 4])
%
%   See also MODALFRF, MODALFIT.

%   Copyright 2016-2018 The MathWorks, Inc.


narginchk(3,9);
nargoutchk(0,1);

if nargin > 3
    [varargin{:}] = convertStringsToChars(varargin{:});
end

opts = parseInputs(f,varargin{:});
opts = validateInputs(FRF,f,fs,opts);

% Cast to enforce precision rules.
fs = double(fs);
f = double(f(:));
opts.sc = double(opts.sc);
opts.fr = double(opts.fr);

% Allocate arrays. Precision will depend on the precision of FRF.
fn = cell(opts.mm,1);
dr = cell(opts.mm,1);
modefn = nan(opts.mm,opts.mm);  % Matrix for plotting
modeStabfn = false(opts.mm,opts.mm);
modeStabdr = false(opts.mm,opts.mm);
fnout = zeros(opts.mm,'like',real(FRF(1)));
fnout(opts.mm,1:opts.mm) = nan;

% Compute poles for 1 to opts.mm modes. Disable warnings for the case of a
% rank deficient LSCE matrix. This will avoid repeated warnings.
[msg0, id0] = lastwarn('');
state = warning('off','MATLAB:rankDeficientMatrix');
cleanupObj = onCleanup(@()warning(state));

for iMode = 1:opts.mm
   opts.nx = 2*iMode;
   opts.ft = false;
   [fn_i, dr_i] = signal.internal.modal.polesTofd(...,
      signal.internal.modal.computePoles(FRF,f,fs,iMode,opts));
   [fn_i, I] = sort(fn_i);
   fn{iMode} = fn_i;
   dr{iMode} = dr_i(I);
   modefn(1:iMode,iMode) = fn{iMode};
   % Check for mode stability.
   if iMode > 1
      [modeStabfn(1:(iMode-1),iMode-1),modeStabdr(1:(iMode-1),(iMode-1))] = ...
         compareModes(fn{iMode},fn{iMode-1},dr{iMode},dr{iMode-1},opts);
      fnout(iMode-1,1:iMode-1) = fn{iMode-1}';
      % Remove frequencies from fnout corresponding to modes that are not
      % stable in frequency.
      fnout(iMode-1,~(modeStabfn(1:(iMode-1),iMode-1))) = nan;
   end
end

% Throw rank deficient warning if it occurred. Reset lastwarn if no warning
% were thrown.
[~,msgid] = lastwarn;
if strcmp(msgid,'MATLAB:rankDeficientMatrix')
   warning(message('signal:modalsd:RankDeficient'));
elseif isempty(msgid)
   lastwarn(msg0,id0);
end

% Plot stability diagram.
plotSDiagram(FRF,f,modefn,modeStabfn,modeStabdr,opts);

if nargout == 1
   % Compute natural frequency and damping ratio
   varargout{1} = fnout;
end

%--------------------------------------------------------------------------
function opts = parseInputs(f,varargin)

% Check that name-value inputs come in pairs and are all strings
if isodd(numel(varargin))
   error(message('signal:modalsd:NVMustBeEven'));
end

p = inputParser;
p.addParameter('FreqRange',[f(1) f(end)]);
p.addParameter('SCriteria',[0.01 0.05]);
p.addParameter('MaxModes',50);
p.addParameter('FitMethod','lsce');

parse(p,varargin{:});
opts.fr = p.Results.FreqRange;
opts.sc = p.Results.SCriteria;
opts.mm = p.Results.MaxModes;
opts.fm = p.Results.FitMethod;

% Validate string arguments
opts.fm = validatestring(opts.fm,{'lsce','lsrf'});

%--------------------------------------------------------------------------
function opts = validateInputs(FRF,f,fs,opts)

validateattributes(FRF,{'single','double'},...
   {'nonsparse','finite','nonnan','nonempty','3d'},'modalsd','FRF');
validateattributes(f,{'single','double'},...
   {'real','nonnegative','nonsparse','finite','nonnan','vector','numel',...
   size(FRF,1)},'modalsd','F');
validateattributes(fs,{'single','double'},...
   {'real','positive','nonsparse','finite','nonnan','scalar'},'modalsd','Fs');
validateattributes(opts.mm,{'single','double'},...
   {'real','positive','integer','nonsparse','finite','nonnan','scalar'},...
   'modalsd','MM');
validateattributes(opts.fr,{'single','double'},...
   {'real','nonnegative','nonsparse','finite','nonnan','vector',...
   'numel',2,'increasing'},'modalsd','FR');
validateattributes(opts.sc,{'single','double'},...
   {'real','positive','nonsparse','finite','nonnan','vector',...
   'numel',2},'modalsd','SC');

% Compare requested maximum number of modes to the maximum possible
fidx = (f >= opts.fr(1) & f <= opts.fr(2));
maxmm = signal.internal.modal.computeMaxM(FRF(:,1,1),f,fs,fidx);

% If no opts.mm was specified or the specified opts.mm is too large, return
% the maximum possible.
if isempty(opts.mm)
   opts.mm = maxmm;
elseif opts.mm > maxmm
   warning(message('signal:modalsd:WarnMaxModes',maxmm));
   opts.mm = maxmm;
end

%--------------------------------------------------------------------------
function [modeStabfn,modeStabdr] = compareModes(fn1,fn0,dr1,dr0,opts)
% Compare the locations of the natural frequencies and damping ratios
% between two model orders. fn1 and dr1 represent the larger model order.
% modeStabfn and modeStabdr are logical arrays of the same size as fn0 and
% dr0, and return true if there is a frequency or damping ratio in fn1 and
% dr1 that is within one percent of fn0 and dr0.
modeStabfn = false(size(fn0(:,1)));
modeStabdr = false(size(dr0(:,1)));

for i = 1:size(fn0,1)
   modeStabfn(i) = min(abs(fn0(i)-fn1(:)))<opts.sc(1)*fn0(i);
   modeStabdr(i) = min(abs(dr0(i)-dr1(:)))<opts.sc(2)*dr0(i);
end

%--------------------------------------------------------------------------
function plotSDiagram(FRF,f,modefn,modeStabfn,modeStabdr,opts)
% Plot a stability diagram in the current figure;
% Compute the indices of the frequency range requested.

import signal.internal.modal.*
fidx = (f >= opts.fr(1) & f <= opts.fr(2));
f = f(fidx);
iF = modeStabfn(:) & ~modeStabdr(:); % Stable frequency.
iFandD = modeStabfn(:) & modeStabdr(:); % Stable frequency and damping.
iNotF = ~modeStabfn(:); % Not stable in frequency.
modenumber = (1:opts.mm).*ones(opts.mm,1);

% Get current figure handle and clear it
ha = newplot;
yyaxis right

% Convert f and modefn to engineering units
[f,sc,uf] = engunits(f,'unicode');
modefn = modefn*sc;

% Plot modal indicator function
hp = plot(f,computeModalPeaksFunction(FRF(fidx,:,:)));
ylabel(getString(message('signal:modalplot:Magnitude')));
set(hp.Parent,'yscale','log');

% Plot poles. Indicate stable, stable in frequency, and unstable.
yyaxis left
plot(modefn(iF),modenumber(iF),'o')
hold on
plot(modefn(iFandD),modenumber(iFandD),'+')
plot(modefn(iNotF),modenumber(iNotF),'.')
hold off
ylim([0 opts.mm+0.5])
xlim([f(1) f(end)]);

% Add labels
xlabel([getString(message('signal:modalplot:Frequency')) ...
   ' (' uf getString(message('signal:modalplot:Hz')) ')'])
ylabel(getString(message('signal:modalplot:ModelOrder')))
title(getString(message('signal:modalplot:SDiagram')));

% Add legend
legStr = {getString(message('signal:modalplot:AvgResponse'))};
if any(iNotF)
   legStr = [{getString(message('signal:modalplot:NotStabFreq'))} legStr];
end
if any(iFandD)
   legStr = [{getString(message('signal:modalplot:StabFreqDamp'))} legStr];
end
if any(iF)
   legStr = [{getString(message('signal:modalplot:StabFreq'))} legStr];
end
legend(legStr{:});

% Grid
grid on;

% Set NextPlot to replace to clobber next time a plot command is issued.
set(ha.Parent,'NextPlot','replace');

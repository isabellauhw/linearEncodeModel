function varargout = ordertrack(varargin)
%ORDERTRACK Track and extract orders in a vibration signal
%   MAG = ORDERTRACK(X,Fs,RPM,ORDERLIST) returns a matrix, MAG, that
%   contains magnitude estimates of orders present in the input signal, X.
%   X has sampling frequency, Fs. The rotational speed vector, RPM, has the
%   same length as X. MAG contains one row for each order specified in the
%   vector ORDERLIST. Orders in ORDERLIST must be positive and less than
%   the maximum allowed order, Fs/(2*max(RPM/60)). By default, MAG has RMS
%   amplitude and linear scale.
%
%   [MAG,RPM,TIME] = ORDERTRACK(X,Fs,RPM,ORDERLIST) returns a row vector of
%   rpm values, RPM, and a row vector of time values, TIME, whose elements
%   correspond to the columns of MAG.
%
%   [...] = ORDERTRACK(MAP,ORDER,RPM,TIME,ORDERLIST) computes MAG for each
%   order specified in the vector ORDERLIST based on an order map matrix,
%   MAP, order vector, ORDER, rpm vector, RPM, and time vector, TIME. These
%   arguments can be computed using the RPMORDERMAP function. Orders in
%   ORDERLIST must be within the range of orders in ORDER. The amplitude
%   and scaling of MAG are the same as in MAP. 
%
%   [...] = ORDERTRACK(X,Fs,RPM,ORDERLIST,RPMREFIDX) extracts order
%   magnitudes using the first-order Vold-Kalman filter. RPM is a matrix
%   that contains one RPM vector in each column and has at least two
%   columns.  RPMREFIDX is a vector that contains the column index of the
%   RPM matrix for each order in ORDERLIST. The output argument RPM is a
%   matrix with the same size as MAG that contains an RPM vector in each
%   row.
%
%   [...] = ORDERTRACK(X,Fs,RPM,ORDERLIST,...,'Amplitude',AMP) returns
%   root-mean-squared (RMS) amplitudes when AMP is set to 'rms', peak
%   amplitudes when AMP is set to 'peak', and power levels when AMP is set
%   to 'power'. If AMP is not specified, it defaults to 'rms'.
%
%   [...] = ORDERTRACK(X,Fs,RPM,ORDERLIST,...,'Scale',SCALE) returns order
%   magnitudes in linear units if SCALE is set to 'linear' and in decibels
%   if SCALE is set to 'dB'. If not specified, SCALE defaults to 'linear'.
%
%   [...] = ORDERTRACK(X,Fs,RPM,ORDERLIST,RPMREFIDX,...,'Bandwidth',BW)
%   extracts order magnitudes using the Vold-Kalman filter with approximate
%   half-power bandwidths, BW, in hertz. BW is either a scalar or a vector
%   with the same number of elements as ORDERLIST. Smaller bandwidth values
%   produce smooth, narrowband outputs, but are less accurate when order
%   amplitudes change rapidly. If BW is not specified, it defaults to
%   1% of the sampling frequency.
%
%   [...] = ORDERTRACK(X,Fs,RPM,ORDERLIST,RPMREFIDX,...,'Decouple',DC) uses
%   the Vold-Kalman filter to extract order magnitudes simultaneously when
%   DC is TRUE or individually when DC is FALSE. Order magnitudes extracted
%   simultaneously can separate closely spaced or crossing orders and take
%   longer to compute. If DC is not specified, it defaults to FALSE.
%
%   [...] = ORDERTRACK(X,Fs,RPM,ORDERLIST,RPMREFIDX,...,'SegmentLength',SL)
%   divides the input signal into overlapping segments of length SL to
%   reduce memory requirements and computation time of the Vold-Kalman
%   filter. This option is recommended for large input signals. When a
%   segment length, SL, is provided, ORDERTRACK computes the order
%   magnitude for each segment and combines the segments to produce the
%   output. If segments are too short, localized events such as crossing
%   orders may not be properly captured. If SL is not specified, the entire
%   input signal, X, is processed in one step.
%
%   ORDERTRACK(...) with no output arguments plots the extracted orders on
%   the current figure along with a corresponding rpm plot. RMS amplitude
%   and linear scale are assumed if a map matrix is provided.
%
%   % EXAMPLE 1:
%   %   Compute order magnitudes from a vibration data set.
%   load('helidata.mat')
% 
%   % Remove the DC bias from the vibration signal.
%   vib = vib - mean(vib);
% 
%   % Compute the rpm-order map.
%   [map,order,rpmOut,time] = rpmordermap(vib,fs,rpm,0.010);
%   
%   % Extract and plot order magnitudes.
%   ordertrack(map,order,rpmOut,time,[0.052 0.066 0.264])
%
%   % EXAMPLE 2:
%   %   Compute order magnitudes of a chirp with 4 orders and sampled at 
%   % 600 Hz.
%   Fs = 600; 
%   t = (0:1/Fs:5)';     
%   f0 = 10; % order 1 instantaneous frequency at 0 seconds
%   f1 = 40; % order 1 instantaneous frequency at 5 seconds
%   
%   % RPM profile
%   rpm = 60*linspace(f0,f1,length(t))';
%   
%   % Generate a signal containing 4 chirps that are harmonically related.
%   phase = 2*pi*cumsum(rpm/60/Fs);
%   x = sum([1 2 3 4].*sin([phase, 0.5*phase, 4*phase, 6*phase]),2); 
%   
%   % Visualize order magnitudes as a function of rpm.
%   ordertrack(x,Fs,rpm,[1 0.5 4 6])
%
%   % EXAMPLE 3:
%   %   Create a simulated vibration signal consisting of two crossing
%   % orders for two different motors.
%   fs = 300;
%   rpm1 = linspace(10,100,1e3)'*60;
%   rpm2 = linspace(50,70,1e3)'*60;
%   x = sum([2 4].*cos(2*pi*cumsum([rpm1 rpm2]/60,1)/fs),2);
% 
%   % Visualize the orders in the frequency domain using rpmfreqmap.
%   rpmfreqmap(x,fs,rpm1)
% 
%   % Generate an order map of the data.
%   [map,order,rpmOut,timeOut] = rpmordermap(x,fs,rpm1,0.2);
% 
%   % Create an order list for the first motor (rpm1).
%   orderlist = 1;
% 
%   % Compute order magnitude as a function of rpm for motor 1.
%   figure
%   ordertrack(map,order,rpmOut,timeOut,orderlist)
% 
%   % Compute order magnitudes for both motors using the Vold-Kalman 
%   % filter to decouple the crossing orders.
%   figure
%   ordertrack(x,fs,[rpm1 rpm2],[1 1],[1 2],...
%     'Decouple',true)
%
%   See also RPMORDERMAP, ORDERWAVEFORM, TACHORPM, ORDERSPECTRUM

%   References:
%     [1] Brandt, Anders. Noise and Vibration Analysis: Signal Analysis 
%         and Experimental Procedures. Chichester, UK: John Wiley & Sons,
%         2011.
%     [2] Feldbauer, C., and Holdrich, R. Realization of a Vold-Kalman
%         Tracking Filter - A Least-Squares Problem. Proceedings of the
%         COST G-6 Conference on Digital Audio Effects, Verona, Italy,
%         December 7-9, 2000.

% Copyright 2015-2020 The MathWorks, Inc.
%#codegen

narginchk(4,15);
nargoutchk(0,3);

inpArgs = cell(size(varargin));
[inpArgs{:}] = convertStringsToChars(varargin{:});
isMATLAB = coder.target('MATLAB');
isSignal = coder.internal.isConst(isscalar(inpArgs{2})) && isscalar(inpArgs{2}) ;
% Parse inputs
if isSignal
  % This is the x,fs,rpm syntax, since the output 'order' of rpmordermap
  % must have at least two values. If the second argument is a scalar, we
  % must have the X,Fs,RPM syntax.
  inputType = 'signal';
  X = inpArgs{1};
  Fs = inpArgs{2};
  Rpm = inpArgs{3};
  Orderlist = inpArgs{4};
  
  % Parse name-value pairs 
  [doVK,amp,scale,Bw,sl,Refidx,dc] = parseinputs(X,Fs,Rpm,Orderlist,inpArgs{5:end});
    
  % Validate inputs
  validateInputs(X,Fs,Rpm,Orderlist,Bw,sl,Refidx,dc,[],[],[],[],inputType)
  
  % Cast to enforce precision rules (we already checked that the inputs are
  % numeric.)
  % Convert vectors to columns vectors, including rpm if it is a vector.
  sl = sl(1);
  dc = dc(1);
  rpm = double(signal.internal.toColIfVect(Rpm));
  fs = double(Fs);
  orderlist = double(Orderlist(:));
  bw = double(Bw(:)); 
  refidx = Refidx(:);
  x = X(:);
  % Compute time vector for input
  time = (0:length(x)-1)'/fs;   
else
  % This is the MAP,ORDER,RPM,TIME syntax
  coder.internal.errorIf(isscalar(inpArgs{2}),'signal:rpmmap:OrderCannotBecomeScalar');
  inputType = 'map';  
  coder.internal.errorIf(nargin > 5,'signal:rpmmap:MAPORDERTRACKNOARGS');
  narginchk(5,5);
  map = inpArgs{1};
  Order = inpArgs{2};
  Maprpm = inpArgs{3};
  Maptime = inpArgs{4};
  Orderlist = inpArgs{5};
  
  % Validate inputs
  validateInputs([],[],[],Orderlist,[],[],[],[],map,Order,Maprpm,Maptime,inputType)

  % Allocate default and unused variables
  % Amplitude and scale are used as plot labels only.
  amp = 'rms';
  scale = 'linear';
  rpm = [];
  time = [];

  % Cast to enforce precision rules (we already checked that the inputs are
  % numeric.)
  orderlist = double(Orderlist(:));
  maptime = double(Maptime(:));
  maprpm = double(Maprpm(:)); 
  order = Order(:);
end

if ~isSignal
  % We have a map. Extract magnitudes.
  mag = computeMAGwithMAP(map,order,orderlist);
  if isa(mag,'single')
      outtime = single(maptime');
      outrpm = single(maprpm');
  else
      outtime = maptime';
      outrpm = maprpm';
  end
else  
  % We have an input signal and rpm. Compute the map if rpm is a
  % vector, otherwise use the Vold-Kalman filter.  
  if ~doVK
    % Use the resampling approach. First, compute the map.
    [map,order,maprpm,maptime] = rpmordermap(x,fs,rpm,...
      'Amplitude',amp,'Scale',scale);
    
    % Compute order magnitudes using the map.
    mag = computeMAGwithMAP(map,order,orderlist);
    outtime = maptime';
    outrpm = maprpm';
  else
    % Compute order magnitudes using the Vold-Kalman filter.
    mag = computeMAGwithVK(x,rpm,fs,orderlist,refidx,bw,dc,amp,scale,sl);

    % Assign outputs and empty map variables (there is no map).
    if isMATLAB
      maprpm = [];
      maptime = [];
    end
    if isa(mag,'single')
        outtime = single(time');
        outrpm =  single(rpm(:,refidx)');
    else
        outtime = time';
        outrpm = rpm(:,refidx)';        
    end
  end
end

% Assign outputs or plot the order amplitude
switch nargout
  case 0
    coder.internal.assert(isMATLAB,'signal:rpmmap:PlottingNotSupported');  
    plotOrders(maptime,time,maprpm,rpm,mag,orderlist,inputType,amp,scale);
  case 1
    varargout{1} = mag;
  case 2
    varargout{1} = mag;
    varargout{2} = outrpm;
  case 3
    varargout{1} = mag;
    varargout{2} = outrpm;
    varargout{3} = outtime; 
end
%--------------------------------------------------------------------------
function [doVK,amp,scale,bw,sl,refidx,dc] = parseinputs(x,fs,rpm,orderlist,varargin) 

if nargin > 4 && ~ischar(varargin{1})
  % Error out if refidx is provided but rpm is a vector
  coder.internal.assert(~isvector(rpm),'signal:rpmmap:RPMMustBeMatrix');
  refidx = varargin{1};
  args = {varargin{2:end}};
  doVK = true;
else
  refidx = ones(size(orderlist));
  % Check that rpm is a vector
  coder.internal.assert(isvector(rpm),'signal:rpmmap:MustbeVectorRPMREFIDX');
  args = varargin;
  doVK = false;
end

% Default values
defaultAmp = 'rms';
defaultScale = 'linear';
defaultBw = 0.01*fs;
defaultsl = length(x);
defaultdc = false;

% Check that name-value inputs come in pairs and are all strings
coder.internal.assert(~isodd(numel(args)),'signal:rpmmap:NVMustBeEven');
% Parse Name-value pairs
if coder.target('MATLAB')
    p = inputParser;
    p.addParameter('Amplitude',defaultAmp);
    p.addParameter('Scale',defaultScale);
    p.addParameter('Bandwidth',defaultBw);
    p.addParameter('SegmentLength',defaultsl);
    p.addParameter('Decouple',defaultdc);
    parse(p,args{:});
    ampOut = p.Results.Amplitude;
    scaleOut = p.Results.Scale;
    bwOut = p.Results.Bandwidth;
    slOut = p.Results.SegmentLength;
    dcOut = p.Results.Decouple;
    
    %if rpm is a vector, do not allow Vold-Kalman filter N-V pairs
    if isvector(rpm) && ~all(ismember({'Bandwidth','Decouple','SegmentLength'},p.UsingDefaults))
        voldkalmanNV = {'Bandwidth','Decouple','SegmentLength'};
        invalidNV = ~ismember(voldkalmanNV,p.UsingDefaults);
        error(message('signal:rpmmap:NVPairInvalid',...
            strjoin(voldkalmanNV(invalidNV),', ')));
    end
else
    params = struct('Amplitude',uint32(0),'Scale',uint32(0),...
              'Bandwidth',uint32(0),'SegmentLength',uint32(0),...
              'Decouple',uint32(0));
           
    poptions = struct('CaseSensitivity',false, ...
                     'PartialMatching','unique', ...
                     'StructExpand',false, ...
                     'IgnoreNulls',false);
    pstruct  =  coder.internal.parseParameterInputs(params,poptions,args{:});             
    ampOut   =  coder.internal.getParameterValue(pstruct.Amplitude,defaultAmp,args{:});
    scaleOut =  coder.internal.getParameterValue(pstruct.Scale,defaultScale,args{:});
    bwOut    =  coder.internal.getParameterValue(pstruct.Bandwidth,defaultBw,args{:});
    slOut    =  coder.internal.getParameterValue(pstruct.SegmentLength,defaultsl,args{:});
    dcOut    =  coder.internal.getParameterValue(pstruct.Decouple,defaultdc,args{:});
    
    voldkalmanNV = {'Bandwidth','Decouple','SegmentLength'};
    invalidNV    = [pstruct.Bandwidth,pstruct.Decouple,pstruct.SegmentLength] ~= zeros('uint32');
    invalidStr = coder.const(strjoin({voldkalmanNV{invalidNV}},','));
    %if rpm is a vector, do not allow Vold-Kalman filter N-V pairs
    coder.internal.errorIf(isvector(rpm) && any(invalidNV),'signal:rpmmap:NVPairInvalid',...
        invalidStr);
end
sl = slOut;
% If bw is a scalar, turn it into a vector
if isscalar(bwOut) && length(orderlist)>1
    bw = bwOut(1)*ones(length(orderlist),1);
else
    bw = bwOut;
end

% Cast dc to logical if it is numeric
if isnumeric(dcOut)
  validateattributes(dcOut,{'numeric'},{'nonnan'},'ordertrack','DC')  
  dc = logical(dcOut);
else
  dc =  dcOut;
end
    
% Check that amp,and scale match to allowed values
amp = validatestring(ampOut,{'peak','rms','power'},'ordertrack','AMP');
scale = validatestring(scaleOut,{'linear','dB'},'ordertrack','SCALE');
%--------------------------------------------------------------------------
function validateInputs(x,fs,rpm,orderlist,bw,sl,refidx,dc,map,order,maprpm,maptime,bMap)
if strcmp(bMap,'signal')
  validateattributes(x,{'single','double'},...
    {'real','nonsparse','nonnan','finite','vector'},'ordertrack','X');
  validateattributes(fs,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','scalar'},'ordertrack','Fs');
  validateattributes(rpm,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','nonempty'},'ordertrack','RPM');
  validateattributes(orderlist,{'numeric'},...
      {'real','positive','nonsparse','nonnan','finite','vector'},'ordertrack','ORDERLIST');
  validateattributes(bw,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','vector',...
    'numel',length(orderlist)},'ordertrack','BW');
  validateattributes(sl,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','scalar','integer'...
    '<=',length(x),'>=',16},'ordertrack','SL');
  if isvector(rpm)
    nrpm=1;
    Omax = fs./(2*max(rpm(:))/60)';
  else 
    nrpm = size(rpm,2);
    Omax = fs./(2*max(rpm,[],1)/60)';
  end
  validateattributes(refidx,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','integer','vector',...
    'numel',length(orderlist),'<=',nrpm},'ordertrack','REFIDX');
  validateattributes(dc,{'logical'},...
    {'nonsparse','nonnan','scalar'},'ordertrack','DC');
  % Make sure rpm is either a vector with the same length as x or a matrix
  % with the same number of rows as the length of x 
  coder.internal.assert((isvector(rpm)&&(length(rpm)==length(x)))...
      || (size(rpm,1)==length(x)),'signal:rpmmap:RPMMustBeVectorMatrix')
  
  % Validate order list to make sure no values exceed the maximum order 
  if ~all(orderlist(:) < Omax(refidx(:)))
      if coder.target('MATLAB')
          badOrdersString = sprintf('% .3f',orderlist(orderlist(:) >= Omax(refidx(:))));
          error(message('signal:rpmmap:OrderlistExceedMaxOrder',badOrdersString));
      else
          idx = orderlist(:) >= Omax(refidx(:));
          invalidOrders = orderlist(idx);
          badOrderString = sprintf('% .3f',invalidOrders(1));
          for i = 2:length(invalidOrders)
              badOrderString = [badOrderString sprintf('% .3f',invalidOrders(i))]; %#ok
          end
          coder.internal.error('signal:rpmmap:OrderlistExceedMaxOrder',badOrderString)
      end
  end
else
  validateattributes(map,{'single','double'},...
    {'real','nonnegative','nonsparse','nonnan','finite','nonempty'},'ordertrack','MAP');
  validateattributes(maprpm,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','vector'},'ordertrack','RPM');
  validateattributes(maptime,{'numeric'},...
    {'real','nonnegative','nonsparse','nonnan','finite','vector',...
    'numel',length(maprpm)},'ordertrack','TIME');
  validateattributes(order,{'numeric'},...
    {'real','nonnegative','nonsparse','nonnan','finite','vector'},'ordertrack','ORDER');
  validateattributes(orderlist,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','vector',...
    '<=',max(order,[],'all'),'>=',min(order,[],'all')},'ordertrack','ORDERLIST');
  
  % Check map and order have consistent dimensions
  coder.internal.assert(size(map,1)==length(order),'signal:rpmmap:OrderMatchMap')

  % Check that map and rpm have consistent dimensions
  coder.internal.assert(size(map,2)==length(maprpm),'signal:rpmmap:RPMMatchMap');
end

%--------------------------------------------------------------------------
function mag = computeMAGwithVK(x,rpm,fs,orderlist,refidx,bw,dc,amp,scale,sl)
% Use the Vold-Kalman filter
xlen = length(x);
numOrd = length(orderlist);
F = coder.nullcopy(zeros(size(rpm,1),numOrd));

% Compute frequency track matrix
for i = 1:numOrd
  F(:,i) = orderlist(i)*rpm(:,refidx(i))/60;
end

% VK defaults
fo = 1; %Filter Order
r = ((1.58*fs)./(bw*2*pi)).^2; % Convert bandwidth to weighting ([2] eq. 31)

% Call the Vold-Kalman filter on coupled orders
if dc
  % Call the Vold-Kalman filter on coupled orders
  [~,xAmp] = signal.internal.vk(x,fs,F,r,fo,sl);
else
  % Call the Vold-Kalman filter on uncoupled orders, one by one
  xAmp = coder.nullcopy(zeros(xlen,numOrd,class(x)));      
  for i = 1:numOrd
    [~,xAmp(:,i)] = signal.internal.vk(x,fs,F(:,i),...
      r(i),fo,sl);
  end
end

% Order amplitude 
mag = abs(xAmp)';
switch amp
  case 'rms'
    mag = mag/sqrt(2);
  case 'peak'
    % No op
  case 'power'
    mag = mag.^2/2;
end

% Order Scale
switch scale
  case 'linear'
    % No op
  case 'dB'
    if isequal(amp,'power')
      mag = 10*log10(mag);
    else
      mag = 20*log10(mag);
    end
end
%--------------------------------------------------------------------------
function mag = computeMAGwithMAP(map,order,orderlist)
% Compute order magnitudes from the order map
mag = coder.nullcopy(zeros(length(orderlist),size(map,2),class(map)));
for i = 1:length(orderlist)
  [~,iOrder]=min(abs(order-orderlist(i)));
  mag(i,:) = map(iOrder,:); 
end
%--------------------------------------------------------------------------
function plotOrders(maptime,signaltime,maprpm,signalrpm,mag,orderlist,bInput,amp,scale)
% maptime - output times from rpmordermap
% maprpm - output rpm value from rpmordermap
% signaltime - time based on fs and input signal
% signalrpm - input rpm signal

% Assign magtime, which corresponds to mag, from the map. If maptime is
% empty, there is no map, so use signaltime.
if ~isempty(maptime)
  magtime = maptime;
else
  magtime = signaltime;
end

% Scale times used in the plots. Empty vectors will return empty.
signaltime = engunits(signaltime, 'unicode', 'time');
[magtime, ~, punits] = engunits(magtime, 'unicode', 'time');
maptime = engunits(maptime, 'unicode', 'time');
if strcmp(punits,'secs')
    punits = 's';
end

% Create subplots, change their size, and make them invisible until the
% plot command is called (which makes them visible automatically).
p1 = subplot(2,1,1);
p1.Visible = 'off';
p2 = subplot(2,1,2);
p2.Visible = 'off';
linkaxes([p1,p2],'x');

% Make the rpm plot smaller and the order plot larger
p1p = get(p1,'position');
p2p = get(p2,'position');
p1p(2) = 0.3612;
p1p(4) = 0.55;
p2p(4) = 0.175;
set(p1,'position',p1p)
set(p2,'position',p2p)

% Plot order magnitudes versus time
plot(p1,magtime,mag'); 
axes(p1);
title(getString(message('signal:rpmmapplot:OrderTracking')));
% Create y-axis label
switch amp
    case 'rms'
      ylbl = getString(message('signal:rpmmapplot:orderrms'));
    case 'power'
      ylbl = getString(message('signal:rpmmapplot:orderpower'));
    case 'peak'
      ylbl = getString(message('signal:rpmmapplot:orderpeak'));
end
if strcmp(scale,'dB')
  ylbl = [ylbl ' (dB)'];
end
ylabel(ylbl);
grid on;

% Create legend entries
legendstr = cellstr(num2str(orderlist(:)));
legendstr = cellfun(@(x) [getString(message('signal:rpmmapplot:order')) ': ' x],...
  legendstr,'UniformOutput',0);
legend(legendstr{:});

% Set p1 xtick and xTickLabels 
set(p1,'xTickLabels',[])

% Plot the signal time and rpm vectors and map time and rpm vectors, if
% given. If both are given, plot the map rpm superimposed on the signal
% rpm. This corresponds to the case where x is given and the resampling
% method is used. For Vold-Kalman, there is no map time and rpm. If the map
% is provided, there is no signal time and rpm.
axes(p2);
if strcmp(bInput,'signal')
  if isempty(maptime)
    [~,scale,units]=engunits(signalrpm);
    % Vold-Kalman
    plot(p2,signaltime,signalrpm*scale);
  else
    % Resampling - truncate signaltime to range of maptime
    [~,scale,units]=engunits(signalrpm);
    inds = signaltime>maptime(1)&signaltime<maptime(end);
    plot(p2,signaltime(inds),signalrpm(inds)*scale);
    hold on
    plot(p2,maptime,maprpm*scale,'r.');
  end
else
  % No input signal was provided. Plot only map time and rpm.
  [~,scale,units]=engunits(maprpm);
  plot(p2,maptime,maprpm*scale);
end

grid on

% Set the xlabel and ylabel for the plot
m = signal.internal.getMultiplier(units);
xlabel([getString(message('signal:spectrogram:Time')) ' (' punits ')']);
if isempty(m)
  ylabel(getString(message('signal:rpmmapplot:RPMs')));
else
  ylabel([getString(message('signal:rpmmapplot:RPMs')) ' (' m ')']);
end

% Make the plots tight in x and give a margin in y
axes(p1);
axis('tight');
yl1 = get(p1,'ylim');
yl2 = get(p2,'ylim');
set(p2,'ylim',[-.1 .1]*abs(diff(yl2))+yl2);
set(p1,'ylim',[-.1 .1]*abs(diff(yl1))+yl1);

% Create tags
p1.Tag = 'Mag';
p2.Tag = 'RPM';

% LocalWords:  Fs ORDERLIST RMS RPMORDERMAP RPMREFIDX Vold rms BW narrowband helidata vib
% LocalWords:  rpmordermap fs rpmfreqmap orderlist ORDERWAVEFORM TACHORPM ORDERSPECTRUM Chichester
% LocalWords:  Feldbauer Holdrich rpmmap MAPORDERTRACKNOARGS refidx Mustbe bw nonsparse VK maptime
% LocalWords:  maprpm signaltime signalrpm magtime rpmmapplot orderrms orderpower orderpeak xtick

function varargout = tachorpm(x,fs,varargin)
%TACHORPM Extract an RPM signal from tachometer pulses
%   RPM = TACHORPM(X,Fs) extracts a rotational speed signal vector, RPM,
%   from a tachometer pulse signal vector, X, with sampling frequency, Fs,
%   in hertz. RPM has the same number of elements as X.
%
%   [RPM,T] = TACHORPM(X,Fs) returns the RPM signal time vector, T,
%   measured in seconds.
%
%   [RPM,T,TP] = TACHORPM(X,Fs) returns a vector of detected pulse
%   times, TP, measured in seconds.
%
%   [...] = TACHORPM(...,'PulsesPerRev',PPR) specifies the number of
%   tachometer pulses per revolution, PPR. If PPR is not specified, it
%   defaults to 1.
%
%   [...] = TACHORPM(...,'StateLevels',SL) sets the levels used to identify
%   pulses. Specify SL as a two-element real vector with first and second
%   elements corresponding to the lower and upper state levels of the input
%   waveform. Choose the state levels so that all pulse edges cross within
%   10% of both of them. If SL is not specified, the levels are computed
%   automatically using the histogram of the input waveform.
%
%   [...] = TACHORPM(...,'OutputFs',OFs) specifies the sampling frequency
%   OFs, of the outputs RPM and T. If OFS is not specified, it defaults to
%   the tachometer sampling frequency, Fs.
%
%   [...] = TACHORPM(...,'FitType',FT) uses the fitting method
%   specified by FT to generate RPM. FT can be
%   'smooth' or 'linear':
%     'smooth' - fit a least-squares B-spline to pulse rpm values
%     'linear' - interpolate linearly between pulse rpm values
%   If FT is not specified, it defaults to 'smooth'.
%
%   [...] = TACHORPM(...,'FitPoints',FP) uses FP breakpoints in the
%   least-squares B-spline. The number of points, FP, is a trade-off
%   between curve smoothness (fewer points) and closeness to the underlying
%   data (more points). Choosing too many points can result in overfitting
%   the data. If unspecified, FP defaults to 10. If FT is
%   'linear', FP is ignored.
%
%   TACHORPM(...) with no output arguments creates plots containing the
%   generated rpm signal, the tachometer signal, and the detected pulses.
%
%   % EXAMPLE:
%   %   Load a tachometer signal.
%   load tacho.mat
%
%   % Compute and visualize the rpm signal using a large number of fit
%   % points to capture the rpm peak.
% 
%   tachorpm(Yn,fs,'FitPoints',100)
%   xlim([0 .1])
%   ylim([500 900])
%
%   See also RPMORDERMAP, ORDERTRACK, ORDERWAVEFORM, STATELEVELS

%   References:
%     [1] Brandt, Anders. Noise and Vibration Analysis: Signal Analysis 
%         and Experimental Procedures. Chichester, UK: John Wiley & Sons,
%         2011.

% Copyright 2015-2019 The MathWorks, Inc.
%#codegen

narginchk(2,12);
nargoutchk(0,3);

inpArgs = cell(size(varargin));
if nargin > 2
    [inpArgs{:}] = convertStringsToChars(varargin{:});
else
    inpArgs = varargin;
end

% Parse inputs
[x,x_class,fs,ppr,ofs,ft,sl,fp] = parseInputs(x,fs,inpArgs{:});

% Construct time vector
t = (0:length(x)-1)'/fs;

% Compute the rising and falling edges of the tachometer pulses using
% risetime and falltime.
[~,LT1] = risetime(x,fs,'StateLevels',sl,'Tolerance',10,...
  'PercentReferenceLevels',[50 51]);
[~,LT2] = falltime(x,fs,'StateLevels',sl,'Tolerance',10,...
'PercentReferenceLevels',[50 51]);

% Error out if no edges were detected
if isempty(LT1) || isempty(LT2)
   coder.internal.error('signal:rpmmap:StateLevelsEmpty');
end

% Make sure number of rising and falling edges is the same. If not, remove
% extra from the end of the signal
if length(LT1)~=length(LT2) 
  len = min([length(LT1) length(LT2)]);
  LT1 = LT1(1:len,1);
  LT2 = LT2(1:len,1);
end

% Compute the times of the center of each pulse
tCenter= mean([LT1(:) LT2(:)],2);

% Determine the period between pulse centers
T = diff(tCenter); 

% Calculate RPM values at the center points between pulse centers. 
rpmPulse = 60/ppr./T; 
tPulse = interp1(1:length(tCenter),tCenter,1.5:length(tCenter)-0.5);

% Compute the output rpm signal. Use either least-squared splines or linear
% interpolation.
tout = interp1(0:length(t)-1,t,0:fs/ofs:length(t)-fs/ofs,'linear','extrap')';

if strcmp(ft,'smooth')
  % Use a least-squares spline to produce the rpm signal
  b = linspace(tPulse(1),tPulse(end),fp);
  sp = spline(b,rpmPulse(:)'/spline(b,eye(length(b)),tPulse(:)'));
  rpm = ppval(sp,tout);
else
  % Use linear interpolation to produce the rpm signal
  rpm = interp1(tPulse,rpmPulse,tout,'linear','extrap');
end

% Cast output if x was single
if nargout > 0
    varargout{1} = cast(rpm(:),x_class);
    if nargout > 1
        varargout{2} = cast(tout(:),x_class);
        if nargout > 2
            varargout{3} = cast(tCenter(:),x_class);
        end
    end
else
    coder.internal.assert(coder.target('MATLAB'),'signal:rpmmap:PlottingNotSupported');
    plotTacho(t,tout,tPulse,tCenter,x,rpm,rpmPulse,sl);
end
%--------------------------------------------------------------------------
function [xCol,x_class,fs,ppr,ofs,ft,sl,fp] = parseInputs(x,fs,varargin)

validateattributes(x,{'numeric'},...
  {'real','finite','vector'},'tachorpm','X');

% Cast to enforce precision rules
% Since risetime, falltime, and statelevels won't accept single, cast to
% double and recast the output to x_class.
x_class = class(x);
xCol = double(x(:));

validateattributes(fs,{'numeric'},...
  {'real','positive','nonsparse','finite','scalar'},'tachorpm','Fs');

fs = double(fs(1));
% Default values
pprDefault = 1;
ofsDefault = fs;
ftDefault = 'smooth';
slDefault = [];
fpDefault = 10;
% Parse Name-value pairs
if ~isempty(varargin)
    % Check that name-value inputs come in pairs and are all strings
    coder.internal.assert(~isodd(numel(varargin)),'signal:rpmmap:NVMustBeEven')
    if coder.target('MATLAB')
        p = inputParser;
        p.addParameter('PulsesPerRev',pprDefault);
        p.addParameter('OutputFs',ofsDefault);
        p.addParameter('FitType',ftDefault);
        p.addParameter('StateLevels',slDefault);
        p.addParameter('FitPoints',fpDefault);
        parse(p,varargin{:});
        pprOut = p.Results.PulsesPerRev;
        ofsOut = p.Results.OutputFs;
        ftOut  = p.Results.FitType;
        slOut  = p.Results.StateLevels;
        fpOut  = p.Results.FitPoints;
    else
        params  = struct('PulsesPerRev',uint32(0),'OutputFs',uint32(0),'FitType',...
            uint32(0),'StateLevels',uint32(0),'FitPoints',uint32(0));
        poption = struct('CaseSensitivity',false, ...
            'PartialMatching','unique', ...
            'StructExpand',false, ...
            'IgnoreNulls',false);
        pstruct = coder.internal.parseParameterInputs(params,poption,varargin{:});
        pprOut  = coder.internal.getParameterValue(pstruct.PulsesPerRev,pprDefault,varargin{:});
        ofsOut  = coder.internal.getParameterValue(pstruct.OutputFs,ofsDefault,varargin{:});
        ftOut   = coder.internal.getParameterValue(pstruct.FitType,ftDefault,varargin{:});
        slOut   = coder.internal.getParameterValue(pstruct.StateLevels,slDefault,varargin{:});
        fpOut   = coder.internal.getParameterValue(pstruct.FitPoints,fpDefault,varargin{:});
    end
    validateattributes(pprOut,{'numeric'},...
      {'real','positive','nonsparse','finite','scalar'},'tachorpm','PPR');
    ppr = double(pprOut(1));
   
    validateattributes(ofsOut,{'numeric'},...
      {'real','positive','nonsparse','finite','scalar'},'tachorpm','OFs')
    ofs = double(ofsOut(1));
    
    validateattributes(fpOut,{'numeric'},...
      {'real','positive','nonsparse','finite','scalar','>=',2},'tachorpm','FP');
    fp = fpOut(1);
    
    % Use statelevels if levels have not been provided
    if isempty(slOut)
        sl = statelevels(xCol);
    else
        validateattributes(slOut,{'numeric'},...
         {'real','finite','nonsparse','vector','numel',2},'tachorpm','SL');
        sl = double(slOut(:).');
    end
    
    % Check that ft is a match to allowed values
    ft = validatestring(ftOut,{'linear','smooth'},'tachorpm','FT'); 
else
    ppr = pprDefault;
    ofs = ofsDefault;
    ft  = ftDefault;
    fp  = fpDefault;
    sl  = statelevels(xCol);
end

%--------------------------------------------------------------------------
function plotTacho(t,tout,tPulse,tCenter,x,rpm,rpmPulse,sl)
  [~,E,U]=engunits(t,'unicode','time');
  xlab = [getString(message('signal:spectrogram:Time')) ' (' U ')'];
  
  % Create subplots, change their size, and make them invisible until the
  % plot command is called (which makes them visible automatically).
  p1 = subplot(2,1,1);
  p2 = subplot(2,1,2);
  linkaxes([p1,p2],'x');

  % Make the rpm plot larger and the pulse plot larger
  p1p = get(p1,'position');
  p2p = get(p2,'position');
  p1p(2) = 0.3612;
  p1p(4) = 0.55;
  p2p(4) = 0.175;
  set(p1,'position',p1p)
  set(p2,'position',p2p)

  % RPM plot
  axes(p1);
  hold on
  plot(p1,tout*E,rpm); 
  plot(p1,tPulse*E,rpmPulse,'+');
  ylabel(getString(message('signal:rpmmapplot:RPMs')));
  legend(getString(message('signal:rpmmapplot:rpmsignal')),...
    getString(message('signal:rpmmapplot:rpmpulses')),'Location','SouthEast');
  grid on;
  title(getString(message('signal:rpmmapplot:rpmSignal')));
  set(p1,'xTickLabels',[])
  axis('tight');
  hold off;

  % Pulse and tacho plot
  axes(p2);
  hold on
  plot(p2,tCenter*E,mean(interp1(t,x,tCenter))*ones(size(tCenter)),'+', ...
    'Color',[0.8500 0.3250 0.0980]);
  plot(p2,tout*E,(sl(1)) * ones(size(tout)),'--','Color', ...
    [0.4660 0.6740 0.1880],'MarkerSize',1);
  plot(p2,tout*E,(sl(2)) * ones(size(tout)),'--','Color',...
    [0.4660 0.6740 0.1880],'MarkerSize',1);
  plot(p2,t*E,x,'Color',[0 0.4470 0.7410]);

  xlabel(xlab);
  ylabel(getString(message('signal:rpmmapplot:volts')));
  grid on;
  title(getString(message('signal:rpmmapplot:tachoSignal')));
  legend(getString(message('signal:rpmmapplot:detectedpulses')), ...
    getString(message('signal:rpmmapplot:statelevels')));
  axis('tight');
  hold off;

  % Make the plots tight in x and give a margin in y
  axes(p1);
  axis('tight');
  yl1 = get(p1,'ylim');
  yl2 = get(p2,'ylim');
  set(p2,'ylim',[-.1 .1]*abs(diff(yl2))+yl2);
  set(p1,'ylim',[-.1 .1]*abs(diff(yl1))+yl1);

  % Create tags
  p1.Tag = 'RPM';
  p2.Tag = 'Tacho';
 







% LocalWords:  Fs TP OFs OFS FP overfitting tacho Yn fs RPMORDERMAP ORDERTRACK
% LocalWords:  ORDERWAVEFORM STATELEVELS Chichester risetime falltime rpmmap
% LocalWords:  extrap statelevels nonsparse rpmmapplot rpmsignal rpmpulses
% LocalWords:  detectedpulses

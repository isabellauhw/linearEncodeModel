function varargout = envspectrum(x,varargin)
%ENVSPECTRUM Envelope spectrum for machinery diagnosis
%   ES = ENVSPECTRUM(X,Fs) computes the envelope spectrum, ES, of the
%   signal X. X is sampled at a rate of Fs. ES contains the one-sided
%   magnitude spectrum of the envelope signal of X, and to peak amplitude.
%   ES has (N/2+1) rows if N, the length of X, is even, and (N+1)/2 rows if
%   N is odd. If X is a matrix, each column of ES contains the envelope
%   spectrum of the corresponding column of X.
%
%   ES = ENVSPECTRUM(XT) computes the envelope spectrum of the signal
%   contained in the timetable XT. XT must contain a single numeric column
%   variable. The time values in XT must be strictly increasing, finite,
%   uniformly spaced.
%
%   ES = ENVSPECTRUM(...,'Method',EM) specifies the algorithm used to
%   compute the envelope signal. EM can be:
%     'hilbert': compute the envelope using the Hilbert transform
%       'demod': compute the envelope using complex demodulation
%   EM defaults to 'demod'.
%
%   ES = ENVSPECTRUM(...,'Band',BA) specifies the frequency band over which
%   to compute the envelope spectrum. BA is a two element vector of
%   strictly increasing values in the range (0 Fs/2). 'Band' defaults to
%   [Fs/4 3*Fs/8].
%
%   ES = ENVSPECTRUM(...,'FilterOrder',FO) specifies the FIR filter order,
%   FO, as a positive integer scalar. The FIR filter is a bandpass filter
%   when 'Method' is 'hilbert' or a lowpass filter when 'Method' is
%   'demod'. FO defaults to 50.
%
%   [ES,F] = ENVSPECTRUM(...) returns a vector of frequencies, F, in hertz,
%   at which ES is evaluated.
%
%   [ES,F,ENV,T] = ENVSPECTRUM(...) returns the envelope signal, ENV, and
%   the corresponding time vector, T.
%
%   ENVSPECTRUM(...) with no output arguments plots the envelope signal and
%   the envelope spectrum in the current figure.
%
%   % Example:
%   %   Plot the envelope spectrum of two simulated vibration signals.
%   %   The first signal corresponds to healthy bearings, and
%   %   the second to damaged bearings. 
%   load envspec.mat
%   envspectrum([yGood yBad],fs,'Band',[2500 3500])
%   xlim([0 10*bpfo]/1000)
%
%   %   Compare the peak locations to the frequencies of  
%   %   harmonics of the outer race bearing impact frequency, bpfo.
%   harmImpact = (1:10)*bpfo/1000;
%   hold on
%   line([harmImpact; harmImpact],repmat([0;.07],1,10),...
%     'Color',[.5 .5 .5],'LineStyle','-.') 
%   legend('Normal','Damage','BPFO harmonics')
%   hold off
%
%   See also ENVELOPE, HILBERT, ORDERSPECTRUM.

%   Copyright 2017-2018 The MathWorks, Inc.

%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

narginchk(1,8);
nargoutchk(0,4);

if nargout == 0 && ~coder.target('MATLAB')
    % Plotting is not supported for code generation. If this is running in
    % MATLAB, just call MATLAB's ENVSPECTRUM, else error.
    coder.internal.assert(coder.target('MEX') || coder.target('Sfun'), ...
        'signal:codegeneration:PlottingNotSupported');
    feval('envspectrum',x,varargin{:});
    return
end

[x,t,fs,ba,em,b,isTTable,td,varNames] = parseAndValidateInputs(x,varargin{:});

% Cast to enforce precision rules.
if isa(x,'single')
    t = single(t);
    ba = single(ba);
    fs = single(fs);
else
    t = double(t);
    ba = double(ba);
    fs = double(fs);
end

% Remove dc offset from x
x = bsxfun(@minus,x,mean(x,1));

if strcmp(em,'hilbert')
    % Band-pass filter the signal.
    xBandPass = conv2(x,b(:),'same');
    
    % Compute the envelope of the analytic signal.
    xAn = hilbert(xBandPass);
    xEnv = abs(xAn);
    
else
    % Perform complex demodulation.
    f0 = (ba(2)+ba(1))/2;
    x0 = bsxfun(@times,x,exp(-1i*2*pi*f0*t));
    
    % Low pass filter to compute the analytic signal.
    xAn = conv2(x0,b(:),'same');
    xAn = 2*xAn;
    
    % Compute the envelope signal.
    xEnv = abs(xAn);
end

% Remove DC bias from envelope
xEnv = bsxfun(@minus,xEnv,mean(xEnv,1));

% Compute the envelope spectrum.
fSpec = (0:length(xEnv)-1)'/length(xEnv)*fs;
xSpec = 1/size(xEnv,1)*abs(fft(xEnv));

% Compute one-sided spectrum. Compensate the amplitude for a two-sided
% spectrum. Double all points except DC and nyquist.
if isodd(length(xSpec))
    % Odd length two-sided spectrum
    fSpec = fSpec(1:(end+1)/2);
    xSpec = xSpec(1:(end+1)/2,:);
    xSpec(2:end,:) = 2*xSpec(2:end,:);
else
    % Even length two-sided spectrum
    fSpec = fSpec(1:end/2+1);
    xSpec = xSpec(1:end/2+1,:);
    xSpec(2:end-1,:) = 2*xSpec(2:end-1,:);
end

if nargout == 0
    localPlot(xEnv,fs,t,td,fSpec,xSpec);
else
    varargout{1} = xSpec;
end
if nargout > 1
    varargout{2} = fSpec;
end
if nargout > 2
    if isTTable        
        newVarNames = cell(numel(varNames),1);
        if numel(varNames) > 1
            for idx = 1:numel(varNames)
                newVarNames{idx} = [varNames{idx} '_env'];                                
            end            
            varargout{3} = array2timetable(xEnv,'RowTimes',td,'VariableNames',newVarNames);
        else
            varargout{3} = timetable(td,xEnv,'VariableNames',{[varNames{1} '_env']});
        end
    else
        varargout{3} = xEnv;
    end
end
if nargout > 3
    if isTTable
        varargout{4} = td;
    else
        varargout{4} = t;
    end
end

end
%--------------------------------------------------------------------------
function [x,t,fs,ba,em,b,isTTable,td,varNames] = parseAndValidateInputs(X,varargin)

isInMATLAB = coder.target('MATLAB');
isTTable = isa(X,'timetable');

% Check that if we don't have a timetable that we have at least 2
% inputs.
if ~isTTable
    narginchk(2,8);
end
varNames = [];
% If we have a timetable, parse signal information and compute the sample
% rate. Otherwise, check that we have at least two inputs and validate and
% save the input sample rate. Save in index of the position of the first
% name-value pair in varargin.
if isTTable
    varNames = X.Properties.VariableNames;
    if nargin > 1 && ~ischar(varargin{1})
        %Error out if we have a timetable followed by a numerical value.
        [x,t,td] = signal.internal.nvh.parseTimeCodegen(X,'envspectrum',varargin{1},true);
    else
        [x,t,td] = signal.internal.nvh.parseTimeCodegen(X,'envspectrum',[],true);
    end
    fs = 1/mean(diff(t));
    ivarargin = 1;
else
    fs = varargin{1};
    validateattributes(fs,{'single','double'},...
        {'real','finite','nonsparse','scalar','positive'},'envspectrum','Fs');
    [x,t,td] = signal.internal.nvh.parseTimeCodegen(X,'envspectrum',fs,true);
    ivarargin = 2;
end

% Validate x.
validateattributes(x,{'single','double'},...
    {'real','finite','nonsparse','2d'},'envspectrum','X');

% Error out if x has fewer than 4 elements.
coder.internal.assert(size(x,1) > 3,'signal:envspectrum:MinLen','X');

% Validate t and check if it is uniformly spaced.
validateattributes(t,{'single','double'},...
    {'real','finite','nonsparse','vector','increasing','numel',size(x,1)},'envspectrum','T');
err = max(abs(t-linspace(t(1),t(end),numel(t))')./max(abs(t),[],1),[],1);
isTUniform = err < 3*eps(class(t));
coder.internal.assert(isTUniform,'signal:envspectrum:UniformT');

% Parse name-value pairs. Default values for n-v pairs. Default band uses a
% small offset from nyquist because fir1 will error for Wn = 1.
defaultBand = [fs/4 3/8*fs];
defaultMethod = 'demod';
defaultFilterOrder = 50;
if isInMATLAB
    p = inputParser;
    p.addParameter('Band',defaultBand);
    p.addParameter('Method',defaultMethod);
    p.addParameter('FilterOrder',defaultFilterOrder);
    
    parse(p,varargin{ivarargin:end});
    ba = p.Results.Band;
    em = p.Results.Method;
    fo = p.Results.FilterOrder;
else
    parms = struct('Band',uint32(0), ...
        'Method',uint32(0),...
        'FilterOrder',uint32(0));
    pstruct = eml_parse_parameter_inputs(parms,[],varargin{ivarargin:end});
    ba = eml_get_parameter_value(pstruct.Band,defaultBand,varargin{ivarargin:end});
    em = eml_get_parameter_value(pstruct.Method,defaultMethod,varargin{ivarargin:end});
    fo = eml_get_parameter_value(pstruct.FilterOrder,defaultFilterOrder,varargin{ivarargin:end});
end

% Validate string n-v pair inputs.
em = validatestring(em,{'hilbert','demod'},'envspectrum','Method');

% Validate numeric n-v pair inputs.
validateattributes(ba,{'single','double'},{'real','finite','nonsparse',...
    'vector','nonnegative','numel',2,'<',fs/2, 'increasing'},'envspectrum','Band');
validateattributes(fo,{'single','double'},{'real','finite','nonsparse',...
    'scalar','positive','integer'},'envspectrum','FilterOrder');

if ~isInMATLAB
    ba = coder.const(ba);
    fs = coder.const(fs);
    bw = coder.const(ba(2)-ba(1));
else
    bw = ba(2)-ba(1);
end

% Design filter
if strcmp(em,'hilbert')
    b = fir1(fo,[ba(1) ba(2)]/(fs/2));
else
    b = fir1(fo,bw/2/(fs/2));
end

end
%--------------------------------------------------------------------------
function localPlot(xEnv,fs,t,td,fSpec,xSpec)
% Plot envelope and envelope spectrum in the current figure.
newplot;
tEnv = (0:length(xEnv)-1)'/fs;
p1 = subplot(2,1,1);
if isempty(td)
    [~,E,U]=engunits(t,'unicode','time');
    plot(tEnv*E,xEnv);
    xlabel([getString(message('signal:envspectrum:Time')) ' (' U ')']);
else
    plot(td,xEnv);
    xlabel(getString(message('signal:envspectrum:Time')));
end
ylabel(getString(message('signal:envspectrum:Amplitude')))
title(getString(message('signal:envspectrum:EnvelopeSignal')))
p2 = subplot(2,1,2);
[~,E,U]=engunits(fSpec,'unicode');
plot(fSpec*E,xSpec);
xlabel([getString(message('signal:envspectrum:Frequency'))...
    ' (' U getString(message('signal:envspectrum:Hz')) ')'])
ylabel(getString(message('signal:envspectrum:PeakAmplitude')))
title(getString(message('signal:envspectrum:EnvelopeSpectrum')))

% Resize the plots, make the time series plot smaller.
p1p = get(p1,'position');
p1p(2) = p1p(2)+p1p(4)/2;
p1p(4) = p1p(4)/2;
set(p1,'position',p1p)
p1p = get(p1,'position');
p2p = get(p2,'position');
p2p(4) = 0.75*(p1p(2)-p2p(2));
set(p2,'position',p2p)

% Make the time series plot tight in x and give a margin in y
axis(p1,'tight');
yl = signal.internal.nvh.plotLimits(get(p1,'ylim'));
set(p1,'ylim',yl);
axis(p2,'tight');
yl = signal.internal.nvh.plotLimits(get(p2,'ylim'));
set(p2,'ylim',yl);

% Create tags
p1.Tag = 'Env';
p2.Tag = 'Spec';

% Set NextPlot to replace to clobber next time a plot command is issued.
set(p2.Parent,'NextPlot','replace');
end

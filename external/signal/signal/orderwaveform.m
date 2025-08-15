function xrec = orderwaveform(x,fs,rpm,orderlist,varargin)
%ORDERWAVEFORM Extract time-domain order waveforms from a vibration signal
%   XREC = ORDERWAVEFORM(X,Fs,RPM,ORDERLIST) reconstructs a matrix of
%   time-domain waveforms, XREC, from an input signal vector, X, for the
%   orders specified in an order vector, ORDERLIST, using the Vold-Kalman
%   filter. The input signal, X, has a sampling frequency, Fs, and a
%   corresponding rotational speed matrix, RPM, of the same length as X.
%   RPM has a number of elements equal to the length of X. ORDERLIST is a
%   vector of positive numbers, one for each waveform to be extracted. XREC
%   contains a reconstructed order waveform in each column. Orders in
%   ORDERLIST must be less than the maximum allowed order,
%   Fs/(2*max(RPM/60)).
%
%   XREC = ORDERWAVEFORM(X,Fs,RPM,ORDERLIST,RPMREFIDX) extracts time-domain
%   waveforms with multiple reference RPM signals. RPM is a matrix that
%   contains one RPM vector in each column. RPMREFIDX is a vector that
%   relates each order in ORDERLIST to an rpm signal. RPMREFIDX contains
%   one column index of the matrix RPM for each order in the
%   corresponding location in ORDERLIST.
%
%   XREC = ORDERWAVEFORM(X,Fs,RPM,ORDERLIST,...,'Bandwidth',BW) extracts
%   time-domain waveforms using a Vold-Kalman filter with approximate
%   half-power bandwidths, BW, in hertz. BW is either a scalar or a vector
%   with the same number of elements as ORDERLIST. Smaller bandwidth values
%   produce smooth, narrowband outputs, but are less accurate when order
%   amplitudes change rapidly. If BW is not specified, it defaults to 1% of
%   the sampling frequency.
%
%   XREC = ORDERWAVEFORM(X,Fs,RPM,ORDERLIST,...,'FilterOrder',FO) extracts
%   time-domain waveforms using a Vold-Kalman filter with filter order
%   specified by FO. FO can be 1 or 2. If FO is not specified, it defaults
%   to 1.
%
%   XREC = ORDERWAVEFORM(X,Fs,RPM,ORDERLIST,...,'Decouple',DC) extracts
%   order waveforms simultaneously when DC is TRUE or individually when DC
%   is FALSE. Order waveforms extracted simultaneously can separate
%   closely spaced or crossing orders and take longer to compute. If DC is
%   not specified, it defaults to FALSE.
%
%   XREC = ORDERWAVEFORM(X,Fs,RPM,ORDERLIST,...,'SegmentLength',SL) divides
%   the input signal into overlapping segments of length SL to reduce
%   memory requirements and computation time. This option is recommended
%   for large input signals. When a segment length, SL, is provided,
%   ORDERWAVEFORM computes the reconstructed waveform for each segment and
%   combines the segments to produce the output. If segments are too short,
%   localized events such as crossing orders may not be properly captured.
%   If SL is not specified, the entire input signal is processed in one
%   step.
%
%   % EXAMPLE 1:
%   %   Extract and plot order waveforms from vibration data.
%   load('helidata.mat')
%   vib = vib - mean(vib);
%   xrec = orderwaveform(vib,fs,rpm,[0.052 0.066 0.264]);
%
%   % Plot the extracted order waveforms and compare their sum to the
%   % original vibration signal.
%   subplot(2,1,1)
%   plot(t,xrec)
%   grid, xlim([4 5])
%   xlabel('Time (s)'), ylabel('Amplitude')
%   legend('Order 0.052','Order 0.066','Order 0.264')
%   title('Waveform Extraction of Top 3 Orders')
%   subplot(2,1,2)
%   plot(t,vib,t,sum(xrec,2))
%   grid, xlim([4 5])
%   xlabel('Time (s)'), ylabel('Amplitude')
%   legend('Vibration signal','Sum of 3 waveforms')
%
%   % EXAMPLE 2:
%   %   Reconstruct a chirp signal waveform sampled at 600 Hz.
%   Fs = 600;
%   t = (0:1/Fs:5)';
%
%   % RPM profile
%   f0 = 10; % order 1 instantaneous frequency at 0 seconds
%   f1 = 40; % order 1 instantaneous frequency at 5 seconds
%   rpm = 60*linspace(f0,f1,length(t))';
%
%   % Generate a signal containing 4 chirps that are harmonically related.
%   phase = 2*pi*cumsum(rpm/60/Fs);
%   x = sum(sin([phase, 0.5*phase, 4*phase, 6*phase]),2);
%
%   % Compute the order waveform.
%   xrec = orderwaveform(x,Fs,rpm,4);
%
%   % Plot the difference between the reconstructed and true order
%   % waveforms.
%   figure
%   plot(t,xrec-sin(4*phase))
%   xlabel('Time (s)')
%   ylabel('Order Amplitude Difference')
%
%   % EXAMPLE 3:
%   %   Reconstruct a long chirp signal waveform by segments.
%   Fs = 600; % signal sample rate
%   t = (0:1/Fs:200)';
%
%   % RPM profile
%   f0 = 10; % order 1 instantaneous frequency at 0 seconds
%   f1 = 40; % order 1 instantaneous frequency at 5 seconds
%   rpm = 60*linspace(f0,f1,length(t))';
%
%   % Generate a signal containing 4 chirps that are harmonically related.
%   phase = 2*pi*cumsum(rpm/60/Fs);
%   x = sum(sin([phase, 0.5*phase, 4*phase, 6*phase]),2);
%
%   % Compute the order waveform in segments to reduce
%   % computation time. ORDERWAVEFORM combines the segments into a single
%   % output waveform.
%   xrec = orderwaveform(x,Fs,rpm,4,'SegmentLength',1001);
%
%   % Plot the difference between the reconstructed and true order
%   % waveforms.
%   figure
%   plot(t,xrec-sin(4*phase))
%   xlabel('Time (s)')
%   ylabel('Order Amplitude Difference')
%
%   See also RPMORDERMAP, ORDERTRACK, ORDERSPECTRUM, TACHORPM

%   References:
%     [1] Feldbauer, C., and Holdrich, R. Realization of a Vold-Kalman
%         Tracking Filter - A Least-Squares Problem. Proceedings of the
%         COST G-6 Conference on Digital Audio Effects, Verona, Italy,
%         December 7-9, 2000.

% Copyright 2015-2020 The MathWorks, Inc.
%#codegen

narginchk(4,13);
nargoutchk(0,1);

if nargin > 4
    inputArgs = cell(1,length(varargin));
    [inputArgs{:}] = convertStringsToChars(varargin{:});
else
    inputArgs = varargin;
end

% Parse and validate inputs
[bw,sl,refidx,dc,fo] = parseinputs(x,fs,rpm,orderlist,inputArgs{:});
validateInputs(x,fs,rpm,orderlist,bw,sl,refidx,dc,fo);

% Cast to enforce precision rules (we already checked that the inputs are
% numeric.)
rpmCol = double(signal.internal.toColIfVect(rpm));
fsDouble = double(fs(1));
orderlistCol = double(orderlist(:));
bwCol = double(bw(:));

xCol = x(:);
refidxCol = refidx(:);

% Allocate and assign an array of frequency tracks based on the rpm signal
numOrd = length(orderlistCol);
xrec = coder.nullcopy(zeros(length(xCol),numOrd,class(xCol)));

% Compute frequency track matrix
F = coder.nullcopy(zeros(size(rpmCol,1),numOrd));
for i = 1:numOrd
    F(:,i) = orderlistCol(i)*rpmCol(:,refidxCol(i))/60;
end

% Call the Vold-Kalman filter to extract the waveform
% Convert bandwidth to weighting ([1] eq 31,32)
if fo == 1
    r = ((1.58*fsDouble)./(bwCol*2*pi)).^2;
else
    r = ((1.7*fsDouble)./(bwCol*2*pi)).^3;
end

% Call the Vold-Kalman filter on coupled orders
if dc
    % Call the Vold-Kalman filter on coupled orders
    xrec = signal.internal.vk(xCol,fsDouble,F,r,fo,sl);
else
    % Call the Vold-Kalman filter on uncoupled orders, one by one
    for i = 1:numOrd
        xrec(:,i) = signal.internal.vk(xCol,fsDouble,F(:,i),...
            r(i),fo,sl);
    end
end

end
%--------------------------------------------------------------------------
function [bw,sl,refidx,dc,fo] = parseinputs(x,fs,rpm,orderlist,varargin)

if nargin > 4 && ~ischar(varargin{1})
    refidx = varargin{1};
    args = {varargin{2:end}};
else
    refidx = ones(size(orderlist));
    % Check that rpm is a vector, since refidx was not provided
    coder.internal.assert(isvector(rpm),'signal:rpmmap:MustbeVectorRPMREFIDX');
    args = varargin;
end

% Default values
defaultBw = 0.01*fs;
defaultSl = length(x);
defaultDc = false;
defaultFo = 1;

% Check that name-value inputs come in pairs and are all strings
coder.internal.assert(~isodd(numel(args)),'signal:rpmmap:NVMustBeEven');

% Parse Name-value pairs
if coder.target('MATLAB')
    p = inputParser;
    p.addParameter('Bandwidth',defaultBw);
    p.addParameter('SegmentLength',defaultSl);
    p.addParameter('Decouple',defaultDc);
    p.addParameter('FilterOrder',defaultFo);
    parse(p,args{:});
    bwOut = p.Results.Bandwidth;
    slOut = p.Results.SegmentLength;
    dcOut = p.Results.Decouple;
    foOut = p.Results.FilterOrder;
else
    params = struct('Bandwidth',uint32(0), ...
        'SegmentLength',uint32(0), ...
        'Decouple',uint32(0), ...
        'FilterOrder',uint32(0));
    poptions = struct('CaseSensitivity',false, ...
        'PartialMatching',true, ...
        'StructExpand',true);
    pstruct = coder.internal.parseParameterInputs(params,poptions,args{:});
    bwOut = coder.internal.getParameterValue(pstruct.Bandwidth,defaultBw,args{:});
    slOut = coder.internal.getParameterValue(pstruct.SegmentLength,defaultSl,args{:});
    dcOut = coder.internal.getParameterValue(pstruct.Decouple,defaultDc,args{:});
    foOut = coder.internal.getParameterValue(pstruct.FilterOrder,defaultFo,args{:});
end

% If bw is a scalar, turn it into a vector
if isscalar(bwOut) && length(orderlist)>1
    bw = bwOut(1)*ones(length(orderlist),1);
else
    bw = bwOut;
end

% Cast dc to logical if it is numeric
if isnumeric(dcOut)
    dc = logical(dcOut);
else
    dc = dcOut;
end

sl = slOut;
fo = foOut;

end
%--------------------------------------------------------------------------
function validateInputs(x,fs,rpm,orderlist,bw,sl,refidx,dc,fo)
validateattributes(x,{'single','double'},...
    {'real','nonsparse','nonnan','finite','vector'},'orderwaveform','X');
validateattributes(fs,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','scalar'},'orderwaveform','Fs');
validateattributes(rpm,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','nonempty'},'orderwaveform','RPM');
validateattributes(orderlist,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','vector'},'orderwaveform','ORDERLIST');
validateattributes(bw,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','vector'},'orderwaveform','BW');
validateattributes(sl,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','integer','scalar',...
    '<=',length(x),'>=',16},'orderwaveform','SL');
if isvector(rpm)
    nrpm=1;
    Omax = fs(1)./(2*max(rpm(:))/60)';
else
    nrpm = size(rpm,2);
    Omax = fs(1)./(2*max(rpm,[],1)/60)';
end
validateattributes(refidx,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','integer','vector',...
    'numel',length(orderlist),'<=',nrpm},'orderwaveform','REFIDX');
validateattributes(dc,{'numeric','logical'},...
    {'nonsparse','scalar'},'orderwaveform','DC');
validateattributes(fo,{'numeric'},...
    {'real','positive','nonsparse','nonnan','finite','integer','<=',2,'scalar'},'orderwaveform','FO');

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
            badOrderString = [badOrderString sprintf('% .3f',invalidOrders(i))];
        end
        coder.internal.error('signal:rpmmap:OrderlistExceedMaxOrder',badOrderString)
        
    end
end

% Make sure rpm is either a vector with the same length as x or a matrix
% with the same number of rows as the length of x
coder.internal.assert(isvector(rpm) && length(rpm)==length(x) ...
    || size(rpm,1) == length(x), 'signal:rpmmap:RPMMustBeVectorMatrix');

end
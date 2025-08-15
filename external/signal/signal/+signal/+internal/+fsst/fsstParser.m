function [Fs,Ts,win,fNorm,freqloc] = fsstParser(x,varargin)
%FSSTPARSER Parse and validate FSST inputs
% This function is for internal use only. It may be removed.

%   Copyright 2020 The MathWorks, Inc.
%#codegen

% Set defaults
fsValue = false;
Ts = [];
win = kaiser(min(256,length(x)),10);
fNorm = false;
freqloc = '';

isInMATLABorMEX = coder.target('MATLAB') || coder.target('MEX');

% Parse optional inputs
if nargin > 1
    if isduration(varargin{1})
        if isempty(varargin{1})
            % Throw error is empty duration object is supplied
            error(message('signal:fsst:EmptyDuration'));
        else
            coder.internal.assert(coder.target('MATLAB'),'signal:fsst:CodegenDurationUnsupported');
            Ts = varargin{1};
            Fs = 1/seconds(Ts);
            fsValue = true;
        end
    elseif ischar(varargin{1})
        % Freqloc input is supported only for MATLAB and MEX targets
        coder.internal.assert(isInMATLABorMEX,'signal:fsst:FreqlocNotSupported');
        
        freqloc = validatestring(varargin{1},{'xaxis','yaxis'},'fsst');
        Fs = [];
        fsValue = false;
    else
        Fs = varargin{1};
        % Ensure parameter Fs is double.
        Fs = double(Fs);
        if ~isempty(varargin{1})
            fsValue = true;
        else
            fsValue = false;
        end
    end
end

if (~fsValue && isempty(Ts))
    fNorm = true;
    Fs = 2*pi;
end

if nargin > 2
    if ischar(varargin{2})
        % Freqloc input is supported only for MATLAB and MEX targets
        coder.internal.assert(isInMATLABorMEX,'signal:fsst:FreqlocNotSupported');
        
        freqloc = validatestring(varargin{2},{'xaxis','yaxis'},'fsst');
    elseif ~isempty(varargin{2})
        if isscalar(varargin{2})
            validateattributes(varargin{2},{'numeric'},{'positive'},'fsst','WINDOW');
            win = kaiser(double(varargin{2}),10);
        else
            coder.internal.errorIf(~coder.target('MATLAB') && isa(varargin{2},'single'),'signal:fsst:WinVecNotSupported');
            win = varargin{2};
        end
    end
end

if nargin > 3
    % Freqloc input is supported only for MATLAB and MEX targets
    coder.internal.assert(isInMATLABorMEX,'signal:fsst:FreqlocNotSupported');
    
    freqloc = validatestring(varargin{3},{'xaxis','yaxis'},'fsst');
end

validateInputs(x,Fs,Ts,win);
end

%--------------------------------------------------------------------------
function validateInputs(x,Fs,Ts,win)

validateattributes(x,{'single','double'},...
    {'nonsparse','finite','nonnan','vector'},'fsst','X');
% Fs has been already cast to double for precision rules.
validateattributes(Fs,{'double'},...
    {'real','positive','finite','nonnan','scalar'},'fsst','Fs');
validateattributes(win,{'single','double'},...
    {'real','finite','nonnegative','nonnan','vector'},'fsst','WINDOW');

if ~isempty(Ts)
    dt = signal.internal.fsst.getFSSTDurationAndUnits(Ts);
    validateattributes(dt,{'numeric'},...
        {'real','positive','finite','nonnan','scalar'},'fsst','Ts');
end

% Check X has at least 2 samples
coder.internal.errorIf(length(x) < 2, 'signal:fsst:MustBeMinLengthX');

% Check WINDOW has at least 2 samples
if length(win) < 2
    coder.internal.error('signal:fsst:MustBeMinLengthWin');
end

% Check window length is not more than the length of the input signal.
if length(win) > length(x)
    coder.internal.error('signal:fsst:WinLength');
end
end

% LocalWords:  FSST fsst Freqloc xaxis yaxis Fs Vec nonsparse

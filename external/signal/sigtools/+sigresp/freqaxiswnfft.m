classdef (Abstract) freqaxiswnfft < sigresp.freqaxiswfreqrange
  %sigresp.freqaxiswnfft class
  %   sigresp.freqaxiswnfft extends sigresp.freqaxiswfreqrange.
  %
  %    sigresp.freqaxiswnfft properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %       FrequencyScale - Property is of type 'string'
  %       NormalizedFrequency - Property is of type 'string'
  %       FrequencyRange - Property is of type 'string'
  %       NumberOfPoints - Property is of type 'double'
  %
  %    sigresp.freqaxiswnfft methods:
  %       createnfftprm - Create an nfft parameter object.
  %       freqaxis_getoptions - Get the input options for the analysis functions
  %       freqaxiswnfft_getfreqrangeopts -    Get the frequency range based on the
  %       getfreqrangeopts -   Get the frequency range options.
  %       getnffttag - Return string/tag for the nfft object.
  %       getoptions - Returns the input arguments to the analysis methods.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %NUMBEROFPOINTS Property is of type 'double'
    NumberOfPoints
  end
  
  
  methods
    function value = get.NumberOfPoints(obj)
      value = getnfft(obj,obj.NumberOfPoints);
    end
    function set.NumberOfPoints(obj,value)
      % DataType = 'double'
      validateattributes(value,{'double'}, {'scalar'},'','NumberOfPoints')
      obj.NumberOfPoints = setnfft(obj,value);
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function createnfftprm(hObj, allPrm)
      % CREATENFFTPRM Create an nfft parameter object.

      createparameter(hObj, allPrm, 'Number of Points', getnffttag(hObj), [2 1 2^31-1], 8192);
      
    end
    
    
    function [opts, xunits] = freqaxis_getoptions(this)
      %FREQAXIS_GETOPTIONS Get the input options for the analysis functions

      fs = getmaxfs(this);
      
      nfft = get(this, 'NumberOfPoints');
      if strcmpi(this.FastUpdate, 'On')
        nfft = min(nfft, 128);
      end
      
      hDlg = getcomponent(this, '-class', 'siggui.parameterdlg');
      
      if isempty(hDlg)
        opts = {};
      else
        opts.nfft = getvaluesfromgui(hDlg, getnffttag(this));
        opts = {opts};
      end
      
      rangeopts = lower(getfreqrangeopts(this, opts{:}));
      
      switch lower(get(this, 'FrequencyRange'))
        case rangeopts{1}
          opts = {nfft, 'half'};
        case rangeopts{2}
          opts = {nfft, 'whole'};
        case rangeopts{3}
          opts = {nfft, 'fftshift'};
      end
      
      if ~isempty(fs)
        [fs, m, xunits] = engunits(fs);
        xunits = sprintf('%sHz', xunits);
      else
        xunits = 'rad/sample';
      end
      
      
    end
    
    
    function rangeopts = freqaxiswnfft_getfreqrangeopts(this, opts)
      %FREQAXISWNFFT_GETFREQRANGEOPTS    Get the frequency range based on the
      %input values.

      if nargin < 2
        normalizedstatus = this.NormalizedFrequency;
        nfft = lclgetnfft(this);
      else
        if isfield(opts,'normalizedstatus')
          normalizedstatus = opts.normalizedstatus;
        else
          normalizedstatus = this.NormalizedFrequency;
        end
        if isfield(opts,'nfft')
          nfft = opts.nfft;
        else
          nfft = lclgetnfft(this);
        end
      end
      
      minPt = '[';  % Even case, include nyquist point.
      if rem(nfft,2)
        minPt = '(';  % Odd case, don't include nyquist point.
      end
      
      if strcmpi(normalizedstatus, 'on')
        rangeopts = {'[0, pi)', '[0, 2pi)', sprintf('%c-pi, pi)', minPt)};
      else
        rangeopts = {'[0, Fs/2)', '[0, Fs)', sprintf('%c-Fs/2, Fs/2)', minPt)};
      end
      
    end
    
    
    function rangeopts = getfreqrangeopts(varargin)
      %GETFREQRANGEOPTS   Get the frequency range options.

      rangeopts = freqaxiswnfft_getfreqrangeopts(varargin{:});
      
      
    end
    
    
    function tag = getnffttag(hObj)
      % GETNFFTTAG Return string/tag for the nfft object.

      tag = 'nfft';
      
    end
    
    
    function [opts, xunits] = getoptions(hObj)
      %GETOPTIONS Returns the input arguments to the analysis methods.

      [opts, xunits] = freqaxis_getoptions(hObj);
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function allPrm = freqaxiswnfft_construct(this, varargin)
      %FREQAXISWNFFT_CONSTRUCT

      allPrm = this.freqaxiswfreqrange_construct(varargin{:});
      
      createnfftprm(this, allPrm);
      
      hPrm = getparameter(this, getnffttag(this));
      l = [ ...
        handle.listener(hPrm, 'NewValue', @lclnfft_listener); ...
        handle.listener(hPrm, 'UserModified', @lclnfft_listener); ...
        ];
      set(l, 'CallbackTarget', this);
      set(this, 'Listeners', union(l, this.Listeners));
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function out = setnfft(hObj, out)
%SETNFFT Set function for the NumberOfPoints property.

hPrm = getparameter(hObj, getnffttag(hObj));
if ~isempty(hPrm), setvalue(hPrm, out); end
end  % setnfft


% ---------------------------------------------------------------------
function out = getnfft(hObj, out)
%GETNFFT Return the NFFT value.

hPrm = getparameter(hObj, getnffttag(hObj));
out = get(hPrm, 'Value');
end  % getnfft



% -------------------------------------------------------------------------
function lclnfft_listener(this, eventData)

hPrm = getparameter(this, getnffttag(this));

opts.nfft = getsettings(hPrm, eventData);

% Ignore the inf/nan case.  We'll handle ti later.
if opts.nfft == inf || isnan(opts.nfft)
  return;
end

setvalidvalues(getparameter(this, getfreqrangetag(this)), ...
  getfreqrangeopts(this, opts));

end


%--------------------------------------------------------------------------
function nfft = lclgetnfft(this)

if isempty(getparameter(this,getnffttag(this)))
  nfft = 512;
else
  nfft = this.NumberOfPoints;
end

end


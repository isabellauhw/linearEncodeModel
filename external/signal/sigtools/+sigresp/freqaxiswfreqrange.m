classdef (Abstract) freqaxiswfreqrange < sigresp.freqaxis
  %sigresp.freqaxiswfreqrange class
  %   sigresp.freqaxiswfreqrange extends sigresp.freqaxis.
  %
  %    sigresp.freqaxiswfreqrange properties:
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
  %
  %    sigresp.freqaxiswfreqrange methods:
  %       freqaxiswfreqrange_construct - Constructor for the freqaxiswfreqrange class.
  %       freqaxiswfreqrange_getxaxisparams - FREQAXIS_GETXAXISPARAMS Differentiates freq. axis from time axis.
  %       freqmode_listener -   Listener for the freqmode parameter (Frequency Units).
  %       getfreqrangeopts -   Return the frequency range options.
  %       getfreqrangetag - Return the string/tag for the frequency range w/ or w/out
  %       getxaxisparams - Get the parameters that are relevant to the axis.
  %       getxparams -   Returns the param tags that force an x unzoom.
  %       unitcircle_listener - Listener for the unitcircle parameter.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %FREQUENCYRANGE Property is of type 'string'
    FrequencyRange = '';
  end
  
  
  methods
    function value = get.FrequencyRange(obj)
      value = getfreqrange(obj,obj.FrequencyRange);
    end
    function set.FrequencyRange(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','FrequencyRange')
      obj.FrequencyRange = setfreqrange(obj,value);
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function allPrm = freqaxiswfreqrange_construct(this,varargin)
      %FREQAXISWFREQRANGE_CONSTRUCT Constructor for the freqaxiswfreqrange class.

      allPrm = this.freqaxis_construct(varargin{:});
      
      % Create parameters for the frequency response object.
      createparameter(this, allPrm, 'Frequency Range',getfreqrangetag(this), ...
        getfreqrangeopts(this));
      
      hPrm = getparameter(this, getfreqrangetag(this));
      l = [ ...
        handle.listener(hPrm, 'NewValue', @unitcircle_listener); ...
        handle.listener(hPrm, 'UserModified', @unitcircle_listener); ...
        ];
      set(l, 'CallbackTarget', this);
      set(this, 'Listeners', [this.Listeners; l]);
      
      freqmode_listener(this, []);
      unitcircle_listener(this, []);
      
    end
    
    
    function hPrm = freqaxis_getxaxisparams(hObj)
      %FREQAXIS_GETXAXISPARAMS Differentiates freq. axis from time axis.

      hPrm = get(hObj, 'Parameters');
      
      hPrm = find(hPrm, 'tag', getfreqrangetag(hObj),'-or', ...
        'tag', getnffttag(hObj), '-or', ...
        'tag', 'freqmode', '-or', ...
        'tag', 'freqscale');
      
    end
    
    
    function freqmode_listener(this, eventData)
      %FREQMODE_LISTENER   Listener for the freqmode parameter (Frequency Units).

      freqaxis_freqmode_listener(this, eventData);
      
      hPrm = getparameter(this, getfreqrangetag(this));
      
      if ~isempty(hPrm)
        
        opts.normalizedstatus = getsettings(getparameter(this, 'freqmode'), eventData);
        
        rangeopts = getfreqrangeopts(this,opts);
        
        setvalidvalues(hPrm, rangeopts);
      end
      
    end
    
    
    function rangeopts = getfreqrangeopts(this, opts)
      %GETFREQRANGEOPTS   Return the frequency range options.

      if nargin < 2
        normalizedstatus = this.NormalizedFrequency;
      else
        normalizedstatus = opts.normalizedstatus;
      end
      
      % Note that the starting point for the -pi-pi range is hardcoded to be
      % inclusive, however this should depend on NFFT. NFFT is only available in
      % subclasses, freqaxiswnfft.
      if strcmpi(normalizedstatus, 'on')
        rangeopts = {'[0, pi)', '[0, 2pi)', '[-pi, pi)'};
      else
        rangeopts = {'[0, Fs/2)', '[0, Fs)', '[-Fs/2, Fs/2)'};
      end
      
      
    end
    
    
    function tag = getfreqrangetag(hObj)
      % GETFREQRANGETAG Return the string/tag for the frequency range w/ or w/out
      % frequency vector.

      tag = 'unitcirclewnofreqvec';
      
    end
    
    
    function hPrm = getxaxisparams(hObj)
      %GETXAXISPARAMS Get the parameters that are relevant to the axis.

      % Call "super" getxaxisparams.
      hPrm = freqaxis_getxaxisparams(hObj);
            
    end
        
    function xparams = getxparams(this)
      %GETXPARAMS   Returns the param tags that force an x unzoom.

      xparams = {'freqmode', getfreqrangetag(this)};
      
    end
    
    
    function unitcircle_listener(this, eventData)
      %UNITCIRCLE_LISTENER Listener for the unitcircle parameter.

      rangeopts = getfreqrangeopts(this);
      
      switch getsettings(getparameter(this, getfreqrangetag(this)), eventData)
        case rangeopts{3}
          disableparameter(this, 'freqscale');
        otherwise
          enableparameter(this, 'freqscale');
      end
      
    end
        
  end  %% public methods
  
end  % classdef

function out = getfreqrange(hObj, out)
%GETFREQRANGE Get the frequency range

hPrm = getparameter(hObj, getfreqrangetag(hObj));
out = get(hPrm, 'Value');
end  % getfreqrange


% ---------------------------------------------------------------------
function out = setfreqrange(hObj, out)
%SETFREQRANGE Set the frequency range.

hPrm = getparameter(hObj, getfreqrangetag(hObj));
if ~isempty(hPrm), setvalue(hPrm, out); end
end  % setfreqrange


% ---------------------------------------------------------------------------
function checkfreqvec(freqvec)

if any(freqvec < 0)
  error(message('signal:sigresp:freqaxiswfreqrange:freqaxiswfreqrange_construct:MustBePositive'));
end

end

% [EOF]


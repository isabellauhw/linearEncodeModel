classdef freqaxiswfreqvec < sigresp.freqaxiswnfft
  %sigresp.freqaxiswfreqvec class
  %   sigresp.freqaxiswfreqvec extends sigresp.freqaxiswnfft.
  %
  %    sigresp.freqaxiswfreqvec properties:
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
  %       FrequencyVector - Property is of type 'double_vector user-defined'
  %
  %    sigresp.freqaxiswfreqvec methods:
  %       freqaxiswfreqvec_construct - Check the inputs
  %       freqaxiswfreqvec_getoptions - Get the input options for the analysis functions
  %       getfreqrangeopts -   Return the frequency range options.
  %       getfreqrangetag - Return the string/tag for the frequency range w/ or w/out
  %       getoptions - Gets the options for the analysis.
  %       getxaxisparams - Get the axis parameters for each analysis.
  %       getxparams -   Returns the param tags that force an x unzoom.
  %       unitcircle_listener - Listener for the unitcircle parameter

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %FREQUENCYVECTOR Property is of type 'double_vector user-defined'
    FrequencyVector = [];
  end
  
  
  methods  % constructor block
    function hObj = freqaxiswfreqvec(varargin)
      %FREQAXIS Check the inputs
      
    end  % freqaxiswfreqvec
    
  end  % constructor block
  
  methods
    function value = get.FrequencyVector(obj)
      value = getfreqvec(obj,obj.FrequencyVector);
    end
    function set.FrequencyVector(obj,value)
      % User-defined DataType = 'double_vector user-defined'
      obj.FrequencyVector = setfreqvec(obj,value);
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function allPrm = freqaxiswfreqvec_construct(hObj,varargin)
      %FREQAXISWFREQVEC_CONSTRUCT Check the inputs

      allPrm = hObj.freqaxiswnfft_construct(varargin{:});
      
      % Create parameters for the frequency axis w/ freq. vector object.
      createparameter(hObj, allPrm, 'Frequency Vector', 'freqvec', @checkfreqvec, linspace(0, 1, 256));
      
    end
    
    function [opts, xunits] = freqaxiswfreqvec_getoptions(this)
      %FREQAXISWFREQVEC_GETOPTIONS Get the input options for the analysis functions
      %which allows specifying a frequency vector.

      fs = getmaxfs(this);
      
      % Only do this if using a response that allows you to specify a freq vector.
      if strcmpi(get(this, 'FrequencyRange'),'specify freq. vector')
        
        if isempty(fs) || strcmpi(this.NormalizedFrequency, 'on')
          boolflag = true;
        else
          boolflag = false;
        end
        
        freqVec = get(this, 'FrequencyVector');
        freqVec = freqVec(:);
        if boolflag
          if ~isempty(fs)
            opts = {freqVec*fs/(2*pi)};
          else
            opts = {freqVec};
          end
        else
          opts = {freqVec};
        end
      else
        opts = freqaxis_getoptions(this);
      end
      
      if ~isempty(fs)
        [~, ~, xunits] = engunits(fs);
        xunits = sprintf('%sHz', xunits);
      else
        xunits = 'rad/sample';
      end
      
    end
    
    
    function rangeopts = getfreqrangeopts(varargin)
      %GETFREQRANGEOPTS   Return the frequency range options.

      rangeopts = freqaxiswnfft_getfreqrangeopts(varargin{:});
      
      % Append extra option specific to this class.
      rangeopts{end+1} = 'Specify freq. vector';
      
    end
    
    function tag = getfreqrangetag(hObj)
      % GETFREQRANGETAG Return the string/tag for the frequency range w/ or w/out
      % frequency vector.

      tag = 'unitcircle';
      
    end
    
    function [opts, xunits] = getoptions(hObj)
      %GETOPTIONS Gets the options for the analysis.

      [opts, xunits] = freqaxiswfreqvec_getoptions(hObj);
      
    end
    
    
    function hPrm = getxaxisparams(hObj)
      %GETXAXISPARAMS Get the axis parameters for each analysis.

      % Call "super" method to find the relevant parameters.
      hPrm = freqaxis_getxaxisparams(hObj);
      
      % Append the frequency vector parameter.
      hPrm = union(hPrm, getparameter(hObj, 'freqvec'));
      
      
      
    end
    
    function xparams = getxparams(this)
      %GETXPARAMS   Returns the param tags that force an x unzoom.

      xparams = {'freqmode', getfreqrangetag(this), 'freqvec'};
      
      
    end
    
    
    function unitcircle_listener(this, eventData)
      %UNITCIRCLE_LISTENER Listener for the unitcircle parameter

      rangeopts = getfreqrangeopts(this);
      
      switch getsettings(getparameter(this, getfreqrangetag(this)), eventData)
        case rangeopts{4}
          disableparameter(this, 'nfft');
          enableparameter(this, 'freqscale');
          enableparameter(this, 'freqvec');
        case rangeopts{3}
          enableparameter(this, 'nfft');
          disableparameter(this, 'freqscale');
          disableparameter(this, 'freqvec');
        otherwise
          enableparameter(this, 'nfft');
          enableparameter(this, 'freqscale');
          disableparameter(this, 'freqvec');
      end
      
    end
    
  end  %% public methods
  
end  % classdef

function out = setfreqvec(hObj, out)

hPrm = getparameter(hObj, 'freqvec');
if ~isempty(hPrm), setvalue(hPrm, out); end
end  % setfreqvec


% ---------------------------------------------------------------------
function out = getfreqvec(hObj, out)

hPrm = getparameter(hObj, 'freqvec');
out = get(hPrm, 'Value');
end  % getfreqvec

% ---------------------------------------------------------------------------
function checkfreqvec(freqvec)

if ~isnumeric(freqvec)
  error(message('signal:sigresp:freqaxiswfreqvec:freqaxiswfreqvec_construct:MustBeNumeric'));
end

end

function hPrm = freqaxis_getxaxisparams(hObj)
%FREQAXIS_GETXAXISPARAMS Differentiates freq. axis from time axis.

hPrm = hObj.Parameters;

hPrm = find(hPrm, 'tag', getfreqrangetag(hObj),'-or', ...
  'tag', getnffttag(hObj), '-or', ...
  'tag', 'freqmode', '-or', ...
  'tag', 'frequnits', '-or', ...
  'tag', 'freqscale');

end



% [EOF]

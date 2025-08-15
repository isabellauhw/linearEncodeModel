classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) masklineMCOS < hgsetget & matlab.mixin.Copyable
  %dspdata.maskline class
  %    dspdata.maskline properties:
  %       EnableMask - Property is of type 'bool'
  %       NormalizedFrequency - Property is of type 'bool'
  %       FrequencyVector - Property is of type 'double_vector user-defined'
  %       MagnitudeUnits - Property is of type 'MagnitudeUnitTypes enumeration: {'dB','Linear','Squared'}'
  %       MagnitudeVector - Property is of type 'mxArray'
  %
  %    dspdata.maskline methods:
  %       copy -   Copy this object.
  %       disp -   Display this object.
  %       draw -   Draw the mask lines.
  %       get_magnitudevector -   PreGet function for the 'magnitudevector' property.
  %       normalizefreq -   Normalize the frequency and the vector.
  %       set_magnitudevector -   PreSet function for the 'magnitudevector' property.
  %       validate -   Validate the object.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %ENABLEMASK Property is of type 'bool'
    EnableMask = false;
    %NORMALIZEDFREQUENCY Property is of type 'bool'
    NormalizedFrequency = true;
    %FREQUENCYVECTOR Property is of type 'double_vector user-defined'
    FrequencyVector = [ 0, .4, .5, 1 ];
    %MAGNITUDEUNITS Property is of type 'MagnitudeUnitTypes enumeration: {'dB','Linear','Squared'}'
    MagnitudeUnits = 'dB';
    %MAGNITUDEVECTOR Property is of type 'mxArray'
    MagnitudeVector = [];
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %PRIVMAGNITUDEVECTOR Property is of type 'double_vector user-defined'
    privMagnitudeVector = [ 1, 1, .01, .01 ];
  end
  
  
  methods  % constructor block
    function this = masklineMCOS(varargin)
      %MASKLINE   Construct a MASKLINE object.

      if nargin
        
        for ii = 1:2:length(varargin)
          % we call off to a public function, otherwise this would allow
          % users to set protected/private properties
          this.(varargin{ii}) =  varargin{ii+1};
        end
    
      end      
      
    end  % maskline
    
  end  % constructor block
  
  methods
    function set.EnableMask(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical','numeric'}, {'scalar'},'','EnableMask')
      obj.EnableMask = value;
    end
    
    function set.NormalizedFrequency(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical','numeric'}, {'scalar'},'','NormalizedFrequency')
      obj.NormalizedFrequency = value;
    end
    
    function set.FrequencyVector(obj,value)
      % User-defined DataType = 'double_vector user-defined'
      obj.FrequencyVector = value;
    end
    
    function set.MagnitudeUnits(obj,value)
      % Enumerated DataType = 'MagnitudeUnitTypes enumeration: {'dB','Linear','Squared'}'
      value = validatestring(value,{'dB','Linear','Squared'},'','MagnitudeUnits');
      obj.MagnitudeUnits = value;
    end
    
    function value = get.MagnitudeVector(obj)
      value = get_magnitudevector(obj,obj.MagnitudeVector);
    end
    
    function set.MagnitudeVector(obj,value)
      obj.MagnitudeVector = set_magnitudevector(obj,value);
    end
    
    function set.privMagnitudeVector(obj,value)
      % User-defined DataType = 'double_vector user-defined'
      obj.privMagnitudeVector = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function Hcopy = copyTheObj(this)
      %COPY   Copy this object.

      Hcopy = feval(class(this));
      
      Hcopy.EnableMask = this.EnableMask;
      Hcopy.NormalizedFrequency = this.NormalizedFrequency;
      Hcopy.FrequencyVector = this.FrequencyVector;
      Hcopy.MagnitudeUnits = this.MagnitudeUnits;
      Hcopy.privMagnitudeVector = this.privMagnitudeVector;
      
    end
    
    
    function disp(this)
      %DISP   Display this object.

      siguddutils('dispstr', this);
      
    end
    
    
    function varargout = draw(this, hax)
      %DRAW   Draw the mask lines.

      % We can only plot a validated object.
      validate(this);
      
      if nargin < 2
        hax = newplot;
      end
      
      h = line(this.FrequencyVector, this.MagnitudeVector, ...
        'Parent', hax, ...
        'Color',  'r', ...
        'LineStyle', '--',...
        'Tag',    'maskline');
      
      if nargout
        varargout = {h};
      end
      
    end
    
    function mv = get_magnitudevector(this, mv)
      %GET_MAGNITUDEVECTOR   PreGet function for the 'magnitudevector' property.

      mv = get(this, 'privMagnitudeVector');
      
      switch lower(this.MagnitudeUnits)
        case 'db'
          mv = db(mv);
        case 'linear'
          % NO OP.
        case 'squared'
          mv = mv.^2;
      end
      
    end
    
    function normalizefreq(this, newvalue, fs)
      %NORMALIZEFREQ   Normalize the frequency and the vector.

      narginchk(3,3);
      
      % If the new value == the old value return early.
      if newvalue == this.NormalizedFrequency
        return;
      end
      
      if newvalue
        % Going to normalized.
        this.FrequencyVector = this.FrequencyVector./(fs/2);
      else
        % Turning off normalized.
        this.FrequencyVector = this.FrequencyVector.*(fs/2);
      end
      
      this.NormalizedFrequency = newvalue;
      
    end
    
    
    function mv = set_magnitudevector(this, mv)
      %SET_MAGNITUDEVECTOR   PreSet function for the 'magnitudevector' property.

      switch lower(this.MagnitudeUnits)
        case 'linear'
          % NO OP.
        case 'db'
          mv = 10.^(mv./20);
        case 'squared'
          mv = sqrt(mv);          
      end
      
      this.privMagnitudeVector = mv;
      
      mv = [];
      
    end    
    
    function varargout = validate(this)
      %VALIDATE   Validate the object.
      
      b = length(this.FrequencyVector) == length(this.MagnitudeVector);
      
      if nargout
        varargout = {b};
      else
        if ~b
          error(message('signal:dspdata:maskline:validate:invalidateState', 'FrequencyVector', 'Magnitude'));        
        end
      end
      
    end
    
    function varargout = set(obj,varargin)      
      [varargout{1:nargout}] = signal.internal.signalset(obj,varargin{:});            
    end
    
    function values = getAllowedStringValues(~,prop)
      % This function gives the the valid string values for object properties.
      
      switch prop
        case 'MagnitudeUnits'
          values = {...
            'dB'
            'Linear'
            'Squared'};

        otherwise
          values = {};
      end
      
    end
    
  end  %% public methods
  
end  % classdef


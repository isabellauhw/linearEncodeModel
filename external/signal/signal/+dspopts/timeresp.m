classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) timeresp < dspopts.abstractoptionswfsMCOS
  %dspopts.timeresp class
  %   dspopts.timeresp extends dspopts.abstractoptionswfs.
  %
  %    dspopts.timeresp properties:
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray'
  %       LengthOption - Property is of type 'ImpulseLengthOptions enumeration: {'Default','Specified'}'
  %       Length - Property is of type 'mxArray'
  %
  %    dspopts.timeresp methods:
  %       disp -   Display this object.
  %       get_length -   PreGet function for the 'length' property.
  %       oldinputs -   Return the inputs for IMPZ and STEPZ.
  %       set_length -   PreSet function for the 'length' property.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %LENGTHOPTION Property is of type 'ImpulseLengthOptions enumeration: {'Default','Specified'}'
    LengthOption = 'Default';
    %LENGTH Property is of type 'mxArray'
    Length = [];
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %PRIVLENGTH Property is of type 'int32'
    privLength = 20;
  end
  
  
  methods  % constructor block
    function this = timeresp(varargin)
      %TIMERESP   Construct a TIMERESP object.
      [varargin{:}] = convertStringsToChars(varargin{:});
      if nargin
        set(this, varargin{:});
      end
      
      
    end  % timeresp
    
  end  % constructor block
  
  methods
    function set.LengthOption(obj,value)
      % Enumerated DataType = 'ImpulseLengthOptions enumeration: {'Default','Specified'}'
      value = validatestring(value,{'Default','Specified'},'','LengthOption');
      obj.LengthOption = value;
    end
    
    function value = get.Length(obj)
      value = get_length(obj,obj.Length);
    end
    function set.Length(obj,value)
      obj.Length = set_length(obj,value);
    end
    
    function set.privLength(obj,value)
      % DataType = 'int32'
      validateattributes(value,{'numeric'},{'scalar'},'','privLength')
      obj.privLength = double(int32(value));
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function disp(this)
      %DISP   Display this object.

      props = {'NormalizedFrequency'};
      
      if ~this.NormalizedFrequency
        props{end+1} = 'Fs';
      end
      
      props{end+1} = 'LengthOption';
      
      if strcmpi(this.LengthOption, 'Specified')
        props{end+1} = 'Length';
      end
      
      siguddutils('dispstr', this, props);
 
    end
    
    
    function le = get_length(this, le) %#ok
      %GET_LENGTH   PreGet function for the 'length' property.

      le = get(this, 'privLength');

    end
    
    
    function c = oldinputs(this)
      %OLDINPUTS   Return the inputs for IMPZ and STEPZ.

      if strcmpi(this.LengthOption, 'Specified')
        c = {this.Length};
      else
        c = {[]};
      end
      
      if ~this.NormalizedFrequency
        c = {c{:}, this.Fs};
      end

    end
    
    
    function le = set_length(this, le)
      %SET_LENGTH   PreSet function for the 'length' property.

      if le < 1
        error(message('signal:dspopts:timeresp:set_length:invalidLength'));
      end
      
      this.LengthOption = 'Specified';
      this.privLength = le;
      
      le = [];

    end
    
    function varargout = set(obj,varargin)
      [varargout{1:nargout}] = signal.internal.signalset(obj,varargin{:});
    end
    
    function values = getAllowedStringValues(~,prop)
      % This function gives the the valid string values for object properties.
      
      switch prop
        case 'LengthOption'
          values = {...
            'Default'
            'Specified'};
          
        otherwise
          values = {};
      end
      
    end
           
  end  %% public methods
  
end  % classdef


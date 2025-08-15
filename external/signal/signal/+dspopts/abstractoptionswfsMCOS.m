classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) abstractoptionswfsMCOS < sigio.dyproputil & hgsetget & matlab.mixin.Copyable
  %dspopts.abstractoptionswfs class
  %    dspopts.abstractoptionswfs properties:
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray'
  %
  %    dspopts.abstractoptionswfs methods:
  %       get_fs - GETFS   Pre-Get Function for the Fs property.
  %       set_fs - SETFS

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %NORMALIZEDFREQUENCY Property is of type 'bool'
    NormalizedFrequency = true;
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %PRIVFS Property is of type 'posdouble user-defined'
    privFs = 1;
  end
  
  properties (Transient, AbortSet, SetObservable, GetObservable)
    %FS Property is of type 'mxArray'
    Fs = [];
  end
  
  
  methods
    function set.NormalizedFrequency(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical'}, {'scalar'},'','NormalizedFrequency')
      obj.NormalizedFrequency = value;
    end
    
    function value = get.Fs(obj)
      value = get_fs(obj,obj.Fs);
    end
    function set.Fs(obj,value)
      obj.Fs = set_fs(obj,value);
    end
    
    function set.privFs(obj,value)
      % User-defined DataType = 'posdouble user-defined'
      obj.privFs = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function Fs = get_fs(h, Fs) %#ok
      %GETFS   Pre-Get Function for the Fs property.

      if h.NormalizedFrequency
        Fs = 'Normalized';
      else
        Fs = h.privFs;
      end

    end
        
    function Fs = set_fs(h,Fs)
      %SETFS

      h.privFs = Fs;
      
      % Unset NormalizedFrequency
      h.NormalizedFrequency = false;
      
      % Make Fs empty to not duplicate storage
      Fs = [];
      
    end
    
  end  %% public methods
  
end  % classdef


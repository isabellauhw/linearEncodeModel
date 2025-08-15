classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, Abstract) abstractspectrumMCOS < dspopts.abstractoptionswfsMCOS & sigio.dyproputil
  %dspopts.abstractspectrum class
  %   dspopts.abstractspectrum extends dspopts.abstractoptionswfs.
  %
  %    dspopts.abstractspectrum properties:
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray'
  %       CenterDC - Property is of type 'mxArray'
  %
  %    dspopts.abstractspectrum methods:
  %       get_centerdc -   PreGet function for the 'CenterDC' property.
  %       get_fs - GETFS   Pre-Get Function for the Fs property.
  %       ishalfnyqinterval -   Returns true if the object specifies half the nyquist.
  %       set_centerdc -   PreSet function for the 'CenterDC' property.
  %       set_fs - SETFS

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %PRIVCENTERDC Property is of type 'bool'
    privcenterdc = false;
  end
  
  properties (Transient, AbortSet, SetObservable, GetObservable)
    %CENTERDC Property is of type 'mxArray'
    CenterDC = [];
  end
  
  
  methods
    function value = get.CenterDC(obj)
      value = get_centerdc(obj,obj.CenterDC);
    end
    function set.CenterDC(obj,value)
      obj.CenterDC = set_centerdc(obj,value);
    end
    
    function set.privcenterdc(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical'}, {'scalar'},'','privcenterdc')
      obj.privcenterdc = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function centerdc = get_centerdc(this, centerdc) %#ok
      %GET_CENTERDC   PreGet function for the 'CenterDC' property.

      if ishalfnyqinterval(this)
        centerdc = false;
      else
        centerdc = this.privcenterdc;
      end
      
    end
        
    function Fs = get_fs(h, Fs) %#ok
      %GETFS   Pre-Get Function for the Fs property.

      if h.NormalizedFrequency
        Fs = 'Normalized';
      else
        Fs = h.privFs;
      end
      
    end
    
    function flag = ishalfnyqinterval(this) %#ok
      %ISHALFNYQINTERVAL   Returns true if the object specifies half the nyquist.

      error(message('signal:dspopts:abstractspectrum:ishalfnyqinterval:abstractMethod'));
      
    end
        
    function centerdc = set_centerdc(this, centerdc)
      %SET_CENTERDC   PreSet function for the 'CenterDC' property.

      this.privcenterdc = centerdc;
      
      % Force to use the entire nyquist interval when appropriate
      if centerdc
        fullnyq(this);
      end
      
      % Don't duplicate
      centerdc = [];

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
  
  
  methods (Hidden) %% possibly private or hidden
    function disp(this)
      %DISP

      s = get(this);
      s = reorderstructure(this,s);
      
      if s.NormalizedFrequency
        nfval = 'true';
      else
        nfval = 'false';
      end
      
      if s.CenterDC
        cdval = 'true';
      else
        cdval = 'false';
      end
      s = changedisplay(s, 'NormalizedFrequency', nfval,'CenterDC', cdval);
      
      disp(s);
      
    end
    
    
    function fullnyq(this) %#ok
      %FULLNYQ

      error(message('signal:dspopts:abstractspectrum:fullnyq:abstractMethod'));

    end
    
  end  %% possibly private or hidden
  
end  % classdef


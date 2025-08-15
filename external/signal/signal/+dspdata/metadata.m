classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) metadata < hgsetget & matlab.mixin.Copyable
  %dspdata.metadata class
  %    dspdata.metadata properties:
  %       DataUnits - Property is of type 'String'
  %
  %    dspdata.metadata methods:
  %       disp - Display method for the metadata object.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %DATAUNITS Property is of type 'String'
    DataUnits = '';
  end
  
  
  methods
    function set.DataUnits(obj,value)
      % DataType = 'String'
      % no cell string checks yet'
      obj.DataUnits = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function disp(H)
      %DISP Display method for the metadata object.

      s = get(H);
      disp(s);
      
    end
  end  %% public methods
  
end  % classdef


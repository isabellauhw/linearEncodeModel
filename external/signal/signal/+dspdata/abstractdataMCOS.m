classdef (CaseInsensitiveProperties=true, TruncatedProperties=true,Abstract) abstractdataMCOS < hgsetget & matlab.mixin.Copyable
  %dspdata.abstractdata class
  %    dspdata.abstractdata properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %
  %    dspdata.abstractdata methods:
  %       set_data -   PreSet function for the 'data' property.
  
  
  properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
    %NAME Property is of type 'String' (read only)
    Name = '';
    %DATA Property is of type 'mxArray' (read only)
    Data = [];
  end
  
  
  methods
    function set.Name(obj,value)
      % DataType = 'String'
      % no cell string checks yet'
      obj.Name = set_name(obj,value);
    end
    
    function set.Data(obj,value)
      obj.Data = set_data(obj,value);
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function data = set_data(this, data)
      %SET_DATA   PreSet function for the 'data' property.
      
      % NO OP.  Subclasses can perform checks here.
      
    end
    
  end  %% public methods
  
end  % classdef

function str = set_name(~,str)

if ~license('checkout','Signal_Toolbox')
  error(message('signal:dspdata:abstractdata:schema:LicenseRequired'));
end
end  % set_name


% [EOF]

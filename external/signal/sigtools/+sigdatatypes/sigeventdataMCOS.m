classdef sigeventdataMCOS < event.EventData & matlab.mixin.SetGet & matlab.mixin.Copyable
  %DataEventData   Define the DataEventData class.
  
  %   Copyright 2012 The MathWorks, Inc.
  
  
  properties
    Data;
  end
  
  methods
    
    function obj = sigeventdataMCOS(~, ~,data)
      %DataEventData   Construct the DataEventData class.
      
      narginchk(3, 3);
      
      if nargin>2
        obj.Data = data;
      end
      
    end
    
  end
  
end
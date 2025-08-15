classdef (ConstructOnLoad) SAEventData < event.EventData
    % Class to send additional event data for custom events
   properties
      Data
   end
   
   methods
      function data = SAEventData(dataStruct)
         data.Data = dataStruct;
      end
   end
end
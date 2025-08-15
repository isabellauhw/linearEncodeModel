classdef xp2winfileMCOS < sigio.abstractxpdestinationMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %sigio.xp2winfile class
  %   sigio.xp2winfile extends sigio.abstractxpdestination.
  %
  %    sigio.xp2winfile properties: 
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Data - Property is of type 'mxArray'
  %       Toolbox - Property is of type 'string'
  %
  %    sigio.xp2winfile methods:
  %       action - Perform the action of exporting to a window text-file.
  %       newdata - Update object based on new data to be exported.
  
  
  
  methods  % constructor block
    function h = xp2winfileMCOS(data)
      %XP2TXTFILE Constructor for the export to window text-file class.
      
      narginchk(1,1);

      h.Version = 1.0;
      h.Data = data;
      
      settag(h);
            
    end  % xp2coeffile
    
    
    function success = action(hCD)
      %ACTION Perform the action of exporting to a window text-file.
      
      % Convert from sigutils.vector to cell 
      hObj = cell(hCD.Data);
      
      % Pass in hObj directly inside winwrite
      winwrite(hObj{1},[],hObj);
      
      success = true;
      
    end
    
    
    function newdata(h)
      %NEWDATA Update object based on new data to be exported.
      
      % NO OP
      
    end
    
  end  %% public methods
  
end  % classdef


classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) cost < matlab.mixin.SetGet & matlab.mixin.Copyable 
%fdesign.cost class
%    fdesign.cost properties:
%       NMult - Property is of type 'mxArray' (read only) 
%       NAdd - Property is of type 'mxArray' (read only) 
%       NStates - Property is of type 'mxArray' (read only) 
%       MultPerInputSample - Property is of type 'mxArray' (read only) 
%       AddPerInputSample - Property is of type 'mxArray' (read only) 
%
%    fdesign.cost methods:
%       disp -   Display this object.


properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
  %NMULT Property is of type 'mxArray' (read only)
  NMult = [];
  %NADD Property is of type 'mxArray' (read only)
  NAdd = [];
  %NSTATES Property is of type 'mxArray' (read only)
  NStates = [];
  %MULTPERINPUTSAMPLE Property is of type 'mxArray' (read only)
  MultPerInputSample = [];
  %ADDPERINPUTSAMPLE Property is of type 'mxArray' (read only)
  AddPerInputSample = [];
end


methods  % constructor block
  function this = cost(NMult,NAdd,NStates,MPIS,APIS)
    %COST   Construct a COST object.

    % this = fdesign.cost;
    this.NMult = NMult;
    this.NAdd = NAdd;
    this.NStates = NStates;
    this.MultPerInputSample = MPIS;
    this.AddPerInputSample = APIS;

  end  % cost

end  % constructor block

methods 
  function set.NMult(obj,value)
  obj.NMult = value;
  end

  function set.NAdd(obj,value)
  obj.NAdd = set_NAdd(obj,value);
  end

  function set.NStates(obj,value)
  obj.NStates = value;
  end

  function set.MultPerInputSample(obj,value)
  obj.MultPerInputSample = value;
  end

  function set.AddPerInputSample(obj,value)
  obj.AddPerInputSample = value;
  end

end   % set and get functions 

methods  % public methods
  disp(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  str = tostring(this)
end  % possibly private or hidden 

end  % classdef

function val = set_NAdd(~,val)

if ~isdeployed
    if ~license('checkout','Signal_Blocks')
        error(message('signal:fdesign:cost:schema:LicenseRequired'));
    end
end
end  % set_NAdd


% [EOF]

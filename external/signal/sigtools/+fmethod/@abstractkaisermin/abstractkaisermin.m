classdef (Abstract) abstractkaisermin < fmethod.abstractwindow
%ABSTRACTKAISERMIN   Construct an ABSTRACTKAISERMIN object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fmethod.abstractkaisermin class
%   fmethod.abstractkaisermin extends fmethod.abstractwindow.
%
%    fmethod.abstractkaisermin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Window - Property is of type 'mxArray'  
%       ScalePassband - Property is of type 'bool'  
%
%    fmethod.abstractkaisermin methods:
%       postprocessargs - Test that the spec is met.
%       updateoddorder - If order is odd, and gain is not zero at nyquist, increase


properties
    MinOrder = 'any';
end

methods  % public methods
  args = postprocessargs(this,hspecs,N,Wn,TYPE,BETA)
  N = updateoddorder(this,N)
end  % public methods 


methods
    function vals = getAllowedStringValues(~,prop)
        switch prop
            case 'MinOrder'
                vals = {'any','even'};          
            otherwise
                vals = {};
        end
    end
    function set.MinOrder(obj,value)
        value = validatestring(value,getAllowedStringValues(obj,'MinOrder'),'','MinOrder');
        obj.MinOrder = value;
    end
end


end  % classdef


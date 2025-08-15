classdef (Abstract) dtfwnum < dfilt.singleton
%DTFWNUM Abstract class

%dfilt.dtfwnum class
%   dfilt.dtfwnum extends dfilt.singleton.
%
%    dfilt.dtfwnum properties:
%       PersistentMemory - Property is of type 'bool'  
%       NumSamplesProcessed - capture (read only) 
%       FilterStructure - Property is of type 'ustring'  (read only) 
%       States - Property is of type 'mxArray'  
%       Numerator - Property is of type 'mxArray'  
%
%    dfilt.dtfwnum methods:
%       dispatch -   Returns the LWDFILT.
%       dtfwnum_setnumerator - SETNUMERATOR Overloaded set on the Numerator property.
%       firxform - FIR Transformations
%       getnumerator - Overloaded get on the Numerator property.
%       iirxform - IIR Transformations
%       isblockable - True if the object supports the block method
%       refnumerator - Return reference numerator.
%       refvals -   Reference coefficient values.
%       setnumerator - Overloaded set on the Numerator property.
%       setrefnum - Overloaded set on the refnum property.
%       setrefvals -   Set reference values.


properties (Access=protected, SetObservable)
    %PRIVNUM Property is of type 'DFILTNonemptyVector user-defined' 
    privnum = [];
    %REFNUM Property is of type 'DFILTNonemptyVector user-defined' 
    refnum = [];
end

properties (SetObservable)
    %NUMERATOR Property is of type 'mxArray' 
    Numerator = 1;
end


    methods 
        function value = get.Numerator(obj)
        value = getnumerator(obj,obj.Numerator);
        end
        function set.Numerator(obj,value)
        obj.Numerator = setnumerator(obj,value);
        end

        function set.privnum(obj,value)
        % User-defined DataType = 'DFILTNonemptyVector user-defined'
        obj.privnum = value;
        end

        function set.refnum(obj,value)
        % User-defined DataType = 'DFILTNonemptyVector user-defined'
        
        %@TODO add validate attributes fir non empty, finite, numeric
        obj.refnum = setrefnum(obj,value);
        end
            
    end   % set and get functions 
    
    methods (Hidden) % possibly private or hidden
        Hd = dispatch(this)
        num = dtfwnum_setnumerator(Hd,num)
        rcnames = dtfwnumrefcoefficientnames(this)
        Ht = firxform(Ho,fun,varargin)
        num = getnumerator(Hd,num)
        [Ht,anum,aden] = iirxform(Ho,fun,varargin)
        b = isblockable(~)
        rcnames = refcoefficientnames(this)
        n = refnumerator(h)
        rcvals = refvals(this)
        num = setnumerator(Hd,num)
        num = setrefnum(Hd,num)
        setrefvals(this,refvals)
        g = thisnormalize(Hd)
        thisunnormalize(Hd,g)
    end  % possibly private or hidden

end  % classdef


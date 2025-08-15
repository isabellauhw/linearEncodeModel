classdef (Abstract) abstractallpass < dfilt.singleton
    %ABSTRACTALLPASS Abstract class
    
    %dfilt.abstractallpass class
    %   dfilt.abstractallpass extends dfilt.singleton.
    %
    %    dfilt.abstractallpass properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       AllpassCoefficients - Property is of type 'mxArray'
    %
    %    dfilt.abstractallpass methods:
    %       dispatch -   Returns the LWDFILT.
    %       dispstr - Display string of coefficients.
    %       doFrameProcessing - Returns true if frame processing if supported by realizemdl()
    %       get_coeffs -   PreGet function for the 'coeffs' property.
    %       iirxform - IIR Transformations
    %       set_coeffs -   PreSet function for the 'coeffs' property.
    %       thisdisp -   Display this object.
    %       thisisreal -   Dispatch and call the method.
    %       thisisrealizable - True if the structure can be realized by simulink
    %       thisisstable -   True if the object is stable.
    
    
    properties (Access=protected, SetObservable)
        %PRIVALLPASSCOEFFS Property is of type 'mxArray'
        privallpasscoeffs = [];
        %REFALLPASSCOEFFS Property is of type 'mxArray'
        refallpasscoeffs = [];
    end
    
    properties (SetObservable)
        %ALLPASSCOEFFICIENTS Property is of type 'mxArray'
        AllpassCoefficients = [];
    end
    
    
    methods
        function value = get.AllpassCoefficients(obj)
            value = get_coeffs(obj,obj.AllpassCoefficients);
        end
        function set.AllpassCoefficients(obj,value)
            obj.AllpassCoefficients = set_coeffs(obj,value);
        end
        
        function set.privallpasscoeffs(obj,value)
            obj.privallpasscoeffs = set_privallpasscoeffs(obj,value);
        end
        
    end   % set and get functions
    
    methods (Hidden) 
        [p,v] = coefficient_info(this)
        c = coefficientnames(this)
        c = coefficients(this)
        Hd = dispatch(this)
        s = dispstr(this,varargin)
        flag = doFrameProcessing(~)
        coeffs = get_coeffs(this,coeffs)
        [Ht,anum,aden] = iirxform(Hd,fun,varargin)
        varargout = lcldispstr(this,varargin)
        loadreferencecoefficients(this,s)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        s = objblockparams(this,varname)
        quantizecoeffs(this,eventData)
        s = savereferencecoefficients(this)
        coeffs = set_coeffs(this,coeffs)
        c = thiscoeffs(this)
        thisdisp(this)
        b = thisisreal(this)
        f = thisisrealizable(Hd)
        b = thisisstable(this)
    end  % possibly private or hidden
    
end  % classdef

function c = set_privallpasscoeffs(~, c)

if ~isdeployed
    if ~license('checkout','Signal_Blocks')
        error(message('signal:dfilt:abstractallpass:schema:LicenseRequired'));
    end
end
end  % set_privallpasscoeffs


% [EOF]

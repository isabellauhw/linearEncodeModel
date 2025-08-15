classdef psgaussnsym < fspecs.abstractspecwithnsymnfs
%PSGAUSSIANSYM   Construct an PSGAUSSIANSYM object.

%   Copyright 1999-2015 The MathWorks, Inc.
  
%fspecs.psgaussnsym class
%   fspecs.psgaussnsym extends fspecs.abstractspecwithnsymnfs.
%
%    fspecs.psgaussnsym properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       NumberOfSymbols - Property is of type 'posint user-defined'  
%       SamplesPerSymbol - Property is of type 'posint user-defined'  
%       BT - Property is of type 'udouble user-defined'  
%
%    fspecs.psgaussnsym methods:
%       getFilterOrder - Get the filterOrder.
%       getdesignobj - Get the design object
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize - Return the property name to normalize
%       propstoadd - Return the properties to add to the parent object
%       set_filterorder - PreSet function for the 'FilterOrder' property
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %SAMPLESPERSYMBOL Property is of type 'posint user-defined' 
    SamplesPerSymbol = 8;
    %BT Property is of type 'udouble user-defined' 
    BT = 0.3;
end


    methods  % constructor block
        function this = psgaussnsym(varargin)
        %PSRCOSNSYM Construct a PSRCOSNSYM object
        
        
        % this = fspecs.psgaussnsym;
        
        this.ResponseType = 'Gaussian pulse shaping with filter length in symbols';
        
        this.NumberOfSymbols = 6;
        
        this.setspecs(varargin{:});
        
        
        end  % psgaussnsym
        
    end  % constructor block

    methods 
        function set.SamplesPerSymbol(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive','integer'},'','SamplesPerSymbol');    
        obj.SamplesPerSymbol = value;
        end

        function set.BT(obj,value)
        % User-defined DataType = 'udouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','nonnegative'},'','BT');  
        value = double(value);
        obj.BT = value;
        end

    end   % set and get functions 

    methods  % public methods
    filterOrder = getFilterOrder(this)
    designobj = getdesignobj(this,str)
    minfo = measureinfo(this)
    p = props2normalize(this)
    p = propstoadd(this)
    filterOrder = set_filterorder(this,filterOrder)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef


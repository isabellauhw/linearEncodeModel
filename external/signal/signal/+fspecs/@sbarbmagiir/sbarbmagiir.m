classdef sbarbmagiir < fspecs.abstractsbarbmag
%SBARBMAGIIR   Construct an SBARBMAGIIR object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.sbarbmagiir class
%   fspecs.sbarbmagiir extends fspecs.abstractsbarbmag.
%
%    fspecs.sbarbmagiir properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       Frequencies - Property is of type 'double_vector user-defined'  
%       Amplitudes - Property is of type 'double_vector user-defined'  
%       NumOrder - Property is of type 'posint user-defined'  
%       DenOrder - Property is of type 'posint user-defined'  
%
%    fspecs.sbarbmagiir methods:
%       getdesignobj -   Get the design object.
%       propstoadd -   Return the properties to add to the parent object.
%       set_frequencies -   PreSet function for the 'frequencies' property.
%       validatespecs -   Validate the specs


properties (AbortSet, SetObservable, GetObservable)
    %NUMORDER Property is of type 'posint user-defined' 
    NumOrder = 8;
    %DENORDER Property is of type 'posint user-defined' 
    DenOrder = 8;
end


    methods  % constructor block
        function this = sbarbmagiir(varargin)
        %SBARBMAGIIR   Construct a SBARBMAGIIR object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.sbarbmagiir;
        respstr = 'Single-Band Arbitrary Magnitude IIR';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 4;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % sbarbmagiir
        
    end  % constructor block

    methods 
        function set.NumOrder(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','nonnegative','integer'},'','NumOrder');    
        obj.NumOrder = value;
        end

        function set.DenOrder(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive','integer'},'','DenOrder');    
        obj.DenOrder = value;
        end

    end   % set and get functions 

    methods  % public methods
    designobj = getdesignobj(this,str)
    p = propstoadd(this)
    frequencies = set_frequencies(this,frequencies)
    [Nb,Na,F,A,P,nfpts] = validatespecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    description = describe(this)
end  % possibly private or hidden 

end  % classdef


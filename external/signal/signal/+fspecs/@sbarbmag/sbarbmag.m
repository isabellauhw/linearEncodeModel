classdef sbarbmag < fspecs.abstractsbarbmag
%SBARBMAG   Construct an SBARBMAG object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.sbarbmag class
%   fspecs.sbarbmag extends fspecs.abstractsbarbmag.
%
%    fspecs.sbarbmag properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       Frequencies - Property is of type 'double_vector user-defined'  
%       Amplitudes - Property is of type 'double_vector user-defined'  
%       FilterOrder - Property is of type 'posint user-defined'  
%
%    fspecs.sbarbmag methods:
%       get_phases -   PreGet function for the 'phases' property.
%       getdesignobj - Get the design object.
%       propstoadd -   Return the properties to add to the parent object.
%       validatespecs -   Validate the specs


properties (AbortSet, SetObservable, GetObservable)
    %FILTERORDER Property is of type 'posint user-defined' 
    FilterOrder = 30;
end


    methods  % constructor block
        function this = sbarbmag(varargin)
        %SBARBMAG   Construct a SBARBMAG object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.sbarbmag;
        
        respstr = 'Single-Band Arbitrary Magnitude';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        end  % sbarbmag
        
    end  % constructor block

    methods 
        function set.FilterOrder(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive','integer'},'','FilterOrder');    
        obj.FilterOrder = value;
        end

    end   % set and get functions 

    methods  % public methods
    phases = get_phases(this,phases)
    designobj = getdesignobj(this,str,sigonlyflag)
    p = propstoadd(this)
    [N,F,A,P,nfpts] = validatespecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    description = describe(this)
end  % possibly private or hidden 

end  % classdef


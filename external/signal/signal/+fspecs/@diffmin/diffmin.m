classdef diffmin < fspecs.abstractspecwithfs
%DIFFMIN   Construct an DIFFMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.diffmin class
%   fspecs.diffmin extends fspecs.abstractspecwithfs.
%
%    fspecs.diffmin properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.diffmin methods:
%       getdesignobj -   Get the designobj.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Properties to normalize frequency.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
end


    methods  % constructor block
        function this = diffmin(varargin)
        %DIFFMIN   Construct a DIFFMIN object.
        
        %   Author(s): P. Costa
        
        % this = fspecs.diffmin;
        
        this.ResponseType = 'Minimum-order Differentiator';
        
        this.setspecs(varargin{:});
        
        
        end  % diffmin
        
    end  % constructor block

    methods 
        function set.Apass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass');
        value = double(value);
        obj.Apass = value;
        end

    end   % set and get functions 

    methods  % public methods
    designobj = getdesignobj(this,str)
    minfo = measureinfo(this)
    p = props2normalize(h)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [p,s] = magprops(this)
end  % possibly private or hidden 

end  % classdef


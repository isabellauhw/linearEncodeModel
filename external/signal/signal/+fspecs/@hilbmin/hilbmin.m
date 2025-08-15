classdef hilbmin < fspecs.abstractspecwithfs
%HILBMIN   Construct an HILBMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hilbmin class
%   fspecs.hilbmin extends fspecs.abstractspecwithfs.
%
%    fspecs.hilbmin properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       TransitionWidth - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.hilbmin methods:
%       getdesignobj -   Get the designobj.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %TRANSITIONWIDTH Property is of type 'posdouble user-defined' 
    TransitionWidth = .1;
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
end


    methods  % constructor block
        function this = hilbmin(varargin)
        %HILBMIN   Construct a HILBMIN object.
        
        %   Author(s): P. Costa
        
        % this = fspecs.hilbmin;
        
        this.ResponseType = 'Minimum-order Hilbert Transformer';
        
        this.setspecs(varargin{:});
        
        
        
        end  % hilbmin
        
    end  % constructor block

    methods 
        function set.TransitionWidth(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','TransitionWidth');
        value = double(value);
        obj.TransitionWidth = value;
        end

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
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [p,s] = magprops(this)
    p = props2normalize(h)
end  % possibly private or hidden 

end  % classdef


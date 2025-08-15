classdef hilbord < fspecs.abstractspecwithordnfs
%HILBORD   Construct an HILBORD object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hilbord class
%   fspecs.hilbord extends fspecs.abstractspecwithordnfs.
%
%    fspecs.hilbord properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       TransitionWidth - Property is of type 'posdouble user-defined'  
%
%    fspecs.hilbord methods:
%       getdesignobj -   Get the designobj.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %TRANSITIONWIDTH Property is of type 'posdouble user-defined' 
    TransitionWidth = .1;
end


    methods  % constructor block
        function this = hilbord(varargin)
        %HILBORD   Construct a HILBORD object.
        
        %   Author(s): P. Costa
        
        % this = fspecs.hilbord;
        
        this.ResponseType = 'Hilbert Transformer with filter order';
        
        this.FilterOrder = 30;
        
        this.setspecs(varargin{:});
        
        
        end  % hilbord
        
    end  % constructor block

    methods 
        function set.TransitionWidth(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','TransitionWidth');
        value = double(value);
        obj.TransitionWidth = value;
        end

    end   % set and get functions 

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    p = props2normalize(h)
end  % possibly private or hidden 

end  % classdef


classdef sbarbmagmin < fspecs.abstractsbarbmag
%SBARBMAGMIN   Construct an SBARBMAGMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.
  
%fspecs.sbarbmagmin class
%   fspecs.sbarbmagmin extends fspecs.abstractsbarbmag.
%
%    fspecs.sbarbmagmin properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       Frequencies - Property is of type 'double_vector user-defined'  
%       Amplitudes - Property is of type 'double_vector user-defined'  
%       Ripple - Property is of type 'posdouble user-defined'  
%
%    fspecs.sbarbmagmin methods:
%       getdesignobj - Get the design object.
%       propstoadd - Return the properties to add to the parent object.
%       set_frequencies - PreSet function for the 'frequencies' property.
%       thisgetspecs - Get the specs.
%       validatespecs - Validate the specs


properties (AbortSet, SetObservable, GetObservable)
    %RIPPLE Property is of type 'posdouble user-defined' 
    Ripple = 0.2;
end


    methods  % constructor block
        function this = sbarbmagmin(varargin)
        %SBARBMAGMIN Construct a SBARBMAGMIN object.
        
        
        % this = fspecs.sbarbmagmin;
        
        respstr = 'Single-Band Arbitrary Magnitude';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        end  % sbarbmagmin
        
    end  % constructor block

    methods 
        function set.Ripple(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Ripple');
        value = double(value);
        obj.Ripple = value;
        end

    end   % set and get functions 

    methods  % public methods
    designobj = getdesignobj(~,str)
    p = propstoadd(~)
    frequencies = set_frequencies(this,frequencies)
    specs = thisgetspecs(this)
    [F,A,R] = validatespecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    description = describe(~)
end  % possibly private or hidden 

end  % classdef


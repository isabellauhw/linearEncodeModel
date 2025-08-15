classdef hpcutoffwatten < fspecs.abstractlpcutoffwatten
%HPCUTOFFWATTEN   Construct an HPCUTOFFWATTEN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hpcutoffwatten class
%   fspecs.hpcutoffwatten extends fspecs.abstractlpcutoffwatten.
%
%    fspecs.hpcutoffwatten properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fcutoff - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'double'  
%       Astop - Property is of type 'double'  
%
%    fspecs.hpcutoffwatten methods:
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       propstoadd -   Return the properties to add to the parent object.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = hpcutoffwatten(varargin)
        %HPCUTOFFWATTEN   Construct a HPCUTOFFWATTEN object.
        
        
        % this = fspecs.hpcutoffwatten;
        
        respstr = 'Highpass with cutoff and attenuation';
        fstart = 2;
        fstop = 2;
        nargsnoFs = 4;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % hpcutoffwatten
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    p = propstoadd(this)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [pass,stop] = magprops(this)
end  % possibly private or hidden 

end  % classdef


classdef lpcutoffwatten < fspecs.abstractlpcutoffwatten
%LPCUTOFFWATTEEN   Construct an LPCUTOFFWATTEN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpcutoffwatten class
%   fspecs.lpcutoffwatten extends fspecs.abstractlpcutoffwatten.
%
%    fspecs.lpcutoffwatten properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fcutoff - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'double'  
%       Astop - Property is of type 'double'  
%
%    fspecs.lpcutoffwatten methods:
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = lpcutoffwatten(varargin)
        %LPCUTOFFWATTEN   Construct a LPCUTOFFWATTEN object.
        
        %   Author(s): J. Schickler
        
        % this = fspecs.lpcutoffwatten;
        
        respstr = 'Lowpass with cutoff and attenuation';
        fstart = 2;
        fstop = 2;
        nargsnoFs = 4;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % lpcutoffwatten
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [pass,stop] = magprops(this)
end  % possibly private or hidden 

end  % classdef


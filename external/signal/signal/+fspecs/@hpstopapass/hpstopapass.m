classdef hpstopapass < fspecs.abstractlpstopapass
%HPSTOPAPASS   Construct an HPSTOPAPASS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hpstopapass class
%   fspecs.hpstopapass extends fspecs.abstractlpstopapass.
%
%    fspecs.hpstopapass properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.hpstopapass methods:
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       propstoadd -   Return the properties to add to the parent object.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = hpstopapass(varargin)
        %HPSTOPAPASS   Construct a HPSTOPAPASS object.
        
        %   Author(s): J. Schickler
        
        % this = fspecs.hpstopapass;
        
        respstr = 'Highpass with passband ripple';
        fstart = 2;
        fstop = 2;
        nargsnoFs = 4;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % hpstopapass
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    p = propstoadd(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef


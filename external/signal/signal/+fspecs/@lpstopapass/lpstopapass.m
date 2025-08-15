classdef lpstopapass < fspecs.abstractlpstopapass
%LPSTOPAPASS   Construct an LPSTOPAPASS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpstopapass class
%   fspecs.lpstopapass extends fspecs.abstractlpstopapass.
%
%    fspecs.lpstopapass properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.lpstopapass methods:
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = lpstopapass(varargin)
        %LPSTOPAPASS   Construct a LPSTOPAPASS object.
        
        %   Author(s): J. Schickler
        
        % this = fspecs.lpstopapass;
        
        respstr = 'Lowpass with passband ripple';
        fstart = 1;
        fstop = 2;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % lpstopapass
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef


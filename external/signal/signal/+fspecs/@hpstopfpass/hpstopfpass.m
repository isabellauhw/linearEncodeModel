classdef hpstopfpass < fspecs.lpstopfpass
%HPSTOPFPASS   Construct an HPSTOPFPASS object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fspecs.hpstopfpass class
%   fspecs.hpstopfpass extends fspecs.lpstopfpass.
%
%    fspecs.hpstopfpass properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%       Fpass - Property is of type 'double'  
%
%    fspecs.hpstopfpass methods:
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Return the property name to normalize.
%       propstoadd -   Props to add.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = hpstopfpass(varargin)
        %HPSTOPFPASS   Construct a HPSTOPFPASS object.
        
        %   Author(s): J. Schickler
        
        % Override factory defaults inherited from lowpass
        if nargin < 1
            varargin{1} = 10;
        end
        if nargin < 2
            varargin{2} = .45;
        end
        if nargin < 3
            varargin{3} = .55;
        end
        
        % this = fspecs.hpstopfpass;
        
        respstr = 'Highpass with passband frequency';
        fstart = 2;
        fstop = 3;
        nargsnoFs = 4;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % hpstopfpass
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    p = props2normalize(this)
    p = propstoadd(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef


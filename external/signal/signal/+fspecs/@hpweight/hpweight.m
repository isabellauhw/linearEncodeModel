classdef hpweight < fspecs.lpweight
%HPWEIGHT   Construct an HPWEIGHT object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hpweight class
%   fspecs.hpweight extends fspecs.lpweight.
%
%    fspecs.hpweight properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.hpweight methods:
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Properties to normalize frequency.
%       propstoadd -   Returns the properties to add.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = hpweight(varargin)
        %HPWEIGHT   Construct a HPWEIGHT object.
        
        %   Author(s): J. Schickler
        
        % this = fspecs.hpweight;
        
        % Override factory defaults inherited from lowpass
        if nargin < 3
            varargin{3} = .55;
            if nargin < 2
                varargin{2} = .45;
                if nargin < 1
                    varargin{1} = 10;
                end
            end
        end
        
        respstr = 'Highpass';
        fstart = 2;
        fstop = 3;
        nargsnoFs = 5;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % hpweight
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    p = props2normalize(h)
    p = propstoadd(this)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [isvalid,errmsg,errid] = thisvalidate(h)
end  % possibly private or hidden 

end  % classdef


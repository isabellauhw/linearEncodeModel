classdef diffminmb < fspecs.abstractlpmin
%DIFFMINMB   Construct an DIFFMINMB object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.diffminmb class
%   fspecs.diffminmb extends fspecs.abstractlpmin.
%
%    fspecs.diffminmb properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.diffminmb methods:
%       getdesignobj -   Get the designobj.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Properties to normalize frequency.
%       thisgetspecs -   Get the specs.
%       thisvalidate -   Returns true if this object is valid.



    methods  % constructor block
        function this = diffminmb(varargin)
        %DIFFMINMB   Construct a DIFFMINMB object.
        
        %   Author(s): P. Costa
        
        % this = fspecs.diffminmb;
        
        this.ResponseType = 'Minimum-order multi-band Differentiator';
        
        this.setspecs(varargin{:});
        
        
        
        end  % diffminmb
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(this,str)
    minfo = measureinfo(this)
    p = props2normalize(h)
    specs = thisgetspecs(this)
    [isvalid,errmsg,errid] = thisvalidate(this)
end  % public methods 

end  % classdef


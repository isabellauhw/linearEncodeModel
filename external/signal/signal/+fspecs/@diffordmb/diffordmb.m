classdef diffordmb < fspecs.abstractdiffordmb
%DIFFORDMB   Construct an DIFFORDMB object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.diffordmb class
%   fspecs.diffordmb extends fspecs.abstractdiffordmb.
%
%    fspecs.diffordmb properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.diffordmb methods:
%       getdesignobj - Get the designobj.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = diffordmb(varargin)
        %DIFFORDMB   Construct a DIFFORDMB object.
        
        %   Author(s): P. Costa
        
        % this = fspecs.diffordmb;
        
        this.ResponseType = 'Multi-band Differentiator with filter order';
        
        % Defaults
        this.FilterOrder = 30;
        this.Fpass = .7;
        this.Fstop = .9;  
        
        this.setspecs(varargin{:});
        
        
        end  % diffordmb
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef


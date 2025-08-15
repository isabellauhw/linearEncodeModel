classdef difford < fspecs.abstractspecwithordnfs
%DIFFORD   Construct an DIFFORD object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.difford class
%   fspecs.difford extends fspecs.abstractspecwithordnfs.
%
%    fspecs.difford properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%
%    fspecs.difford methods:
%       getdesignobj -   Get the designobj.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Properties to normalize frequency.
%       set_filterorder -   PreSet function for the 'filterorder' property.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = difford(varargin)
        %DIFFORD   Construct a DIFFORD object.
        
        %   Author(s): P. Costa
        
        % this = fspecs.difford;
        
        this.ResponseType = 'Differentiator with filter order';
        
        % Since this specification type can only be used to design type IV
        % differentiators, set the default to an odd filter order.
        this.FilterOrder = 31;
        
        this.setspecs(varargin{:});
        
        
        
        end  % difford
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
    minfo = measureinfo(this)
    p = props2normalize(h)
    filterorder = set_filterorder(this,filterorder)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    p = thispropstosync(this,p)
end  % possibly private or hidden 

end  % classdef


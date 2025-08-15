classdef (Abstract) abstractdiffordmb < fspecs.abstractlp
%ABSTRACTDIFFORDMB   Construct an ABSTRACTDIFFORDMB object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractdiffordmb class
%   fspecs.abstractdiffordmb extends fspecs.abstractlp.
%
%    fspecs.abstractdiffordmb properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractdiffordmb methods:
%       props2normalize - Properties to normalize frequency.
%       set_filterorder - PreSet function for the 'filterorder' property.



    methods  % public methods
    p = props2normalize(~)
    filterorder = set_filterorder(this,filterorder)
end  % public methods 


        methods (Hidden) % possibly private or hidden
    p = propstoadd(this,varargin)
    p = thispropstosync(~,p)
end  % possibly private or hidden 

end  % classdef


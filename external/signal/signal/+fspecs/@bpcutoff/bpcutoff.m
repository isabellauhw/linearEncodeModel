classdef bpcutoff < fspecs.abstractspecwithordnfs
%BPCUTOFF   Construct an BPCUTOFF object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bpcutoff class
%   fspecs.bpcutoff extends fspecs.abstractspecwithordnfs.
%
%    fspecs.bpcutoff properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fcutoff1 - Property is of type 'posdouble user-defined'  
%       Fcutoff2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bpcutoff methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       props2normalize -   Properties to normalize frequency.
%       thisgetspecs -   Get the specs.
%       thisvalidate -   Check that this object is valid.


properties (AbortSet, SetObservable, GetObservable)
    %FCUTOFF1 Property is of type 'posdouble user-defined' 
    Fcutoff1 = 0.4;
    %FCUTOFF2 Property is of type 'posdouble user-defined' 
    Fcutoff2 = 0.6;
end


    methods  % constructor block
        function h = bpcutoff(varargin)
        %BPCUTOFF   Construct a BPCUTOFF object.
        %   H = BPCUTOFF(N,Fcutoff1,Fcutoff2,Fs) constructs a bandpass filter
        %   specifications object with cutoff frequencies.
        %
        %   N is the filter order and must be an even positive integer.
        %
        %   Fcutoff1 is the lower cutoff frequency and must be a positive scalar
        %   between 0 and 1 if no sampling frequency is specified or between 0 and
        %   Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fcutoff2 is the higher cutoff frequency and must be a positive scalar
        %   between 0 and 1 if no sampling frequency is specified or between 0 and
        %   Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        narginchk(0,4);
        
        
        % h = fspecs.bpcutoff;
        constructor(h,varargin{:});
        h.ResponseType = 'Bandpass with cutoff';
        
        end  % bpcutoff
        
    end  % constructor block

    methods 
        function set.Fcutoff1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fcutoff1');
        value = double(value);
        obj.Fcutoff1 = value;
        end

        function set.Fcutoff2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fcutoff2');
        value = double(value);
        obj.Fcutoff2 = value;
        end

    end   % set and get functions 

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    p = props2normalize(h)
    specs = thisgetspecs(this)
    [isvalid,errmsg,errid] = thisvalidate(h)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    constructor(h,varargin)
    hdesigns = hiddendesigns(this)
    minfo = measureinfo(this)
end  % possibly private or hidden 

end  % classdef


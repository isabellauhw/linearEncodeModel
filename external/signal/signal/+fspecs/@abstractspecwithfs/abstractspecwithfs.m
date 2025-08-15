classdef (Abstract) abstractspecwithfs < fspecs.abstractspec
%ABSTRACTSPECWITHFS   Construct an ABSTRACTSPECWITHFS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractspecwithfs class
%   fspecs.abstractspecwithfs extends fspecs.abstractspec.
%
%    fspecs.abstractspecwithfs properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%
%    fspecs.abstractspecwithfs methods:
%       describe -   Describe the object.
%       designopts -   Display the design options.
%       firdecim -   Design a Decimation filter.
%       firinterp -   Create an FIRINTERP object.
%       firmultirate -   Perform the design of a multirate.
%       firsrc -   Design an sample-rate converter.
%       fsconstructor -   Base constructor for all specs with Fs.
%       getdecimfactor -   Get the decimfactor.
%       getfs -   Pre-Get Function for the Fs property.
%       getinterpfactor -   Get the interpfactor.
%       getnormalizedfrequency -   Get the normalizedfrequency.
%       getspecs -   Get the specs.
%       getstate -   Return the state of the object.
%       help -   Provide help for the specified design method.
%       loadobj -   Load this object.
%       magprops -   Return the magnitude properties.
%       nfcn -   Evaluate a function with normalized frequency set to true.
%       normalizefreq - Normalize frequency specifications.
%       normalizetime - Normalize time specifications.
%       saveobj -   Save this object.
%       setspecs -   Set the specifications
%       setstate -   Set the state of the object.
%       thisstaticresponse -   Called by STATICRESPONSE.
%       validate -   Validate specs.


properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %PRIVFS Property is of type 'posdouble user-defined'
    privFs = 1;
    %PRIVNORMALIZEDFREQ Property is of type 'bool'
    privNormalizedFreq = true;
end

properties (Transient, AbortSet, SetObservable, GetObservable)
    %FS Property is of type 'mxArray' 
    Fs = [];
end

properties (Transient, SetObservable, GetObservable)
    %NORMALIZEDFREQUENCY Property is of type 'bool' 
    NormalizedFrequency = true;
end


    methods 
        function value = get.NormalizedFrequency(obj)
        value = getnormalizedfrequency(obj,obj.NormalizedFrequency);
        end
        function set.NormalizedFrequency(obj,value)
        % DataType = 'bool'
        %This method will error, so validateattributes is removed
        obj.NormalizedFrequency = setnormalizedfrequency(obj,value);
        end

        function value = get.Fs(obj)
        value = getfs(obj,obj.Fs);
        end
        function set.Fs(obj,value)
        % User-defined DataType = 'mxArray' 
        % This method relies on the set method of the privFs to error for
        % invalid inputs.
        obj.Fs = setfs(obj,value);
        end

        function set.privFs(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fs');
        value = double(value);
        obj.privFs = value;
        end

        function set.privNormalizedFreq(obj,value)
        % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privNormalizedFreq')
        value = logical(value);
        obj.privNormalizedFreq = value;
        end

    end   % set and get functions 

    methods  % public methods
    p = describe(this)
    s = designopts(this,dmethod,sigonlyflag)
    varargout = firdecim(this,method,varargin)
    varargout = firinterp(this,method,varargin)
    varargout = firmultirate(this,method,varargin)
    varargout = firsrc(this,method,L,M,varargin)
    fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin)
    decimfactor = getdecimfactor(this)
    Fs = getfs(h,Fs)
    interpfactor = getinterpfactor(this)
    normalizedfrequency = getnormalizedfrequency(this,dummy)
    specs = getspecs(this)
    state = getstate(this)
    help(this,designmethod)
    [p,s] = magprops(this)
    varargout = nfcn(this,fcn,varargin)
    normalizefreq(h,boolflag,Fs)
    normalizetime(this,oldFs,oldNormFreq)
    s = saveobj(this)
    setspecs(this,varargin)
    setstate(this,state)
    thisstaticresponse(this,hax,magunits)
    [isvalid,errmsg,msgid] = validate(h)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    s = aswfs_getdesignpanelstate(this)
    aswfs_setspecs(this,varargin)
    cachecurrentnormalizedfreq(~)
    c = computecparam(h,F1,F2)
    [struct,varargin] = parsemultiratestruct(this,struct,varargin)
    p = propstosync(this)
    Fs = setfs(h,Fs)
    staticresponse(this,hax,magunits)
    p = thisprops2add(this,varargin)
    p = thispropstosync(this,p)
    [isvalid,errmsg,errid] = thisvalidate(h)
    
end  % possibly private or hidden 


    methods (Static) % static methods
    this = loadobj(this,s)
end  % static methods 

end  % classdef

function normfreq = setnormalizedfrequency(this,normfreq)
  %SETNORMALIZEDFREQUENCY   Set function for the NormalizedFrequency property.
  error(message('signal:fspecs:abstractspecwithfs:schema:settingPropertyNotAllowed', 'NormalizedFrequency', 'normalizefreq', 'help fdesign/normalizefreq'));
end  % setnormalizedfrequency


% [EOF]

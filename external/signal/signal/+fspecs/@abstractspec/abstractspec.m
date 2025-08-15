classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, Abstract) abstractspec < matlab.mixin.SetGet & matlab.mixin.Copyable & dynamicprops & matlab.mixin.Heterogeneous 
%ABSTRACTSPEC   Construct an ABSTRACTSPEC object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractspec class
%    fspecs.abstractspec properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%
%    fspecs.abstractspec methods:
%       butter -   Butterworth digital filter design.
%       cheby1 - Chebyshev Type I digital filter design.
%       cheby2 -   Chebyshev Type II digital filter design.
%       checkincfreqs -   Check for increasing frequencies.
%       design - Design a filter.
%       designmethods -   Return the design methods for this specification object.
%       designoptions - Return the design options.
%       disp -   Display this object.
%       ellip -   Elliptic or Cauer digital filter design.
%       equiripple -   Design an equiripple filter.
%       fircls -   Design a constrained least-squares filter.
%       firls -   Design a FIR Least-Squares filter.
%       hiddendesigns -   Returns designs that we do not want to publicize.
%       ifir -    Design an two-stage equiripple filter.
%       iirlinphase -   IIR quasi linear phase digital filter design.
%       isfromdesignfilt - True if design comes from designfilt function
%       kaiserwin -   Design a kaiser-window filter.
%       maxflat -   Design a FIR maximally flat filter.
%       measureinfo -   Return the info for the measurements.
%       multistage -    Design a multistage equiripple filter.
%       validstructures -   Return the valid structures.
%       window - Design a window filter.


properties (AbortSet, SetObservable, GetObservable, Hidden)
    %FROMFILTERDESIGNER Property is of type 'bool' (hidden)
    FromFilterDesigner = false;
    %FROMDESIGNFILT Property is of type 'bool' (hidden)
    FromDesignfilt = false;
end

properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
    %RESPONSETYPE Property is of type 'ustring' (read only)
    ResponseType
end


    methods 
        function set.ResponseType(obj,value)
            % DataType = 'ustring'
        validateattributes(value,{'char'}, {'vector'},'','ResponseType')
        obj.ResponseType = value;
        end

        function set.FromFilterDesigner(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','FromFilterDesigner')
        value = logical(value);
        obj.FromFilterDesigner = value;
        end

        function set.FromDesignfilt(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','FromDesignfilt')
        value = logical(value);
        obj.FromDesignfilt = value;
        end

    end   % set and get functions 

    methods  % public methods
    Hd = butter(this,varargin)
    Hd = cheby1(this,varargin)
    Hd = cheby2(this,varargin)
    [isvalid,errmsg,errid] = checkincfreqs(h,fprops)
    varargout = design(this,method,varargin)
    [d,isfull,type] = designmethods(this,varargin)
    dopts = designoptions(this,method,sigonlyflag)
    disp(this)
    Hd = ellip(this,varargin)
    varargout = equiripple(this,varargin)
    varargout = fircls(this,varargin)
    Hd = firls(this,varargin)
    hdesigns = hiddendesigns(this)
    varargout = ifir(this,varargin)
    Hd = iirlinphase(this,varargin)
    flag = isfromdesignfilt(this)
    Hd = kaiserwin(this,varargin)
    Hd = maxflat(this,varargin)
    varargout = measureinfo(this)
    varargout = multistage(this,varargin)
    vs = validstructures(this,method)
    Hd = window(this,win,varargin)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    Hd = ansis142(this,varargin)
    Hd = bell41009(this,varargin)
    varargout = freqsamp(this,varargin)
    varargout = iirlpnorm(this,varargin)
    varargout = iirls(this,varargin)
    Hd = lagrange(this,varargin)
    g = nominalgain(this)
    p = propstoadd(this)
    [isvalid,errmsg,msgid] = validate(h)
end  % possibly private or hidden 

end  % classdef


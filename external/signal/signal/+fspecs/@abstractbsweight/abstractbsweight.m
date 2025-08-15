classdef (Abstract) abstractbsweight < fspecs.abstractspecwithordnfs
%ABSTRACTBSWEIGHT   Construct an ABSTRACTBSWEIGHT object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractbsweight class
%   fspecs.abstractbsweight extends fspecs.abstractspecwithordnfs.
%
%    fspecs.abstractbsweight properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fstop1 - Property is of type 'posdouble user-defined'  
%       Fstop2 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractbsweight methods:
%       getdesignpanelstate - Get the designpanelstate.
%       props2normalize - Properties to normalize frequency.


properties (AbortSet, SetObservable, GetObservable)
    %FPASS1 Property is of type 'posdouble user-defined' 
    Fpass1 = 0.35;
    %FSTOP1 Property is of type 'posdouble user-defined' 
    Fstop1 = 0.45;
    %FSTOP2 Property is of type 'posdouble user-defined' 
    Fstop2 = 0.55;
    %FPASS2 Property is of type 'posdouble user-defined' 
    Fpass2 = 0.65;
end


    methods 
        function set.Fpass1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fpass1');
        value = double(value);
        obj.Fpass1 = value;
        end

        function set.Fstop1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop1');
        value = double(value);
        obj.Fstop1 = value;
        end

        function set.Fstop2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop2');
        value = double(value);
        obj.Fstop2 = value;
        end

        function set.Fpass2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fpass2');
        value = double(value);
        obj.Fpass2 = value;
        end

    end   % set and get functions 

    methods  % public methods
    s = getdesignpanelstate(this)
    p = props2normalize(~)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [isvalid,errmsg,errid] = thisvalidate(h)
end  % possibly private or hidden 

end  % classdef


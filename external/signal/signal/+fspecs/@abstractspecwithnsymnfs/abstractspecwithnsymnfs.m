classdef (Abstract) abstractspecwithnsymnfs < fspecs.abstractspecwithfs
%ABSTRACTSPECWITHNSYMNFS   Construct an ABSTRACTSPECWITHNSYMNFS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractspecwithnsymnfs class
%   fspecs.abstractspecwithnsymnfs extends fspecs.abstractspecwithfs.
%
%    fspecs.abstractspecwithnsymnfs properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       NumberOfSymbols - Property is of type 'posint user-defined'  
%
%    fspecs.abstractspecwithnsymnfs methods:
%       set_NumberOfSymbols - SET_FILTERLENGTH PreSet function for the 'NumberOfSymbols' property


properties (AbortSet, SetObservable, GetObservable)
    %NUMBEROFSYMBOLS Property is of type 'posint user-defined' 
    NumberOfSymbols = 6;
end


    methods 
        function set.NumberOfSymbols(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive','integer'},'','NumberOfSymbols');    
        obj.NumberOfSymbols = set_NumberOfSymbols(obj,value);
        end

    end   % set and get functions 

    methods  % public methods
    numSymbols = set_NumberOfSymbols(this,numSymbols)
end  % public methods 

end  % classdef


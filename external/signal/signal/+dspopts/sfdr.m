classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) sfdr < hgsetget & matlab.mixin.Copyable
%dspopts.sfdr class
%    dspopts.sfdr properties:
%       MinSpurLevel - Property is of type 'mxArray'  
%       MinSpurDistance - Property is of type 'mxArray'  

%   Copyright 2015-2017 The MathWorks, Inc.


properties (AbortSet, SetObservable, GetObservable)
    %MINSPURLEVEL Property is of type 'mxArray' 
    MinSpurLevel = [];
    %MINSPURDISTANCE Property is of type 'mxArray' 
    MinSpurDistance = [];
end


methods  % constructor block
    function this = sfdr(varargin)
    %SFDR   Construct a SFDR options object
    
    
    % this = dspopts.sfdr;
    
    if nargin   
        set(this, varargin{:});
    end
    
    end  % sfdr
    
end  % constructor block

methods 
    function value = get.MinSpurLevel(obj)
        value = get_MinSpurLevel(obj,obj.MinSpurLevel);
    end
    function set.MinSpurLevel(obj,value)
        obj.MinSpurLevel = set_MinSpurLevel(obj,value);
    end

    function set.MinSpurDistance(obj,value)
        obj.MinSpurDistance = set_MinSpurDistance(obj,value);
    end

end   % set and get functions 
end  % classdef

function MinSpurLevel = set_MinSpurLevel(this,MinSpurLevel)
%%SET_MINSPURLEVEL Set function for the MINSPURLEVEL property.

if ~isempty(MinSpurLevel) && (~isreal(MinSpurLevel) || ~isscalar(MinSpurLevel) || ~isnumeric(MinSpurLevel))   
    error(message('signal:dspopts:sfdr:schema:invalidMinSpurLevel', 'MinSpurLevel'));
end
end  % set_MinSpurLevel


%--------------------------------------------------------------------------
function MinSpurLevel = get_MinSpurLevel(this,MinSpurLevel)
%%GET_MINSPURLEVEL   Return the value of the MINSPURLEVEL property.
if isempty(MinSpurLevel)
    MinSpurLevel = -Inf;
end
end  % get_MinSpurLevel


%--------------------------------------------------------------------------
function MinSpurDistance = set_MinSpurDistance(this,MinSpurDistance)
%%SET_MINSPURDISTANCE Set function for the MinSpurDistance property.

if ~isempty(MinSpurDistance) && (~isreal(MinSpurDistance) || ~isscalar(MinSpurDistance)  || ~isnumeric(MinSpurDistance) || MinSpurDistance <= 0)   
    error(message('signal:dspopts:sfdr:schema:invalidMinSpurDistance', 'MinSpurDistance'));
end
end  % set_MinSpurDistance


% [EOF]

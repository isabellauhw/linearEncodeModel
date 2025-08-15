classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) findpeaks < hgsetget & matlab.mixin.Copyable
%dspopts.findpeaks class
%    dspopts.findpeaks properties:
%       MinPeakHeight - Property is of type 'mxArray'  
%       MinPeakDistance - Property is of type 'mxArray'  
%       Threshold - Property is of type 'mxArray'  
%       NPeaks - Property is of type 'mxArray'  
%       SortStr - Property is of type 'mxArray'  

%   Copyright 2015-2017 The MathWorks, Inc.


properties (AbortSet, SetObservable, GetObservable)
    %MINPEAKHEIGHT Property is of type 'mxArray' 
    MinPeakHeight = [];
    %MINPEAKDISTANCE Property is of type 'mxArray' 
    MinPeakDistance = [];
    %THRESHOLD Property is of type 'mxArray' 
    Threshold = [];
    %NPEAKS Property is of type 'mxArray' 
    NPeaks = [];
    %SORTSTR Property is of type 'mxArray' 
    SortStr = [];
end


methods  % constructor block
    function this = findpeaks(varargin)
    %FINDPEAKS Construct a FINDPEAKS options object
    
    
    % this = dspopts.findpeaks;
    
    if nargin   
        set(this, varargin{:});
    end
    
    
    end  % findpeaks
    
end  % constructor block

methods 
    function value = get.MinPeakHeight(obj)
        value = get_MinPeakHeight(obj,obj.MinPeakHeight);
    end
    function set.MinPeakHeight(obj,value)
        obj.MinPeakHeight = set_MinPeakHeight(obj,value);
    end

    function set.MinPeakDistance(obj,value)
        obj.MinPeakDistance = set_MinPeakDistance(obj,value);
    end

    function value = get.Threshold(obj)
        value = get_Threshold(obj,obj.Threshold);
    end
    function set.Threshold(obj,value)
        obj.Threshold = set_Threshold(obj,value);
    end

    function set.NPeaks(obj,value)
        obj.NPeaks = set_NPeaks(obj,value);
    end

    function value = get.SortStr(obj)
        value = get_SortStr(obj,obj.SortStr);
    end
    function set.SortStr(obj,value)
        obj.SortStr = set_SortStr(obj,value);
    end

end   % set and get functions 
end  % classdef

function MinPeakHeight = set_MinPeakHeight(this,MinPeakHeight)
%SET_MINPEAKHEIGHT Set function for the MINPEAKHEIGHT property.

if ~isempty(MinPeakHeight) && (~isreal(MinPeakHeight) || ~isscalar(MinPeakHeight) || ~isnumeric(MinPeakHeight))   
    error(message('signal:dspopts:findpeaks:schema:invalidMinPeakHeight', 'MinPeakHeight'));
end
end  % set_MinPeakHeight


%--------------------------------------------------------------------------
function MinPeakHeight = get_MinPeakHeight(this,MinPeakHeight)
%GET_MINPEAKHEIGHT Return the value of the MINPEAKHEIGHT property.

if isempty(MinPeakHeight)
    MinPeakHeight = -Inf;
end
end  % get_MinPeakHeight


%--------------------------------------------------------------------------
function MinPeakDistance = set_MinPeakDistance(this,MinPeakDistance)
%SET_MINPEAKDISTANCE Set function for the MinSpurDistance property.

if ~isempty(MinPeakDistance) && (~isreal(MinPeakDistance) || ~isscalar(MinPeakDistance)  || ~isnumeric(MinPeakDistance) || MinPeakDistance <= 0)   
    error(message('signal:dspopts:findpeaks:schema:invalidMinPeakDistance', 'MinPeakDistance'));
end
end  % set_MinPeakDistance


%--------------------------------------------------------------------------
function Threshold = set_Threshold(this,Threshold)
%SET_THRESHOLD Set function for the THRESHOLD property.

if ~isempty(Threshold) && (~isreal(Threshold) || ~isscalar(Threshold) || ~isnumeric(Threshold) || Threshold < 0)   
    error(message('signal:dspopts:findpeaks:schema:invalidThreshold', 'Threshold'));
end
end  % set_Threshold


%--------------------------------------------------------------------------
function Threshold = get_Threshold(this,Threshold)
%GET_THRESHOLD Return the value of the THRESHOLD property.

if isempty(Threshold)
    Threshold = 0;
end
end  % get_Threshold


%--------------------------------------------------------------------------
function NPeaks = set_NPeaks(this,NPeaks)
%SET_NPEAKS Set function for the NPEAKS property.

if ~isempty(NPeaks) && (~isnumeric(NPeaks) || ~isscalar(NPeaks) || any(rem(NPeaks,1)) || NPeaks < 1)   
    error(message('signal:dspopts:findpeaks:schema:invalidPeaks'));
end
end  % set_NPeaks


%--------------------------------------------------------------------------
function SortStr = set_SortStr(this,SortStr)
%SET_SORTSTR Set function for the SORTSTR property.

if ~isempty(SortStr) && (~ischar(SortStr) || (ischar(SortStr) && ~(strcmp(SortStr,'ascend') && ~(strcmp(SortStr,'none')) || strcmp(SortStr,'descend'))))    
    error(message('signal:dspopts:findpeaks:schema:invalidSortString', 'ascend', 'descend', 'none'));
end
end  % set_SortStr


%--------------------------------------------------------------------------
function SortStr = get_SortStr(this,SortStr)
%GET_SORTSTR Get function for the SORTSTR property.

if isempty(SortStr)  
    SortStr = 'none';
end
end  % get_SortStr


% [EOF]

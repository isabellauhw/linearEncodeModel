classdef notificationeventdataMCOS < sigdatatypes.sigeventdataMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
%sigdatatypes.notificationeventdata class
%   sigdatatypes.notificationeventdata extends sigdatatypes.sigeventdata.
%
%    sigdatatypes.notificationeventdata properties:
%       Type - Property is of type 'string' (read only) 
%       Source - Property is of type 'handle' (read only) 
%       Data - Property is of type 'MATLAB array'  
%       NotificationType - Property is of type 'sigdatatypesNotificationType enumeration: {'ErrorOccurred','WarningOccurred','StatusChanged','FileDirty'}'  


properties (AbortSet, SetObservable, GetObservable)
    %NOTIFICATIONTYPE Property is of type 'sigdatatypesNotificationType enumeration: {'ErrorOccurred','WarningOccurred','StatusChanged','FileDirty'}' 
    NotificationType = 'ErrorOccurred';
end


methods  % constructor block
    function obj = notificationeventdataMCOS(hSrc, NType, data)
    %SIGEVENTDATA Constructor for the sigeventdata object.
    
    narginchk(2, 3);
    if nargin < 3, data = []; end
    
    obj@sigdatatypes.sigeventdataMCOS(hSrc,'Notification',data);   
    
    % Initialize the Data field with the passed-in value
    obj.NotificationType = NType;
    obj.Data = data;
    
    
    end  % notificationeventdata
    
    function set.NotificationType(obj,value)
        % Enumerated DataType = 'sigdatatypesNotificationType enumeration: {'ErrorOccurred','WarningOccurred','StatusChanged','FileDirty'}'
        value = validatestring(value,{'ErrorOccurred','WarningOccurred','StatusChanged','FileDirty'},'','NotificationType');
        obj.NotificationType = value;
    end
end   % set and get functions 
end  % classdef

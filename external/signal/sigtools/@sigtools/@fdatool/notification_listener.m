function notification_listener(hFDA, eventData)
%NOTIFICATION_LISTENER Listener to components 'Notification' Event

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Use calledonce to make sure the self listener doesn't do anything if its
% already been called once.
persistent calledonce;

% If the source of the warning is hFDA then the warning has already been
% resent.
if (isempty(calledonce) || calledonce == 0) && eventData.Source ~= hFDA
    calledonce = 1;
    send(hFDA, 'Notification', eventData);
else
    
    % Get the Notification type and all it's possible settings. Note that
    % warning and error are methods of fvtool and not the warning and error
    % functions.
    NTypes = set(eventData, 'NotificationType');
    NType  = get(eventData, 'NotificationType');
    
    % Switch on the Notification type
    switch NType
        case NTypes{1} % 'ErrorOccurred'
            error(hFDA, eventData.Data.ErrorString);
        case NTypes{2} % 'WarningOccurred'
            if ~lclignorewarning(eventData.Data)
                warnstr = eventData.Data.WarningString;
                if largestuiwidth({warnstr}) > 625 || contains(warnstr, newline)
                    str = getString(message('signal:sigtools:fdatool:notification_listener:FDAToolWarning'));  
                    warning(hFDA, str, warnstr);
                else
                    status(hFDA, warnstr, 1);
                end
            end
        case NTypes{3} % 'StatusChanged'
            status(hFDA, eventData.Data.StatusString);
        case NTypes{4} % 'FileDirty'
            set(hFDA, 'FileDirty', 1);
      otherwise
          str = getString(message('signal:sigtools:fdatool:notification_listener:UnhandledNotification',NType,class(eventData.Source)));     
          error(hFDA, str);
    end
    calledonce = 0;
end

% ---------------------------------------------------------------------
function b = lclignorewarning(data)

id = data.WarningID;

ids2ignore = {'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'};

if any(strcmpi(id, ids2ignore))
    b = true;
    return;
end

id = fliplr(strtok(fliplr(id), ':'));

b = false;

tags2ignore = {'propwillbereset' };

if any(strcmpi(id, tags2ignore))
    b = true;
end

% [EOF]

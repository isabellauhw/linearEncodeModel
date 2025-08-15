function push(hStack, data)
%PUSH Add an entry to the database

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% If the stack is full, cannot push
if isfull(hStack)
    error(message('signal:sigutils:stack:push:GUIErr'));
end

allData = get(hStack,'Data');

% Add the data to the stack
allData{end+1} = data;
set(hStack,'Data',allData);

% Notify listeners
send(hStack,'TopChanged',handle.EventData(hStack,'TopChanged'));

% [EOF]

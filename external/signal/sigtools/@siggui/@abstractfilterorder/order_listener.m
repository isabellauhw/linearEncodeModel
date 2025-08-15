function order_listener(h, eventData)
%ORDER_MODIFIED Callback executed by listener to the order property.

%   Author(s): R. Losada, Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

% Get the order
Order = get(h, 'Order');

% Get the handle to the edit box
handles = get(h, 'Handles');
eb = handles.eb;

% Get the string of the edit box
set(eb, 'String', Order);

% [EOF]

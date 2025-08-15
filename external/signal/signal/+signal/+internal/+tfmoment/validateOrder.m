function orderUnique = validateOrder(order, funcNameStr)
%VALIDATEORDER validate the order for TFSMOMENT, TFTMOMENT, TFMOMENT.

%   This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc. 

validateattributes(order, {'single','double'},{'positive','nonempty',...
        'finite','real','integer'},'tfsmoment','order');
switch funcNameStr   
    case {'tfsmoment', 'tftmoment'}
        validateattributes(order, {'single','double'},{'vector'},'tfsmoment','order');
        orderUnique = unique(order);
        if length(order) ~= length(orderUnique)
            warning(message('signal:tfmoment:duplicateOrder'));
        end
    case 'tfmoment'
        validateattributes(order, {'single','double'},{'2d','ncols', 2},'tfmoment','order');
        orderUnique = unique(order, 'rows');
        if size(order, 1) ~= size(orderUnique, 1)
            warning(message('signal:tfmoment:duplicateOrder'));
        end
end
end

%==========================================================================
%                   Input and Output Variable Names
%==========================================================================
function opts = getRHSFunctionCallInfo(voInArgName,opts)

% Default input argument names
sigName = 'vibSig';
fsName = 'Fs';
orderName = 'order';
ridgePointName = 'ridgePoints';

% Input signal name
if ~isempty(voInArgName{1})
    sigName = voInArgName{1};
end
voInArgName(1) = [];

% Right-hand-side function call
rhsFuncCall = ['rpmtrack(',sigName,','];

opts.RHSFunctionCallWithValueOnlyParam = rhsFuncCall;
opts.SignalArgName = sigName;
opts.OrderArgName = orderName;
opts.RidgePointArgName = ridgePointName;
opts.FsArgName = fsName;

if ~opts.IsTimeTable
    if ~isempty(voInArgName)
        % Fs
        if ~isempty(voInArgName{1})
            opts.FsArgName = voInArgName{1};
        end
        voInArgName(1) = [];
    end
    opts.RHSFunctionCallWithValueOnlyParam = ...
        [opts.RHSFunctionCallWithValueOnlyParam,opts.FsArgName,','];
end
if ~isempty(voInArgName)
    % Order
    if ~isempty(voInArgName{1})
        opts.OrderArgName = voInArgName{1};
    end
    voInArgName(1) = [];
end
opts.RHSFunctionCallWithValueOnlyParam = ...
    [opts.RHSFunctionCallWithValueOnlyParam,opts.OrderArgName,','];
if ~isempty(voInArgName)
    % Ridge point
    if ~isempty(voInArgName{1})
        opts.RidgePointArgName = voInArgName{1};
    end
end
opts.RHSFunctionCallWithValueOnlyParam = ...
    [opts.RHSFunctionCallWithValueOnlyParam,opts.RidgePointArgName,','];

end

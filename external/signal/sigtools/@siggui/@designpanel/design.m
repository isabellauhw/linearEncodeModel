function design(this)
%DESIGN Design the filter specified.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hDM = get(this, 'CurrentDesignMethod');
if isempty(hDM)
    buildcurrent(this);
    hDM = get(this, 'CurrentDesignMethod');
end

set(this, 'IsDesigned', 1);

sendstatus(this, [getString(message('signal:sigtools:siggui:DesigningFilter')) ' ... ']);

try
    
    % Send the active components to the design method
    syncGUIvals(hDM, get(this, 'ActiveComponents'));
    
    % Design the filter
    data.filter = designwfs(hDM);
    data.mcode   = genmcode(hDM);
catch ME
    set(this, 'IsDesigned', 0);
    throwAsCaller(ME);
end

% Send the FilterDesigned Event
send(this, 'FilterDesigned', ...
    sigdatatypes.sigeventdata(this, 'FilterDesigned', data));

sendstatus(this, [getString(message('signal:sigtools:siggui:DesigningFilter')) ...
                  ' ... ' getString(message('signal:sigtools:siggui:Done'))]);

% [EOF]

function Hd = reorderandscale(this, Hd)
%REORDERANDSCALE   Reorder and scale the filter

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Always use the reference filter.
if nargin < 2, Hd = this.refFilter; end

reorderinputs = {get(this, 'ReorderType')};

switch lower(reorderinputs{1})
    case 'custom'
        hc = getcomponent(this, 'custom');
        reorderinputs = getreorderinputs(hc);
    case 'none'
        reorderinputs = [];
    case 'auto'
        reorderinputs = {'auto'};
    otherwise
        % NO OP, just use the above inputs.
end

% Check if there is any mask information that we need to capture.
if isprop(Hd, 'maskinfo')
    maskinfo = get(Hd, 'MaskInfo');
else
    maskinfo = [];
end
Hd = copy(Hd);
if ~isempty(maskinfo)
    p = schema.prop(Hd, 'maskinfo', 'mxArray');
    set(p, 'Visible', 'Off');
    set(Hd, 'MaskInfo', maskinfo);
end

if ~isempty(reorderinputs)
    reorder(Hd, reorderinputs{:});
end
   
switch this.PNorm
    case 1, pnorm = 'l1';
    case 2, pnorm = 'Linf';
    case 3, pnorm = 'l2';
    case 4, pnorm = 'L1';
    case 5, pnorm = 'linf';
end

if strcmpi(this.scale, 'on')

    svc = map(this.ScaleValueConstraint);
    
    if strcmpi(svc, 'unit')
        msv = {};
    else
        msv = {'MaxScaleValue', evaluatevars(this.MaxScaleValue)};
    end
    
    sendstatus(this, [getString(message('signal:sigtools:siggui:ScalingSOSFilter')) ' ...']);

    % Scale with no reorder, because we do this ourselves.
    scale(Hd, pnorm, ...
        'MaxNumerator', evaluatevars(this.MaxNumerator), ...
        'NumeratorConstraint', map(this.NumeratorConstraint), ...
        'Overflowmode', this.OverflowMode, ...
        'ScaleValueConstraint', svc, ...
        'sosReorder', 'none', ...
        msv{:});

    sendstatus(this, [getString(message('signal:sigtools:siggui:ScalingSOSFilter')) ...
                      ' ... ' getString(message('signal:sigtools:siggui:Done'))]);
end

% -------------------------------------------------------------------------
function n = map(n)

if strcmpi(n, 'powers of two')
    n = 'po2';
end

% [EOF]

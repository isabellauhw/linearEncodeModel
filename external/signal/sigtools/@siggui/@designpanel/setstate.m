function setstate(this, s)
%SETSTATE Set the designpanel's state

%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

set(this, 'PreviousState', s, 'IsLoading', true);

try
    set(this, lclconvertstatestruct(this, s));
catch %#ok<CTCH>
    set(this, 'IsLoading', false);
    error(message('signal:siggui:designpanel:setstate:SigErr'));
end

for hindx = allchild(this)
    setcomponentstate(this, s, hindx);
end

% Force fire the event of the filter order so that the min/specify frames
% will appear.
hFO = find(this, '-class', 'siggui.filterorder');
send(hFO, 'UserModifiedSpecs', handle.EventData(hFO, 'UserModifiedSpecs'));

if isfield(s, 'isDesigned')
    set(this, 'IsDesigned', s.isDesigned);
end

% Set the input processing option. If loading from a pre R2011b block, then
% set input processing to inherited. 
setInputProcessingState(this,s);

set(this, 'IsLoading', false);

% -------------------------------------------------------------
%   Functions for backwards compatibility
% -------------------------------------------------------------

% -------------------------------------------------------------
function sout = lclconvertstatestruct(this, sin)

if isfield(sin, 'type')

    sout.ResponseType   = sin.type;
    sout.DesignMethod   = processmethod(sin.method);
    sout.StaticResponse = sin.StaticResponse;
else
    fout = {'Tag', 'Version', 'Components'};
    if isfield(sin, 'FilterType')
        sin.ResponseType = sin.FilterType;
        fout = {fout{:}, 'FilterType'}; %#ok<CCAT>
    end
    sout = rmfield(sin, fout);
end

if ~isfield(sout, 'SubType')

    hFT = getcomponent(this, '-class', 'siggui.selector', 'Name', 'Response Type');

    sout.SubType = sout.ResponseType;
    filtertypes  = getallselections(hFT);
    for indx = 1:length(filtertypes)
        subs = getsubselections(hFT, filtertypes{indx});

        idx = find(strcmpi(subs, sout.SubType), 1);

        if ~isempty(idx)
            sout.ResponseType = filtertypes{indx};
            break;
        end
    end
end
sout = reorderstructure(sout, 'ResponseType', 'SubType');


% -------------------------------------------------------------
function method = processmethod(method)

switch method
    case 'cheb2'
        method = 'filtdes.cheby2';
    case 'cheb1'
        method = 'filtdes.cheby1';
    otherwise

        if isempty(findstr(method, '.'))
            method = ['filtdes.' method];
        end
end

% [EOF]

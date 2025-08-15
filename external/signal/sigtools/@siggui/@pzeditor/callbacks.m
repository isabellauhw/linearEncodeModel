function cbs = callbacks(this)
%CALLBACKS Callbacks for the Pole/Zero Editor

%   Copyright 1988-2017 The MathWorks, Inc.

cbs              = siggui_cbs(this);
cbs.gain         = @gain_cb;
cbs.scale        = @scale_cb;
cbs.rotate       = @rotate_cb;
cbs.currentvalue = @currentvalue_cb;
cbs.keypress     = @keypress_cb;
cbs.currentsection = @currentsection_cb;

% -----------------------------------------------------
function currentsection_cb(hcbo, ~, this)

set(this, 'CurrentSection', str2double(popupstr(hcbo)));

% -----------------------------------------------------
function currentvalue_cb(hcbo, ~, this)

cv = getcurrentvalue(this);

if strcmpi(get(hcbo, 'Tag'), 'real')
    one = evaluatevars(get(hcbo, 'String'));
    if strcmpi(this.CoordinateMode, 'polar')
        two = angle(cv);
    else
        two = imag(cv);
    end
else
    two = evaluatevars(get(hcbo, 'String'));
    if strcmpi(this.CoordinateMode, 'polar')
        one = abs(cv);
    else
        one = real(cv);
    end
end

% Convert to rectangular coordinates.
if strcmpi(this.CoordinateMode, 'polar')
    cv = one*(sin(two)*1i+cos(two));
else
    cv = one+two*1i;
end

setcurrentvalue(this, cv);

send(this, 'NewFilter', handle.EventData(this, 'NewFilter'));
% -----------------------------------------------------
function gain_cb(hcbo, ~, this)

gain   = evaluatevars(fixup_uiedit(hcbo));
set(this, 'Gain', gain{1});
send(this, 'NewFilter', handle.EventData(this, 'NewFilter'));

% -----------------------------------------------------
function scale_cb(~, ~, this)

type = getcurrenttype(this);

scalefactor = inputdlg(getString(message('signal:sigtools:siggui:ScaleByFactor', type)), getString(message('signal:sigtools:siggui:Scale', type)), 1, {'1'});

if ~isempty(scalefactor)

    try
        
        scalefactor = evaluatevars(scalefactor{1});

        scale(this, scalefactor);
    catch
        senderror(this, getString(message('signal:sigtools:siggui:InvalidScaleFactor')));
    end
end

% -----------------------------------------------------
function rotate_cb(~, ~, this)

type = getcurrenttype(this);

rotatefactor = inputdlg(getString(message('signal:sigtools:siggui:RotateByRadians', type)),getString(message('signal:sigtools:siggui:Rotate', type)), 1, {'1'});

if ~isempty(rotatefactor)


    try
        
        rotatefactor = evaluatevars(rotatefactor{1});

        rotate(this, rotatefactor);
    catch
        senderror(this, getString(message('signal:sigtools:siggui:InvalidRotationFactor')));
    end
end

% -----------------------------------------------------
function keypress_cb(hFig, ~, this)

if isempty(getcurrenttype(this)) || isempty(get(hFig, 'CurrentCharacter')), return; end

switch abs(get(hFig, 'CurrentCharacter'))
    case 28 % left arrow
        this.setcurrentvalue(getcurrentvalue(this) - .1);
    case 29 % right arrow
        this.setcurrentvalue(getcurrentvalue(this) + .1);
    case 30 % up arrow
        this.setcurrentvalue(getcurrentvalue(this) + .1i);
    case 31 % down arrow
        this.setcurrentvalue(getcurrentvalue(this) - .1i);
    case {8, 127} % backspace and delete
        deletecurrentroots(this);
end

currentroots_listener(this, 'update_currentvalue');
send(this, 'NewFilter', handle.EventData(this, 'NewFilter'));


% [EOF]

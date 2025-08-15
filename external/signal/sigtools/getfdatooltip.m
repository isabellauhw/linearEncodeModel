function tip = getfdatooltip(index)
%GETFDATOOLTIP   Return a tip for FDATool given an index.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

% Define the valid for the signal only case.
validtips = [0 6 12 14 16 17 18 19 20 21 23 25];

% Add the plug-in tips.
if isfdtbxinstalled
    validtips = [validtips 1 2 4 5 8 9 10 11 13 24];
end
if issimulinkinstalled
    validtips = [validtips 15];
end
if isfdhdlcinstalled
    validtips = [validtips 3 22];
end
if isccslinkinstalled
    validtips = [validtips 7];
end

% Sort them so they show in the correct order.
validtips = sort(validtips);

ntips = length(validtips);

% Index into the VALIDTIPS vector to find the next tip.
switch validtips(rem(index+ntips-1, ntips)+1)
    case 0
        tip = getString(message('signal:fdatooltip:Tip0'));
    case 1
        tip = getString(message('signal:fdatooltip:Tip1'));
    case 2
        tip = getString(message('signal:fdatooltip:Tip2'));
    case 3
        tip = getString(message('signal:fdatooltip:Tip3'));
    case 4
        tip = getString(message('signal:fdatooltip:Tip4'));
    case 5
        tip = getString(message('signal:fdatooltip:Tip5'));
    case 6
        tip = getString(message('signal:fdatooltip:Tip6'));
    case 7
        tip = getString(message('signal:fdatooltip:Tip7'));
    case 8
        tip = getString(message('signal:fdatooltip:Tip8'));
    case 9
        tip = getString(message('signal:fdatooltip:Tip9'));
    case 10
        tip = getString(message('signal:fdatooltip:Tip10'));
    case 11
        tip = getString(message('signal:fdatooltip:Tip11'));
    case 12
        tip = getString(message('signal:fdatooltip:Tip12'));
    case 13
        tip = getString(message('signal:fdatooltip:Tip13'));
    case 14
        tip = getString(message('signal:fdatooltip:Tip14'));
    case 15
        tip = getString(message('signal:fdatooltip:Tip15'));
    case 16
        tip = getString(message('signal:fdatooltip:Tip16'));
    case 17
        tip = getString(message('signal:fdatooltip:Tip17'));
    case 18
        tip = getString(message('signal:fdatooltip:Tip18'));
    case 19
        tip = getString(message('signal:fdatooltip:Tip19'));
    case 20
        tip = getString(message('signal:fdatooltip:Tip20'));
    case 21
        tip = getString(message('signal:fdatooltip:Tip21'));
    case 22
        tip = getString(message('signal:fdatooltip:Tip22'));
    case 23
        tip = getString(message('signal:fdatooltip:Tip23'));
    case 24
        tip = getString(message('signal:fdatooltip:Tip24'));
    case 25
        tip = getString(message('signal:fdatooltip:Tip25'));
end

% [EOF]

function select(hObj, str)
%SELECT Select the specified poles and zeros
%   SELECT(hObj, STR) Select the poles and zeros specified by STR.  STR can
%   be 'none', 'all', 'allpoles', 'allzeros', 'insideunitcircle', 'left',
%   'lowerhalf', 'onunitcircle', 'outsideunitcircle', 'right', 'upperhalf'.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

opts = {'all', 'none', 'allpoles', 'allzeros', 'insideunitcircle', 'left', ...
        'lowerhalf', 'onunitcircle', 'outsideunitcircle', 'right', 'upperhalf'};

indx = strmatch(str, opts);

switch length(indx)
    case 0
        error(message('signal:siggui:pzeditor:select:invalidSelection', str));
    case 1
    otherwise
        
        % 'all' triggers this case.
        indx = strcmpi(str, opts);
        
        if isempty(indx)
            error(message('signal:siggui:pzeditor:select:notSpecific', str));
        end
end

allroots = hObj.Roots;

if isempty(allroots)
    croots = allroots;
else
    croots = feval([opts{indx} '_fcn'], allroots);
end

hObj.CurrentRoots = croots;

% -------------------------------------------------------------------------
function out = none_fcn(out)

out = [];

% -------------------------------------------------------------------------
function out = all_fcn(out)

% NO OP

% -------------------------------------------------------------------------
function out = allpoles_fcn(out)

out = find(out, '-isa', 'sigaxes.pole');

% -------------------------------------------------------------------------
function out = allzeros_fcn(out)

out = find(out, '-isa', 'sigaxes.zero');

% -------------------------------------------------------------------------
function out = insideunitcircle_fcn(out)

out = out(find(abs(double(out)) < 1));

% -------------------------------------------------------------------------
function out = left_fcn(out)

out = out(find(real(double(out)) < 0));

% -------------------------------------------------------------------------
function out = lowerhalf_fcn(out)

c = find(out, 'conjugate', 'on');
n = find(out, 'conjugate', 'off');

c = c(find(abs(imag(double(c))) > 0));

if isempty(n)
    out = c;
else
    out = [c; n(find(imag(double(n)) < 0))];
end

% -------------------------------------------------------------------------
function out = onunitcircle_fcn(out)

out = out(find(abs(double(out)) == 1));

% -------------------------------------------------------------------------
function out = outsideunitcircle_fcn(out)

out = out(find(abs(double(out)) > 1));

% -------------------------------------------------------------------------
function out = right_fcn(out)

out = out(find(real(double(out)) > 0));

% -------------------------------------------------------------------------
function out = upperhalf_fcn(out)

c = find(out, 'conjugate', 'on');
n = find(out, 'conjugate', 'off');

c = c(find(abs(imag(double(c))) > 0));

if isempty(n)
    out = c;
else
    out = [c; n(find(imag(double(n)) > 0))];
end

% [EOF]

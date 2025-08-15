function str = formatparams(this, params, values, descs)
%FORMATPARAMS Formats parameters
%   H.FORMATPARAMS(PARAMS, VALUES, DESCS) format the cells of strings PARAMS,
%   VALUES, and DESCS so that "PARAMS{:} = VALUES{:};  % DESCS{:}" and the
%   '=' and '%' line up.  The cell arrays must all be of the same length,
%   but DESCS can have empty entries in it.  In this case a local map will
%   be used which will determine the description from the parameter name.

%   Copyright 1988-2017 The MathWorks, Inc.

lv = length(values);

if nargin < 4
    descs = cell(size(params));
end

if lv ~= length(params) || lv ~= length(descs)
    error(message('signal:sigcodegen:mcodebuffer:formatparams:lengthMismatch'));
end

% Look for empty descriptions and fill them in from the map
for indx = 1:length(descs)
    if isempty(descs{indx})
        descs{indx} = lclmap(params{indx});
    end
end

for indx = 1:lv
    values{indx} = [values{indx} ';'];
end

tempstr = [char(params) repmat(' = ', lv, 1) char(values)];

% If any of the strings is already over 50 characters we need to move that
% line to the bottom of the list and make its comment on the above line.
if size(tempstr, 2) > 50
    
    % Break out the strings and deblank them so we can see which is over 50
    % characters
    ondx = []; % overflow index
    for indx = 1:size(tempstr, 1)
        cellstr{indx} = deblank(tempstr(indx, :));  %#ok<*AGROW>
        if length(cellstr{indx}) > 50
            ondx = [ondx, indx];
        end
    end
    
    % Divide the over and under strings and their descriptions
    overstrs   = cellstr(ondx);
    overdescs  = descs(ondx);
    understrs  = cellstr;
    underdescs = descs;
    understrs(ondx)  = [];
    underdescs(ondx) = [];
    
    % All of the under strings can just be combined with their descriptions
    tempstr = [char(understrs) repmat('  % ', length(understrs), 1) char(underdescs)];
    
    % The over strings have their descriptions on the line above the
    % variable declaration.
    for indx = 1:length(overstrs)
        overstrs{indx} = sprintf('\n%% %s\n%s', overdescs{indx}, ...
            this.format(overstrs{indx}, '=', 2));
    end
    
    tempstr = char(tempstr, overstrs{:});
    
else
    tempstr = [tempstr repmat('  % ', lv, 1) char(descs)];
end

str = '';
for indx = 1:size(tempstr,1)
    str = sprintf('%s\n%s', str, deblank(tempstr(indx,:)));
end
str(1) = [];

% -------------------------------------------------------------------------
function desc = lclmap(param)
%Map the known parameter names to their descriptions.

indx = regexp(param, '\d');

indx1 = max(indx);

if (length(indx) > 1) && (diff(indx) == 1)
  indx2 = indx;
else
  indx2 = indx1;
end

if isempty(indx1) || (indx1 ~= length(param) && ...
    ~contains(param,'Constrained') && ...
    isempty(regexp(param,'F.dB', 'once')))
  pre = '';
else
  paramCopy = param;
  paramCopy(indx1) = [];
  if strcmpi(paramCopy,'fdb')
    pre = num2str(param(indx1));
  else
    switch str2num(param(indx1)) %#ok<ST2NM>
      case 1
        pre = 'First ';
      case 2
        pre = 'Second ';
      case 3
        pre = 'Third ';
      case 4
        pre = 'Fourth ';
      case 5
        pre = 'Fifth ';
      case 6
        pre = 'Sixth ';
      case 7
        pre = 'Seventh ';
      case 8
        pre = 'Eighth ';
      case 9
        pre = 'Ninth ';
      case 0
        pre = 'Tenth ';        
    end
  end
end

param(indx2) = [];
if length(param) > 5
    switch param(end)
        case 'L'
            pre = sprintf('%sLower ', pre);
            param(end) = [];
        case 'U'
            pre = sprintf('%sUpper ', pre);
            param(end) = [];
    end
end

switch lower(param)
    case 'b'
        desc = 'Number of Bands';
    case 'c'
        desc = 'Constrained Band';        
    case 'n'
        desc = 'Order';
    case 'nb'
        desc = 'Numerator Order';
    case 'na'
        desc = 'Denominator Order';
    case 'apass'
        desc = 'Passband Ripple (dB)';
    case 'dpass'
        desc = 'Passband Ripple';
    case 'astop'
        desc = 'Stopband Attenuation (dB)';
    case 'dstop'
        desc = 'Stopband Attenuation';
    case 'fpass'
        desc = 'Passband Frequency';
    case 'fstop'
        desc = 'Stopband Frequency';
    case 'fc'
        desc = 'Cutoff Frequency';
    case 'fdb'
        desc = '-dB Frequency';        
    case 'fs'
        desc = 'Sampling Frequency';
    case 'fo'
        desc = 'Original Frequency';
    case 'ft'
        desc = 'Target Frequency';
    case 'wpass'
        desc = 'Passband Weight';
    case 'wstop'
        desc = 'Stopband Weight';
    case 'f'
        desc = 'Frequency Vector';
    case 'a'
        desc = 'Amplitude Vector';
    case 'w'
        desc = 'Weight Vector';
    case 'r'
        desc = 'Ripple Vector';
    case 'rp'
      desc = 'Ripple Value';
    case 'e'
        desc = 'Frequency Edges';
    case {'g','gd'}
        desc = 'Group Delay Vector';
    case 'dens'
        desc = 'Density Factor';
    case 'in'
        desc = 'Initial Numerator';
    case 'id'
        desc = 'Initial Denominator';
    case 'l'
        desc = 'Band';
    case 'tw'
        desc = 'Transition Width';
    case 'bw'
        desc = 'Bandwidth';
    case 'q'
        desc = 'Q-factor';
    case 'match'
        desc = 'Band to match exactly';
   case 'stopbandconstrained'
      desc = 'Stopband constraint flag';
   case 'passbandconstrained'
      desc = 'Passband constraint flag';      
    otherwise
        desc = '';
end

desc = sprintf('%s%s', pre, desc);

if isempty(desc)
    desc = ' ';
end

% [EOF]

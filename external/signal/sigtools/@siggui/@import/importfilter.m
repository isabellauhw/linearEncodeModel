function importfilter(this)
%IMPORT Import the filter into the Filter Target

%   Copyright 1988-2017 The MathWorks, Inc.

sendstatus(this, [getString(message('signal:sigtools:siggui:ImportingFilter')) ' ...']);

hcs = getcomponent(this, '-class', 'siggui.coeffspecifier');
hfs = getcomponent(this, '-class', 'siggui.fsspecifier');

% Get the constructor from the Filter Structure popup
object = getshortstruct(hcs,'object');

% Get the selected coefficient strings
coeffStrs = getselectedcoeffs(hcs);

coeffVals = thisEvaluatevars(coeffStrs);
ishdl = ishandle(coeffVals{1});
if isobject(coeffVals{1}) || (~isnumeric(coeffVals{1}) && ishdl(1) )
  if ~isa(coeffVals{1},'dfilt.basefilter')
    error(message('signal:sigtools:siggui:ImportInvalidFilter',class(coeffVals{1})))
  end
end
if strcmpi(object,'dfilt.basefilter') && ~isa(coeffVals{1},'dfilt.basefilter')
  error(message('signal:sigtools:siggui:ImportInvalidFilter1'))
end


% SOS Is the one "special" case
if strcmpi(get(hcs, 'SOS'), 'on')
    object = [object 'sos'];
end

% If the coefficient specified is already an object just assign it, as long
% as it is of the correct type.
if isa(coeffVals{1}, 'dfilt.basefilter')
    if isa(coeffVals{1},object)
        data.filter = copy(coeffVals{1});
    else
        error(message('signal:siggui:import:importfilter:GUIErr'));
    end
else
        
    % Lattice Allpass is another special case, we only use the first coeff
    if strcmpi(object,'dfilt.latticeallpass')
        coeffVals = coeffVals(1);
    end
    
    % Create the filter object using the constructor and coefficients
    data.filter = feval(str2func(object),coeffVals{:});
end

% Send the new filter
data.fs = getfsvalue(hfs);

send(this, 'FilterGenerated', ...
    sigdatatypes.sigeventdata(this, 'FilterGenerated', data));
set(this, 'isImported', 1);

sendstatus(this, [getString(message('signal:sigtools:siggui:ImportingFilter')) ...
                  ' ... ' getString(message('signal:sigtools:siggui:Done'))]);

%--------------------------------------------------------------------------
function vals = thisEvaluatevars(strs)

if  iscell(strs)
  for n = 1:length(strs) % Loop through strings
    if ~isempty(strs{n})
      try
        vals{n} = evalin('base',['[',strs{n},']']); %#ok<AGROW>
      catch %#ok<*CTCH>
        error(message('signal:siggui:import:importfilter:NotDefined', strs{ n }));
      end
    else
      error(message('signal:siggui:import:importfilter:EmptyEditBoxes'));
    end
  end
else
  if ~isempty(strs)
    try
      vals = evalin('base',['[',strs,']']);
    catch
      error(message('signal:siggui:import:importfilter:NotDefined', strs));
    end
  else
    error(message('signal:siggui:import:importfilter:EmptyEditBoxes'));
  end
end

% [EOF]

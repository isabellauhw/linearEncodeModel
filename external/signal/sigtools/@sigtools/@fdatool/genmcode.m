function genmcode(this, file , launchEditorFlag)
%GENMCODE Generate M-code

%   Copyright 1988-2017 The MathWorks, Inc.

if nargin < 3
  launchEditorFlag = true;
end

mcode = get(this, 'MCode');

% If there is no mcode, generate the default mcode.
if isempty(ishandle(mcode))
    [~, mcode] = defaultfilter(this);
end
if isempty(mcode)
    error(message('signal:sigtools:fdatool:genmcode:noMATLABcode'));
end

if nargin < 2
    [file, path] = uiputfile('*.m', ...
      getString(message('signal:sigtools:sigtools:GenerateMATLABCode')),...
      'untitled.m');
    if isequal(file, 0)
        return;
    end
    file = fullfile(path, file);
end

if ~contains(file, '.')
  file = [file '.m'];
end

% Set up the options for the public writer.
if isa(getfilter(this), 'mfilt.abstractmultirate')
    opts.H1 = getString(...
      message('signal:sigtools:sigtools:ReturnsMultirateFilterObj'));
else
    opts.H1 = getString(...
      message('signal:sigtools:sigtools:ReturnsDiscreteTimeFilterObj'));
end
opts.outputargs = 'Hd';

% Call the public writer.
genmcode(file, mcode, opts);

% Launch the editor with the file.
if launchEditorFlag
  edit(file);
end

% [EOF]

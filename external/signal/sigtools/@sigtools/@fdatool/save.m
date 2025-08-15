function success = save(hFDA, filename)
%SAVE Save the current session

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

overwrite = get(hFDA, 'Overwrite');

if nargin == 1, filename = get(hFDA, 'FileName'); end
if nargin == 2, set(hFDA, 'OverWrite', 'On'); end

[file, ext] = strtok(filename, '.');

if isempty(ext)
    filename = [file '.fda'];
end

success = false;

if strcmpi(hFDA.OverWrite, 'Off')
    success = saveas(hFDA);
elseif file ~= 0
    
    success = true;

    % Unix returns a path that sometimes includes two paths (the
    % current path followed by the path to the file) separated by '//'.
    % Remove the first path.
    if isunix
      indx = findstr(filename,[filesep,filesep]); %#ok<FSTR>
      if ~isempty(indx)
          filename = filename(indx+1:end);
      end
    end

    s = getstate(hFDA); %#ok

    try
        save(filename,'s','-mat');
        set(hFDA, ....
            'FileName', filename, ...
            'FileDirty', 0, ...
            'OverWrite', 'On');

    catch
        set(hFDA, 'Overwrite', overwrite);
        error(message('signal:sigtools:fdatool:save:SigErr'));
    end
end

% [EOF]

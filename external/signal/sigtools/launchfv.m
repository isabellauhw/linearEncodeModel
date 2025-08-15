function launchfv(hFig, tag, toolname)
%LAUNCHFV Utility for launching the help bowser.
%   LAUNCHFV(HFIG, TAG, TOOLNAME) attempts to bring up the TOOLNAME help
%   corresponding to the TAG string. Provides appropriate error messages
%   on failure.
%
%   TAG should include the toolbox.  If it finds more information beyond
%   the toolbox name it assumes that it is the whole path to the map file.
%
%   TAG can also be an HTML file from the documentation.

%   Author(s): V.Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(3,3);

if isempty(docroot)
    helpError(hFig, tag, toolname);
    return;
end

try,
    [path, name, ext] = fileparts(tag);
    if ~strcmpi(ext, '.html')

        [tag, toolbox] = strtok(tag,filesep);
        if isempty(toolbox)
            toolbox = ['signal' filesep 'signal'];
        else
            toolbox(1) = [];
        end
        if isempty(findstr(toolbox, filesep)), toolbox = [toolbox filesep toolbox]; end
        helpview(fullfile(docroot, 'toolbox', [toolbox '.map']), tag, 'CSHelpWindow');
    else

        % If the tag is already an html file, just show it.
        helpview(tag, 'CSHelpWindow');
    end
catch
    helpError(hFig, tag, toolname);
end

% -------------------------------------------------------------------------
function helpError(hFig, tag, toolname)

% Help failed
% Do some basic debugging of the help system:
msg = {'';
    getString(message('signal:sigtools:launchfv:FailedToFindOnlineHelpEntry'));
    ['   "' tag '"'];
    ''};

if isempty(docroot)
    msg = [msg; {getString(message('signal:sigtools:launchfv:info2')); ''}];
else
    msg = [msg; {getString(message('signal:sigtools:launchfv:info1')); ''}];
end

msg = [msg; getString(message('signal:sigtools:launchfv:info3'))];

hmsg = errordlg(msg,[toolname ' ' getString(message('signal:sigtools:launchfv:HelpError'))],'modal');
centerfigonfig(hFig, hmsg);

% [EOF]

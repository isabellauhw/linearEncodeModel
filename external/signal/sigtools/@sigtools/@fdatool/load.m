function load(this, file, varargin)
%LOAD Load a saved session into FDATool

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

old_tag = get(this.FigureHandle, 'Tag');
set(this.FigureHandle, 'Tag', 'Initializing');

force     = false;
overwrite = 'on';

for indx = 1:length(varargin)
    switch lower(varargin{indx})
        case 'force'
            force = true;
        case 'nooverwrite'
            overwrite = 'off';
    end
end

% Don't load if GUI is dirty.
if force || save_if_dirty(this,'loading')

    if nargin == 1

        % Change to the directory where the current session lives.
        old_pwd = pwd;

        path = fileparts(this.FileName);
        if ~isempty(path); cd(path); end

        % Load the file.
        [filename,pathname] = uigetfile('*.fda',getString(message('signal:sigtools:sigtools:LoadFilterDesignSession')));
        file = [pathname filename];

        % Return to old pwd ASAP after loading the file.
        cd(old_pwd);
    end

    % Skip loading if Cancel button is pressed on save dialog.
    if file ~= 0
        str = getString(message('signal:sigtools:sigtools:LoadingSessionFile'));
        status(this, str);
        
        % Turning warning off in case the load warns
        w = warning('off'); % cache warning state

        try
            s = loadandcheckforcorruptfile(file);
        catch ME
            warning(w);
            set(this.FigureHandle, 'Tag', old_tag);
            throwAsCaller(ME);
        end

        % If the file is a fwiz session, set up the fwiz panel with the
        % information.  This is a little hackish.  Revisit in R14.
        if isfield(s, 'fwspec')
            hsb = find(this, '-class', 'siggui.sidebar');
            inx = string2index(hsb, 'dspfwiz');

            % If the panel doesn't exist, it must be not be installed
            if isempty(inx)
                error(message('signal:sigtools:fdatool:load:GUIErr'));
            end

            hrm = constructAndSavePanel(hsb, inx);

            load(hrm, file);
            return;
        end

        warning(w); % Reset the warning state

        % This if statement is for backwards compatibility.  The new
        % MAT files store variables in a structure which results in the
        % s.s.fields format.  The old MAT files store a group of variables
        % which results in the s.fields format.
        if isfield(s,'s')
            s = s.s;
        end

        % A MAT file has been loaded, but it might not contain a valid session.
        isavalidsession(file,s);

        % Check if current_filt has been converted to a structure.
        % If so, DSP System Toolbox is not installed, can't load session.
        %successflag = checkforqfilt(w,s,ud);
        isauncorruptedfilter(s);

        calledbydspblks = getflags(this,'calledby','dspblks');
        hFig = get(this, 'FigureHandle');
        
        if isa(s.current_filt, 'dfilt.statespace')
            warning(message('signal:sigtools:fdatool:load:GUIWarn'));
            s.current_filt = convert(s.current_filt, 'df2t');
        end

        if isempty(s.current_filt)
            status(this,getString(message('signal:sigtools:sigtools:SessionNotLoaded')));
        else
            % Use the state ud (s) from the file to set the state of FDATool
            [wstr, wid] = lastwarn; % Ignore warnings from setstate
            w = warning('off');
            setstate(this,s);
            warning(w);
            lastwarn(wstr, wid);

            % Set appropriate flags
            set(this, ...
                'FileName', file, ...
                'FileDirty', 0, ...
                'OverWrite', overwrite);

            if calledbydspblks
                dspblksstatusbar(hFig);
            else
                status(this, getString(message('signal:sigtools:sigtools:Done', str)));
            end
        end
    end
end

set(this.FigureHandle, 'Tag', old_tag);

%----------------------------------------------------------------
function s = loadandcheckforcorruptfile(file)

[wstr, wid] = lastwarn;
s = struct([]);
try
    % Load session file.
    s = load(file,'-mat');
catch ME
    [file, ext] = strtok(file, '.');
    
    % If there was no extension, try with .fda before erroring.
    if isempty(ext)
        try
            s = load([file '.fda'], '-mat');
        catch ME
            notvalid(file);
        end
    else
        notvalid(file);
    end
end

% Ignore warnings coming from the loading of the objects.  They can throw
% divide by zero warnings.
lastwarn(wstr, wid);

%-----------------------------------------------------------------
function isavalidsession(file,s)
% A MAT file has been loaded, but it might not contain a valid session.
% There may be other problems later, but these variables being
% present is a good indication that the file is okay.

if ~isfield(s,'current_filt') || ...
        ~(isfield(s,'sidebar') || isfield(s,'fdspecs'))
    
    notvalid(file);
end

%--------------------------------------------------------------------
function isauncorruptedfilter(s,this)

if isstruct(s.current_filt)
    % Only qfilts should get here.
    error(message('signal:sigtools:fdatool:load:FDAToolSessionQFILT', 'QFILT'))
elseif iscell(s.current_filt) || ...
        ~isa(s.current_filt, 'dfilt.basefilter')
    error(message('signal:sigtools:fdatool:load:FDAToolSessionInvalidFilt'))      
end

%--------------------------------------------------------------------
function notvalid(file)

% Error if the session file could not load.
error(message('signal:sigtools:fdatool:load:notFDAToolSession', file));

% [EOF]

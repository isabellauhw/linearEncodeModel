function genmcode(file, mcode, opts)
%GENMATLABCODE Generate MATLAB code
%   GENMATLABCODE(FILE, MATLABCODE) Write the strings in MCODE to the file FILE.
%   MATLABCODE can also be a SIGCODEGEN.MATLABCODEBUFFER object.
%
%   GENMATLABCODE(FILE, MATLABCODE, OPTS) Using the OPTS to format the MCode.  OPTS
%   is a structure with the following fields:
%
%   'isfunction'    true or false to indicate whether to write a function
%                   prototype
%   'inputargs'     A string or cell of strings containing the input
%                   arguments.  If this field is present and not empty
%                   'isfunction' will be forced to true.
%   'outputargs'    A string or cell of strings containing the output
%                   arguments.  If this field is present and not empty
%                   'isfunction' will be forced to true.
%   'H1'            The string to be used for the H1 line in the help.  The
%                   filename will be capitalized and automatically
%                   prepended to this string.
%   'toolbox'       The toolbox to be used in the header for the file.
%                   This is defaulted to 'signal'.

%   'filename'      Specify a filename.
%   'attachfooter'  true if you want an [EOF] string at the end of the
%                   file. True by default.

%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,3)

if nargin < 3, opts = []; end

opts = lclbuildopts(opts);

closefile = false;

% If the file is a character string, open the file for writing.
if ischar(file)
    [~, opts.filename, ~] = fileparts(file);
    if isempty(findstr(file, '.'))
        file = [file '.m'];
    end
    closefile = true;
    file = fopen(file, 'w');
elseif isempty(opts.filename)
    opts.filename = 'testfile';
end

% Attach the function prototype
attachprototype(file, opts);

% Attach the header
fprintf(file, '\n%s\n', sptfileheader('MATLAB Code', opts.toolbox));

% Attach the body, this is the passed in MCode
attachbody(file, mcode);

% Attach a footer
if opts.attachfooter
  attachfooter(file);
end

% If we opened the file, close it.
if closefile
    fclose(file);
end

% ---------------------------------------------------------------
function attachprototype(file, opts)

inputargs  = opts.inputargs;
outputargs = opts.outputargs;
filename   = opts.filename;

% If there are input or output arguments write a function.
if ~(isempty(inputargs) && isempty(outputargs))
    opts.isfunction = true;
end

if ~opts.isfunction, return; end

fprintf(file, 'function ');

% If there are output arguments create them
if ~isempty(outputargs)
    
    brackets = false;
    
    if iscellstr(outputargs)
        outputargs = convert2string(outputargs);
    end
    
    % If the output arguments are in characters look for a ',' to indicate
    % multiple outputs and use the '[' character
    if ~isempty(findstr(outputargs, ','))
        brackets = true;
        fprintf(file, '[');
    end
    
    fprintf(file, '%s', outputargs);
    
    % If we added a '[' then add a ']'.
    if brackets
        fprintf(file, '] = ');
    else
        fprintf(file, ' = ');
    end
end

% Print the file name
fprintf(file, '%s', filename);

% If there are input arguments create them
if ~isempty(inputargs)
    if iscellstr(inputargs)
        inputargs = convert2string(inputargs);
    end
    
    fprintf(file, '(%s)', inputargs);
end

% Always put a new line after the function prototype
fprintf(file, '\n');

% If an H1 line has been supplied, add it with an uppercase FILENAME
if ~isempty(opts.H1)
    fprintf(file, '%%%s %s\n', upper(opts.filename), opts.H1);
end

% ---------------------------------------------------------------
function attachbody(file, strs)

if isa(strs, 'sigcodegen.stringbuffer')
    strs = strs.string;
end

if ~iscell(strs), strs = {strs}; end

% Always put spacing between the header and the body.
fprintf(file, '\n');

% Loop over the strings and write them to the file
for indx = 1:length(strs)
    if isempty(strs{indx})
        fprintf(file, '\n');
    else
        for jndx = 1:size(strs{indx}, 1)
            fprintf(file, '%s\n', strs{indx}(jndx,:));
        end
    end
end

fprintf(file, '\n');

% ---------------------------------------------------------------
function attachfooter(file)

fprintf(file, '%% [EOF]\n');

% ---------------------------------------------------------------
function opts = lclbuildopts(opts)
% Set up the option structure with some defaults.
if ~isempty(license('inuse','signal_blocks'))
  tbox = 'dsp';
else
  tbox = 'signal';
end
   
opts = setstructfields(struct('filename', '', ...
    'isfunction', false, ...
    'inputargs', '', ...
    'outputargs', '', ...
    'H1', 'Auto-generated M-code',...
    'toolbox',tbox,...
    'attachfooter', true),opts);

% ---------------------------------------------------------------
function str = convert2string(cstr)

str = '';
for indx = 1:length(cstr)-1
    str = sprintf('%s%s, ', str, cstr{indx});
end
str = sprintf('%s%s', str, cstr{end});


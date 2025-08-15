function write(this, fname)
%WRITE Write buffer string to text file.
%   H.WRITE(FNAME) Write the buffer string to the text file FNAME.
%
%   H.WRITE(FID) Write the buffer string to a text file pointed to by FID.
%   The file will not be closed.
%
%   See also FOPEN, FCLOSE, FPRINTF.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

% If fname is not a character, we assume that it is the FID to write to.
if ischar(fname)
    
    % open in "write text" mode, no append.  If the user wishes to append,
    % he can supply an FID instead of a filename.
    [fid, msg] = fopen(fname,'wt');
    if fid==-1
        error(message('signal:sigcodegen:stringbuffer:write:FileErr', fname, msg));
    end
else
    fid = fname;
end

fprintf(fid,'%s', this.string);

if ischar(fname)
    fclose(fid);
end

% [EOF]

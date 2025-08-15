function hblk = extractbits(hTar,name)
%EXTRACTNBITS 


%   Copyright 2007-2017 The MathWorks, Inc.

narginchk(2,2);

% check if simulink/Sources lib is available, if not load it.
issrclibloaded = 0;
srclibname = 'simulink';
srcblks_avail = issimulinkinstalled;
if srcblks_avail
    wdsrcblk = warning;
    warning('off');
    if isempty(find_system(0,'flat','Name',srclibname))
        issrclibloaded = 1;
        load_system(srclibname);
    end
    warning(wdsrcblk);
end

bname = 'simulink/Logic and Bit Operations/Extract Bits';

hblk = add_block(bname, [hTar.system '/' name]);

if issrclibloaded
    close_system(srclibname);
end

% [EOF]

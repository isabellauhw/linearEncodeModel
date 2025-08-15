function hblk =  comparetoconstant(hTar,name,constvalue,operator)
%COMPARETOCONSTANT Add a compare to constant block to model

%   Copyright 2007-2017 The MathWorks, Inc.


narginchk(4,4);

% check if simulink is available, if not load it.
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

blkname = 'simulink/Logic and Bit Operations/Compare To Constant';
hblk = add_block(blkname, [hTar.system '/' name]);
set_param(hblk, 'const', constvalue, 'relop', operator, 'LogicOutDataTypeMode','boolean');  

if issrclibloaded
    close_system(srclibname);
end

% [EOF]

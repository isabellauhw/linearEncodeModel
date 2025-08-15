function hblk = outport(hTar, name, render)
%OUTPORT Add a Outport block to the model.

%   Copyright 1995-2004 The MathWorks, Inc.

narginchk(2,3);

sys = hTar.system;

if nargin<3
    render=true;
end

if render 
    hblk = add_block('built-in/Outport', [hTar.system '/' name]);
else % do not add block just update
    hblk2=find_system(sys,'SearchDepth',1,'BlockType','Outport','Name',name);
    hblk=hblk2{1};
end

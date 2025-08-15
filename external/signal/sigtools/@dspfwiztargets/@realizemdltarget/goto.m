function hblk = goto(hTar, name, gototag, render)
%GOTO Add a Goto block to the model.

%   Copyright 1995-2004 The MathWorks, Inc.

narginchk(3,4);

sys = hTar.system;

if nargin<4
    render=true;
end

if render
    hblk = add_block('built-in/Goto', [hTar.system '/' name]);
    set_param(hblk, 'GotoTag', gototag);
else % do not add block just update
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','Goto','Name',name);
    hblk=hblk1{1};
end


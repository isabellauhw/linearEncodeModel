function [hblk,hblk1] = inport(hTar, name, param, render)
%INPORT Add a Inport block to the model.

%   Copyright 1995-2006 The MathWorks, Inc.

narginchk(3,4);

sys = hTar.system;

if nargin<4
    render=true;
end

if render
     hblk = add_block('built-in/Inport', [hTar.system '/' name]);
else % just update block
   hblk2=find_system(sys,'SearchDepth',1,'BlockType','Inport','Name',name);
    hblk=hblk2{1};
end


hblk1=0;


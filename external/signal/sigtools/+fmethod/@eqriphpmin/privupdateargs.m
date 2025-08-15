function args = privupdateargs(this,args,Nstep)
%PRIVUPDATEARGS Utility fcn called by POSTPROCESSMINORDERARGS

%   Copyright 1999-2017 The MathWorks, Inc.

% Increase order
args{1} = args{1}+Nstep;

if rem(args{1},2)
    % Odd order
    args{end+1}='h';
elseif strcmpi(args{end},'h')
    % Even order
    args(end) = [];
end

devs = args{4};                             % Deviations
if ~any(devs==1)
    % Convert Deviations to Weights
    args{4} = ones(size(devs))*max(devs)./devs; % Normalized weights
end

function args = privupdateargs(~,args,Nstep)
%PRIVUPDATEARGS Utility fcn called by POSTPROCESSMINORDERARGS

%   Copyright 1999-2017 The MathWorks, Inc.

% Increase order
args{1} = args{1}+Nstep;

devs = args{4};                             % Deviations
if ~any(devs==1)
    % Convert Deviations to Weights
    args{4} = ones(size(devs))*max(devs)./devs; % Normalized weights
end

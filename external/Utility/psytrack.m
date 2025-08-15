function out = psytrack(contrastLeft,contrastRight,isRightwardChoice,varargin)
% [weights, weights_stderr, hyperparameters] = psytrack(contrastLeft,contrastRight,isRightwardChoice,varargin)
% This implements the psytrack toolbox (https://github.com/nicholas-roy/psytrack)
% contrastLeft is a column vector of left contrast. contrastRight is a
% column vector of right contrast. isRightwardChoice is a column vector
% indicating whether the trial was a rightward choice (0=left choice,
% 1=right choice). The outputs are the weights for the model, standard error on the weight estimate, and
% estimates of the hyperparameters (see paper). Logistic model defined as:
%   ln(pR/pL) = B + SL*CL + SR*CR
%
% There are several optional arguments, but the two most important are:
% 
% 'sessionLength' - vector containing the number of trials within each session.
%       This is used to get an estimate of parameter shifts across sessions
% 'plotFlag' - true/false for whether to plot the parameter estimates

%Initial values for the hyperparameters. Sigma will be estimated from the
%data. If sessionLength is included, then sigDay will also be estimated from
%data.
default_sigInit = 2^4;
default_sigma = 2^py.numpy.array([-4 -4 -4]);
default_sigDay = 2^(-0.5);

p = inputParser;
addRequired(p,'contrastLeft',@iscolumn);
addRequired(p,'contrastRight',@iscolumn);
addRequired(p,'isRightwardChoice',@islogical);
addParameter(p,'sessionLength',[],@iscolumn);
addParameter(p,'sigma',default_sigma,@isrow);
addParameter(p,'sigInit',default_sigInit,@isrow);
addParameter(p,'sigDay',default_sigDay,@isrow);
addParameter(p,'plotFlag',false);
parse(p,contrastLeft,contrastRight,isRightwardChoice,varargin{:})

%check python installation 
try
    py.psytrack.generateSim;
catch
    error('Please setup Python for your MATLAB version, and ensure you have installed psytrack using pip');
end


%transform contrast
cTransform = @(c) tanh(5*c)./tanh(5);

%build data input
data = struct;
data.y = py.numpy.array(double(p.Results.isRightwardChoice));
data.inputs = struct('SL',py.numpy.matrix(cTransform(contrastLeft)).T,...
    'SR',py.numpy.matrix(cTransform(contrastRight)).T);

if ~isempty(p.Results.sessionLength)
    data.dayLength = py.numpy.array(int32(p.Results.sessionLength));
    optList = {'sigma','sigDay'};
    hyper = struct('sigInit',p.Results.sigInit,'sigma',p.Results.sigma, 'sigDay', p.Results.sigDay);
else
    optList = {'sigma'};
    hyper = struct('sigInit',p.Results.sigInit,'sigma',p.Results.sigma);
end

%Fit
w = struct('bias', int32(1), 'SL', int32(1),'SR', int32(1)); %identify which columns of predictors to use
out = py.psytrack.hyperOpt(data, hyper, w, optList);

%get weights from fit
weights = double(out{3})';
weights_stderr = double(out{4}{'W_std'})';
hyperparameters=struct(out{1});
hyperparameters.sigma = double(hyperparameters.sigma);

%Put into output struct
out = struct;
% out.contrastLeft = contrastLeft;
% out.contrastRight = contrastRight;
% out.isRightwardChoice = isRightwardChoice;
out.bias = weights(:,3);
out.SL = weights(:,1);
out.SR = weights(:,2);
out.bias_stderr =  weights_stderr(:,3);
out.SL_stderr = weights_stderr(:,1);
out.SR_stderr = weights_stderr(:,2);
out.hyper_sigInit = hyperparameters.sigInit;
out.hyper_sigma = hyperparameters.sigma;
if any(contains(optList,'sigDay'))
    out.hyper_sigDay = hyperparameters.sigDay;
else
    out.hyper_sigDay = [];
end

%Calculate p_hat (pred. probability of rightward choice) for each trial
z = sum([cTransform(contrastLeft) cTransform(contrastRight) ones(size(p.Results.contrastLeft))].*weights,2);
out.p_hat = 1./(1+exp(-z));

if p.Results.plotFlag
    numTrials = size(weights,1);
    param = repmat({'SL','SR','bias'}, numTrials,1);
    t = repmat( (1:numTrials)',1,3);
    g = gramm('x',t(:),'y',weights(:), 'ymin', weights(:)-1.96*weights_stderr(:), 'ymax', weights(:)+1.96*weights_stderr(:),'color',param(:));
    g.geom_interval('geom','area');
    g.set_color_options('map',[182 87 90;72 129 199;250 180 62]/255);
    g.set_names('x','Trial','y','MAP estimate & 95% credible intervals','color','parameter');
    figure; g.draw();
    yline(g.facet_axes_handles,0,'k:');
    if ~isempty(p.Results.sessionLength)
        arrayfun(@(x)xline(g.facet_axes_handles,x,'k:'),cumsum(p.Results.sessionLength));
    end
end

end

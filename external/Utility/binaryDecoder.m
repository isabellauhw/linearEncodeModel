function [auROC,auROC_nullP] = binaryDecoder(activity,decodedLabel,groupSplit,varargin)
%   [auROC,auROC_nullP] = binaryDecoder(activity,decodedLabel,groupSplit)
%   Performs combined conditions choice probability analysis (Steinmetz et al 2019)
%   This decoding analysis can be used to determine whether neural activity
%   (or any other variable) distinguishes between two conditions, while
%   controlling for the effect of other conditions on neural activity. For
%   example, decoding whether neural activity was different for Left vs
%   Right choices, while controlling for the effect of stimulus contrast on
%   the neural activity.
%
%   activity - [numTrials x numTimepoints]. A matrix containing the
%       value which will be used for the decoding analysis. This could be
%       neural activity (dF/F, or ephys spike counts, or wheel velocity).
%       Note that activity should not have many similar values, so if
%       you're using spike counts then add a small number to the activity.
%   decodedLabel - [numTrials x 1] logical array containing true/false or
%       1/0 values, indicating the trial label you want to decode. For
%       example if you want to decode whether the choice was to the Left,
%       then this variable could be defined as choice=='Left choice'.
%   groupSplit - [1 x numControlVariables] cell array, where each element
%       in the array contains an [numTrials x 1] vector of values labeling
%       different conditions for each trial. For example groupSplit =
%       {contrastLeft, contrastRight} will run the decoding analysis within
%       each possible combination of contrastLeft and contrastRight.
%
%   Optional extra argument: ...'numShuffles',X) sets the number of
%       shuffled used to compute statistical significance. Default is 2000.
%
%   Outputs:
%   auROC is a [1 x numTimepoints] vector containing the decoding
%       performance for each timepoint.
%   auROC_nullP is a [1 x numTimepoints] vector containing the
%       percentile of the auROC value within the shuffled null
%       distribution. The null distribution is calculated by shuffling
%       decodedLabel across trials. This percentile value can be compared against
%       threshold values (e.g. 0.025 and 0.975 for alpha=5% false alarm
%       rate) to determine statistical significance.

default_numShuffles = 2000;

%Validate inputs
p = inputParser;
addRequired(p,'activity',@(x) ismatrix(x) & ~any(isnan( x(:) )) );
addRequired(p,'decodedLabel',@islogical);
addRequired(p,'groupSplit',@iscell);
addParameter(p,'numShuffles',default_numShuffles,@isnumeric);
parse(p,activity,decodedLabel,groupSplit,varargin{:})

%Get all combinations of groupSplit
groupSplit = cellfun(@double,p.Results.groupSplit,'UniformOutput',false);
groupSplit = cell2mat(groupSplit);
[conds,~,groupSplitCondition]=unique(groupSplit,'rows');

%ensure a large enough number of cases where decodedLabel was 0 or 1 within
%each possible groupSplitCondition
q = crosstab(groupSplitCondition, decodedLabel);
assert( dot(q(:,1),q(:,2)) > 10, 'Too few trials present for the given combinations');

%For each condition, create a set of shuffle labels used later for
%computing the null distribution
shufLabels = cell(size(conds,1),1);
for c = 1:size(conds,1)
    idx = groupSplitCondition == c;
    numTrials = sum(idx);
    
    %Trials where decodedLabel is true
    chA = decodedLabel & idx;
    nA = sum(chA);
    
    q = arrayfun(@(x)randperm(numTrials,nA)', 1:p.Results.numShuffles, 'uni', false);
    shufLabels{c} = cell2mat(q); %each column is one shuffle
end

%For each column of activity
auROC = nan(1,size(p.Results.activity,2));
auROC_nullP = nan(1,size(p.Results.activity,2));
for t = 1:size(p.Results.activity,2)
    %For each groupSplitCondition
    
    nTotal = 0;
    nTotalShuf = zeros(1,p.Results.numShuffles);
    dTotal = 0;
    for c = 1:size(conds,1)
        idx = groupSplitCondition == c;
        numTrials = sum(idx);
        
        %Trials where decodedLabel is true
        chA = decodedLabel & idx;
        nA = sum(chA);
        
        %Trials where decodedLabel is false
        chB = ~decodedLabel & idx;
        nB = sum(chB);
        
        %Calculate the Mann Whitney statistic for whether the activity is
        %different between these two cases
        n = mannWhitneyUshuf(activity(chA,t), ...
            activity(chB,t), (1:nA)');
        
        %Calculate the null distribution taken by shuffling the
        %decodedLabel between different trials
        n_shuf = mannWhitneyUshuf(activity(chA,t), ...
            activity(chB,t), shufLabels{c});
                
        nTotal = nTotal+n;
        nTotalShuf = nTotalShuf+n_shuf;
        dTotal = dTotal+(nA*nB);
    end
    
    %Combine N and D values across conditions to get auROC
    auROC(1,t) = nTotal/dTotal;
    auROCShuf = nTotalShuf./dTotal;
    
    %Calculate the percentile of the auROC value in the shuffled
    %distribution
    tr = tiedrank([auROC(1,t), auROCShuf]); %rank order of auROC values
    nullP = tr(1)/(1+p.Results.numShuffles); %percentile of non-shuffled auROC
    
    %Correct p values at 0 or 1. Given the number of shuffles, the p value
    %is bounded between [(numShuffles-0.5)/numShuffles,
    %1-(numShuffles-0.5)/numShuffles]
    if nullP == 0
        nullP = (p.Results.numShuffles-0.5)/p.Results.numShuffles;
    elseif p == 1
        nullP = 1 - (p.Results.numShuffles-0.5)/p.Results.numShuffles;
    end
    
    auROC_nullP(1,t) = nullP;
end

end

function numer = mannWhitneyUshuf(x,y,shufLabels)
% function numer = mannWhitneyUshuf(x,y,shufLabels)
%
% numer is the number of instances for which x>y, of all possible
% comparisons. Divide by nx*ny for mannWhitney u statistic.
%
% shufLabels is ny x nshuf, each column a random permutation of integers
% from 1:nx. First column of shufLabels should be exactly 1:nx
%
% x and y are vectors
%

nx = numel(x);

t = tiedrank([x(:); y(:)]);

t = t(shufLabels);

if nx==1
    numer = t(:)';
else
    numer = sum(t,1);
end

numer = numer-nx*(nx+1)/2;
end
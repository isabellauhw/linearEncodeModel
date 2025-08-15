function visualiseTrainingPavlov1WorksWith0Rewards(expRef,dataProfile,channelLabels)
% This code visualises pavlov1 photometry data (stim-aligned and
% reward-aligned), used for current experiments.

%Load behav
b = getBehavData( expRef, dataProfile );

%Recode stimulus type to continuous variable
b.cDiff = nan(size(b.stimulusType));
b.cDiff( b.stimulusType=='None') = 0;
b.cDiff( b.stimulusType=='25%GratingRight') = 0.25;
b.cDiff( b.stimulusType=='50%GratingRight') = 0.5;
b.cDiff( b.stimulusType=='25%GratingLeft') = -0.25;
b.cDiff( b.stimulusType=='50%GratingLeft') = -0.5;
b.cDiff( b.stimulusType=='100%GratingCentre') = 1;

% %Get times when the wheel moved
% block = dat.loadBlock( expRef );
% moveOnsetTime = wheel.findWheelMoves3( block.inputs.wheelMMValues, block.inputs.wheelMMTimes,...
%     70,[]);



%define events to plot fluorescence - first need to make fill in the
%missing 'reward' times when the 'reward' was 0 -- otherwise later it won't
%be able to plot any of the non rewarded trials lol
if any(isnan(b.rewardTime))
    b.RewardTimeOriginal = b.rewardTime;
    idx0reward = arrayfun(@isnan,b.rewardTime);
    b.rewardTime(idx0reward==1) = b.stimulusOnsetTime(idx0reward==1)+1;
end
events = {'stimulus onset',b.stimulusOnsetTime;
          'reward onset',b.rewardTime};
      
b.rewardYN = b.rewardVolume;
b.rewardYN(b.rewardVolume==3) = 1;
b.rewardYN(isnan(b.rewardVolume)) = 0;

splitBy = {'reward:Y/N',b.rewardYN};
splitByCols = {0.9*RedWhiteBlue(3)};

%get aligned data. 
photometry = photometryAlign( expRef , 'plot', true, 'numSecToDetrend', 25, 'alignWithRewards', true);

chans = {'channel1_0G','channel2_2G','channel3_4G','channel4_6G'}; %green filtered channels
for i = 1:4
    if ~isempty(channelLabels{i})
        easy.EventAlignedAverageTimeWarped(photometry.(chans{i}),photometry.Timestamp, events,...
            'label','z-score fluorescence',...
            'titleText', [expRef ' ' channelLabels{i} ],...
            'splitBy',splitBy,...
            'EpochTimePrePost',[0.5 2],...
            'splitByColours',splitByCols);
        set(gcf,'position',[431 639 489 258],'MenuBar','none','name',[expRef ' ' channelLabels{i} ]);
    end
end


end



    

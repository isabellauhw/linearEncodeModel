function visualiseTrainingPavlov1(expRef,dataProfile,channelLabels)
% This code visualises pavlov1 photometry data (stim-aligned and
% reward-aligned), used for current experiments.

%Load behaviour
b = getBehavData( expRef, dataProfile );

%Recode stimulus type to continuous variable
b.cDiff = nan(size(b.stimulusType));
b.cDiff( b.stimulusType=='0%Grating') = 0;
b.cDiff( b.stimulusType=='25%GratingRight') = 0.25;
b.cDiff( b.stimulusType=='50%GratingRight') = 0.5;
b.cDiff( b.stimulusType=='25%GratingLeft') = -0.25;
b.cDiff( b.stimulusType=='50%GratingLeft') = -0.5;

% %Get times when the wheel moved
% block = dat.loadBlock( expRef );
% moveOnsetTime = wheel.findWheelMoves3( block.inputs.wheelMMValues, block.inputs.wheelMMTimes,...
%     70,[]);

%define events to plot fluorescence
events = {'stimulus onset',b.stimulusOnsetTime;
          'reward onset',b.rewardTime};

splitBy = {'stim c',b.cDiff};
splitByCols = {0.9*RedWhiteBlue(2)};

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

chans = {'channel1_0G_415','channel2_2G_415','channel3_4G_415','channel4_6G_415'}; %green filtered channels
for i = 1:4
    if ~isempty(channelLabels{i})
        easy.EventAlignedAverageTimeWarped(photometry.(chans{i}),photometry.Timestamp, events,...
            'label','z-score fluorescence',...
            'titleText', [expRef ' ' channelLabels{i} ' 415 nm'],...
            'splitBy',splitBy,...
            'EpochTimePrePost',[0.5 2],...
            'splitByColours',splitByCols);
        set(gcf,'position',[431 639 489 258],'MenuBar','none','name',[expRef ' ' channelLabels{i} ]);
    end
end



end



    

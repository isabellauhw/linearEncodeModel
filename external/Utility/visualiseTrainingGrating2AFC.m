function g=visualiseTrainingGrating2AFC(expRef,dataProfile,channelLabels)
% This code visualises grating2afc photometry and behav data, used for current experiments.

%Load behav
b = getBehavData( expRef, dataProfile );
b.cDiff = b.contrastRight-b.contrastLeft;
totalNumTrials = height(b);
goodTrials = b.repeatNumber==1 & b.choice~='NoGo';
b.outcomeTime = nanmean([b.rewardTime b.punishSoundOnsetTime],2);
highCPerformance = 100*mean(b.feedback(goodTrials & abs(b.cDiff)==max(abs(b.cDiff)))=='Rewarded');
overallPerformance = 100*mean(b.feedback(goodTrials)=='Rewarded');


%Define warp times
warp_sizes = [50,100,20,100]; %number of elements for erach epoch: pre-stim, stim-choice, choice-outcome, post-outcome
if sum(warp_sizes) == length(b.choice) %This addresses a bug which happens later if the number of trials = number of warp timepoints
    warp_sizes = warp_sizes+1;
end

%get time-warped activity for each trial
warp_samples = nan(length(b.choice), sum(warp_sizes));
for tr = 1:length(b.choice)
    epoch1 = linspace(b.stimulusOnsetTime(tr)-0.5, b.stimulusOnsetTime(tr), warp_sizes(1));
    epoch2 = linspace(b.stimulusOnsetTime(tr), b.choiceStartTime(tr), warp_sizes(2));
    epoch3 = linspace(b.choiceStartTime(tr), b.outcomeTime(tr), warp_sizes(3));
    epoch4 = linspace(b.outcomeTime(tr), b.outcomeTime(tr)+1, warp_sizes(4));
    warp_samples(tr,:) = [epoch1, epoch2, epoch3, epoch4];
end

block = dat.loadBlock(expRef);
wheel_warped = interp1(block.inputs.wheelMMTimes, block.inputs.wheelMMValues, warp_samples);
wheel_warped = wheel_warped - mean(wheel_warped(:,1:warp_sizes(1),:),2);

%Plot psych
clear g;
g(1,1) = gramm('x',b.cDiff,'y',b.choice=='Right','subset',goodTrials);
g(1,1).stat_summary('geom',{'point','line','errorbar'},'type',@grammCallbackBinomialConfidenceInterval);
g(1,1).axe_property('ylim',[0 1]);
g(1,1).geom_vline('xintercept',0,'style','k:');
g(1,1).geom_hline('yintercept',0.5,'style','k:');
g(1,1).set_names('x','Contrast','y','p(Right) & 95% CI');
g(1,1).set_title(sprintf('%s\n%d good trials, %d total trials\nHighC: %0.2f%%, All: %0.2f%% correct',expRef,sum(goodTrials),totalNumTrials,highCPerformance,overallPerformance));
g(2,1) = gramm('x',b.cDiff,'y',b.choiceCompleteTime - b.stimulusOnsetTime,'color',b.choice,'subset',b.feedback=='Rewarded' & goodTrials);
g(2,1).stat_summary('type','quartile','geom',{'line','errorbar','point'},'setylim',true);
g(2,1).set_names('x','Contrast','y','Response time (s) median & quartiles','color','');
g(2,1).set_title(sprintf('Response time\ncorrect trials'));
g(3,1) = gramm('x',1:sum(warp_sizes),'y',wheel_warped,'color',b.choice,'subset',b.feedback=='Rewarded');
g(3,1).stat_summary('setylim','true');
g(3,1).geom_vline('xintercept',cumsum(warp_sizes(1:3)),'style','k:');
g(3,1).set_names('x','','y','Wheel position mean & 95% CI');
g(3,1).set_title('Rewarded wheel movements');
g(3,1).axe_property('xtick','','xcolor','none');

% g(1,2) = gramm('x',b.trialNumber,'y', cumsum(b.choice == 'Right')./b.trialNumber,'subset',goodTrials);
g(1,2) = gramm('x',b.trialNumber,'y', movmean(b.choice == 'Right', 20));
g(1,2).geom_line();
g(1,2).axe_property('ylim',[0 1]);
g(1,2).geom_hline('yintercept',0.5,'style','k:');
g(1,2).set_names('x','Trial number','y','p(Right) (20 trial av.)');
g(1,2).set_title('Right choices over time');

g(2,2) = gramm('x',b.trialNumber,'y', movmean(b.feedback == 'Rewarded', 20),'color',b.choice);
g(2,2).geom_line();
g(2,2).axe_property('ylim',[0 1]);
g(2,2).geom_hline('yintercept',0.5,'style','k:');
g(2,2).set_names('x','Trial number','y','Accuracy (20 trial av.)', 'color', 'Choice');
g(2,2).set_title('Accuracy over time');

g(3,2) = gramm('x',b.trialNumber,'y', movmedian(b.choiceCompleteTime - b.stimulusOnsetTime, 20), 'color', b.choice, 'subset', goodTrials);
g(3,2).geom_line();
g(3,2).set_names('x','Trial number','y','Response time (good trials, 20 trial median.)', 'color', 'Choice');
g(3,2).set_title('Response time over time (good trials)');

if isempty(channelLabels)
    g.set_layout_options('redraw',true,'redraw_gap',0,'legend_width',0.2);
    figure('color','w','MenuBar','none','position',[364 457 1112 299]);
    g = g';
    g.draw();
else
    
    %get aligned data. 
    photometry = photometryAlign( expRef , 'plot', true, 'numSecToDetrend', 25, 'alignWithRewards', true);

    chans = {'channel1_0G','channel2_2G','channel3_4G','channel4_6G'}; %green filtered channels
    chanRaster = cell(1,4);
    col = 3;
    for c = 1:4
        if ~isempty(channelLabels{c})
            
            dff_warped = interp1(photometry.Timestamp,photometry.(chans{c}),warp_samples);
            dff_warped = dff_warped - mean(dff_warped(:,1:warp_sizes(1),:),2);
            
            if sum(b.contrastLeft==0 & b.contrastRight==0) > 0 
                g(1,col) = gramm('x',1:sum(warp_sizes),'y',dff_warped,'color',b.feedback,'subset',b.contrastLeft==0 & b.contrastRight==0);
                g(1,col).set_title({channelLabels{c}, 'C=0 trials, separated by outcome'});
                g(2,col).set_color_options('map',0.9*RedWhiteBlue(floor(length(unique(b.contrastRight-b.contrastLeft))/2)));
            else
                disp('No zero contrast trials found. Plotting all trials by feedback.')
                g(1,col) = gramm('x',1:sum(warp_sizes),'y',dff_warped,'color',b.feedback);
                g(1,col).set_title({channelLabels{c}, 'All trials, separated by outcome'});
            end
            
            g(1,col).stat_summary('setylim','true');
            g(1,col).geom_vline('xintercept',cumsum(warp_sizes(1:3)),'style','k:');
            g(1,col).set_names('x','','y','z-score & 95% CI');
            
            g(2,col) = gramm('x',1:sum(warp_sizes),'y',dff_warped,'color',b.contrastRight-b.contrastLeft,'subset',b.feedback=='Rewarded');
            g(2,col).stat_summary('setylim','true');
            g(2,col).geom_vline('xintercept',cumsum(warp_sizes(1:3)),'style','k:');
            g(2,col).set_names('x','','y','z-score & 95% CI');
            g(2,col).set_title('Correct trials, separated by contrast');
            g(:,col).axe_property('xtick','','xcolor','none');
            
            g(3,col) = gramm('x',1000,'y',1000);
            g(3,col).set_title('All rewarded trials');
            g(3,col).set_names('x','Reward onset','y','');
            
            t_sample_rew = linspace(-0.5,1,100);
            dff_rew = interp1(photometry.Timestamp, photometry.(chans{c}), b.rewardTime+ t_sample_rew);
            chanRaster{c} = dff_rew(~isnan(dff_rew(:,1)),:);
%             chanRaster{c} = chanRaster{c} - mean(chanRaster{c}(:,t_sample_rew<0),2);
            
            col = col+1;
        end
    end
    
    g.set_layout_options('redraw',true,'redraw_gap',0,'legend_width',0.2);
    figure('color','w','MenuBar','none','position',[258 121 1338 873]); g.draw();
    
    %add rasters
    col = 3;    
    for c = 1:4
        if ~isempty(channelLabels{c})
            imagesc(g(3,col).facet_axes_handles, t_sample_rew, 1:sum(~isnan(b.rewardTime)), chanRaster{c});
            set(g(3,col).facet_axes_handles,'xlim',[-0.5 1],'ylim',[0 sum(~isnan(b.rewardTime))],'ydir','reverse');
            xline(g(3,col).facet_axes_handles,0);
            col = col+1;
        end
    end

end
end









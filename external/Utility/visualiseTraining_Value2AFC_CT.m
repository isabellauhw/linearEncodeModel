function visualiseTraining_Value2AFC_CT(expRef,dataProfile,channelLabels)


% expRef = ['2022-04-14_2_DAP076'];
% fiber_where = 'Left mPFC'
% try
D = getBehavData(expRef, dataProfile);
% catch 
%     dataProfile = 'Value2AFC_noTimeline'
%     D = getBehavData(expRef, dataProfile);
% end

%animal = 'DAP076'
%mkdir(['\\QNAP-AL001.dpag.ox.ac.uk\CToschi\DATA\' animal '\value2AFC\'])
%Figure_path = ['\\QNAP-AL001.dpag.ox.ac.uk\CToschi\DATA\' animal '\value2AFC\']


% extract relevant data

    % Label value conditions and trial types
    for i = 1 : height(D)

        if isequal(D.stimulusLeftPayoff(i, :), [0 0])
            D.stim_pres(i) = {'Right'};
        else
            D.stim_pres(i) = {'Left'};
        end

        if isequal(D.stimulusLeftPayoff(i, :), [0 0])
            D.valueLeft(i) = {'Zero'};
            D.stimulusLeftNum(i) = 0;
        elseif isequal(D.stimulusLeftPayoff(i, :), [1.5 1.5]) || isequal(D.stimulusLeftPayoff(i, :), [1.7 1.7])
            D.valueLeft(i) = {'MediumSafe'};
            D.stimulusLeftNum(i) = 1.5;
        elseif isequal(D.stimulusLeftPayoff(i, :), [3 3])
            D.valueLeft(i) = {'LargeSafe'};
            D.stimulusLeftNum(i) = 3;
        elseif isequal(D.stimulusLeftPayoff(i,  :), [0 3]) || isequal(D.stimulusLeftPayoff(i,  :), [3 0])
            D.valueLeft(i) = {'ProbLarge'};
            D.stimulusLeftNum(i) = 2;
        elseif isequal(D.stimulusLeftPayoff(i,  :), [0 1.5]) || isequal(D.stimulusLeftPayoff(i,  :), [1.5 0]) || isequal(D.stimulusLeftPayoff(i,  :), [0 1.7]) || isequal(D.stimulusLeftPayoff(i,  :), [1.7 0]) 
            D.valueLeft(i) = {'ProbSmall'};
            D.stimulusLeftNum(i) = 1;
        else
            D.valueLeft(i) = {'Unclassified'};
            warning('Unclassified value on left side!');
        end

        if isequal(D.stimulusRightPayoff(i, :), [0 0])
            D.valueRight(i) = {'Zero'};
            D.stimulusRightNum(i) = 0;
        elseif isequal(D.stimulusRightPayoff(i, :), [1.5 1.5]) || isequal(D.stimulusRightPayoff(i, :), [1.7 1.7])
            D.valueRight(i) = {'MediumSafe'};
             D.stimulusRightNum(i) = 1.5;
        elseif isequal(D.stimulusRightPayoff(i, :), [3 3])
            D.valueRight(i) = {'LargeSafe'};
             D.stimulusRightNum(i) = 3;
        elseif isequal(D.stimulusRightPayoff(i,:), [0 3]) || isequal(D.stimulusRightPayoff(i,:), [3 0])
            D.valueRight(i) = {'ProbLarge'};
             D.stimulusRightNum(i) = 2;
        elseif isequal(D.stimulusRightPayoff(i,  :), [0 1.5]) || isequal(D.stimulusRightPayoff(i,  :), [1.5 0]) || isequal(D.stimulusRightPayoff(i,  :), [0 1.7]) || isequal(D.stimulusRightPayoff(i,  :), [1.7 0]) 
            D.valueRight(i) = {'ProbSmall'};
            D.stimulusRightNum(i) = 1;
        else
            D.valueRight(i) = {'Unclassified'};
            warning('Unclassified value on left side!');
        end

        if D.rewardVolume(i)>0
           D.feedback(i) = {'Rewarded'};
        else D.feedback(i) = {'Unrewarded'};
        end

        if isequal(D.stimulusRightPayoff(i,:), [3 3]) || isequal(D.stimulusLeftPayoff(i,:), [3 3]) || isequal(D.stimulusRightPayoff(i,:), [0 3]) || isequal(D.stimulusRightPayoff(i,:), [3 0]) || isequal(D.stimulusLeftPayoff(i,:), [0 3]) || isequal(D.stimulusLeftPayoff(i,:), [3 0]) 
            D.value(i) = {'LargeReward'};
            D.stimulus(i) = {'Gratings'};
        elseif isequal(D.stimulusRightPayoff(i,:), [1.5 1.5]) || isequal(D.stimulusLeftPayoff(i,:), [1.5 1.5]) || isequal(D.stimulusRightPayoff(i,:), [1.7 1.7]) || isequal(D.stimulusLeftPayoff(i,:), [1.7 1.7]) || ...
                isequal(D.stimulusRightPayoff(i,:), [0 1.5]) || isequal(D.stimulusRightPayoff(i,:), [1.5 0]) || isequal(D.stimulusLeftPayoff(i,:), [1.5 0]) || isequal(D.stimulusLeftPayoff(i,:), [0 1.5]) || isequal(D.stimulusRightPayoff(i,:), [0 1.7]) ||...
                isequal(D.stimulusRightPayoff(i,:), [1.7 0]) || isequal(D.stimulusLeftPayoff(i,:), [1.7 0]) || isequal(D.stimulusLeftPayoff(i,:), [0 1.7]);
            D.value(i) = {'SmallReward'};
            D.stimulus(i) = {'Cross'};
        end 


%         if isequal(D.stimulusRightPayoff(i,:), [3 0]) || isequal(D.stimulusRightPayoff(i,:), [0 3]) & D.choice(i,:) == 'Right' & ~isnan(D.rewardVolume(i,:))
%             D.type(i) = {'Corr L-R'}; %correct right stim, large rewarded
%             D.Correct(i) = {'Yes'};
%             D.type2(i) = {'Corr R'};
%            
%         elseif isequal(D.stimulusRightPayoff(i,:), [1.5 0]) || isequal(D.stimulusRightPayoff(i,:), [0 1.5]) || isequal(D.stimulusRightPayoff(i,:), [1.7 0]) || isequal(D.stimulusRightPayoff(i,:), [0 1.7]) & D.choice(i,:) == 'Right' & ~isnan(D.rewardVolume(i,:))
%              D.type(i) = {'Corr S-R'};  %correct right stim, small rewarded
%              D.Correct(i) = {'Yes'};
%              D.type2(i) = {'Corr R'};
%              
%         elseif isequal(D.stimulusRightPayoff(i,:), [1.5 0]) || isequal(D.stimulusRightPayoff(i,:), [0 1.5]) || isequal(D.stimulusRightPayoff(i,:), [1.7 0]) || isequal(D.stimulusRightPayoff(i,:), [0 1.7]) & D.choice(i,:) == 'Right' & isnan(D.rewardVolume(i,:))
%              D.type(i) = {'Corr S-NR'};  %correct right stim, small non-rewarded
%              D.Correct(i) = {'Yes'};
%              D.type2(i) = {'Corr NR'};
%              
%         elseif isequal(D.stimulusRightPayoff(i,:), [3 0]) || isequal(D.stimulusRightPayoff(i,:), [0 3]) & D.choice(i,:) == 'Right' & isnan(D.rewardVolume(i,:))
%              D.type(i) = {'Corr L-NR'};  %correct right stim, large non-rewarded
%              D.Correct(i) = {'Yes'};
%              D.type2(i) = {'Corr NR'};
%             
%         elseif isequal(D.stimulusRightPayoff(i,:), [1.5 0]) || isequal(D.stimulusRightPayoff(i,:), [0 1.5]) || isequal(D.stimulusRightPayoff(i,:), [1.7 0]) || isequal(D.stimulusRightPayoff(i,:), [0 1.7]) & D.choice(i,:) ~= 'Right' 
%              D.type(i) = {'Incorr S'};  %incorrect right stim, small non-rewarded
%              D.Correct(i) = {'No'};
%              D.type2(i) = {'Incorr'};
%              
%         elseif isequal(D.stimulusRightPayoff(i,:), [3 0]) || isequal(D.stimulusRightPayoff(i,:), [0 3]) & D.choice(i,:) ~= 'Right' 
%              D.type(i) = {'Incorr L'};  %incorrect right stim, large non-rewarded
%              D.Correct(i) = {'No'};
%               D.type2(i) = {'Incorr'};
%              
%             
%         elseif isequal(D.stimulusLeftPayoff(i,:), [3 0]) || isequal(D.stimulusLeftPayoff(i,:), [0 3]) & D.choice(i,:) == 'Left' & ~isnan(D.rewardVolume(i,:))
%             D.type(i) = {'Corr L-R'}; %correct left stim, large rewarded
%             D.Correct(i) = {'Yes'};
%             D.type2(i) = {'Corr R'};
%             
%         elseif isequal(D.stimulusLeftPayoff(i,:), [1.5 0]) || isequal(D.stimulusLeftPayoff(i,:), [0 1.5]) || isequal(D.stimulusLeftPayoff(i,:), [1.7 0]) || isequal(D.stimulusLeftPayoff(i,:), [0 1.7]) & D.choice(i,:) == 'Left' & ~isnan(D.rewardVolume(i,:))
%              D.type(i) = {'Corr S-R'};  %correct left stim, small rewarded
%              D.Correct(i) = {'Yes'};
%              D.type2(i) = {'Corr R'};
%              
%         elseif isequal(D.stimulusLeftPayoff(i,:), [1.5 0]) || isequal(D.stimulusLeftPayoff(i,:), [0 1.5]) || isequal(D.stimulusLeftPayoff(i,:), [1.7 0]) || isequal(D.stimulusLeftPayoff(i,:), [0 1.7]) & D.choice(i,:) == 'Left' & isnan(D.rewardVolume(i,:))
%              D.type(i) = {'Corr S-NR'};  %correct left stim, small non-rewarded
%              D.Correct(i) = {'Yes'};
%              D.type2(i) = {'Corr NR'};
%              
%         elseif isequal(D.stimulusLeftPayoff(i,:), [3 0]) || isequal(D.stimulusLeftPayoff(i,:), [0 3]) & D.choice(i,:) == 'Left' & isnan(D.rewardVolume(i,:))
%              D.type(i) = {'Corr L-NR'};  %correct left stim, large non-rewarded
%              D.Correct(i) = {'Yes'};
%              D.type2(i) = {'Corr NR'};
%             
%         elseif isequal(D.stimulusLeftPayoff(i,:), [1.5 0]) || isequal(D.stimulusLeftPayoff(i,:), [0 1.5]) || isequal(D.stimulusLeftPayoff(i,:), [1.7 0]) || isequal(D.stimulusLeftPayoff(i,:), [0 1.7]) & D.choice(i,:) ~= 'Left' 
%              D.type(i) = {'Incorr S'};  %incorrect left stim, small non-rewarded
%              D.Correct(i) = {'No'};
%              D.type2(i) = {'Incorr'};
%             
%         elseif isequal(D.stimulusLeftPayoff(i,:), [3 0]) || isequal(D.stimulusLeftPayoff(i,:), [0 3]) & D.choice(i,:) ~= 'Left' 
%              D.type(i) = {'Incorr L'};  %incorrect left stim, large non-rewarded
%              D.Correct(i) = {'No'};
%              D.type2(i) = {'Incorr'};
%              
%         else
%         end



 end 



    
    D.cDiff = D.stimulusRightNum-D.stimulusLeftNum;
    totalNumTrials = height(D);
    
    
    
%     if sum(strcmp('value', D.Properties.VariableNames))==1 %does this column exist?
%         D.value = categorical(D.value);
%     else
%     end

    D.value = categorical(D.value);
    D.stimulus = categorical(D.stimulus);
    D.feedback = categorical(D.feedback);
    
    
    D.stim_pres = categorical(D.stim_pres);
    
    

%     if sum(ismember(D.Properties.VariableNames,'Correct')) == 1 %do this only if the column Correct exists
%     D.Correct = categorical(D.Correct);
%     D.type = categorical(D.type); 
%     D.type2 = categorical(D.type2); 
%     else
%     end

    if sum(strcmp(D.valueLeft, 'ProbLarge'))>=1 || sum(strcmp(D.valueLeft, 'ProbSmall'))>=1 
       accuracy_LargeRew = sum(D.value=='LargeReward' & D.Correct=='Yes')/sum(D.value=='LargeReward');
       accuracy_SmallRew = sum(D.value=='SmallReward' & D.Correct=='Yes')/sum(D.value=='SmallReward');

       accuracy_right = sum(D.stim_pres=='Right' & D.Correct=='Yes')/sum(D.stim_pres=='Right');
       accuracy_left = sum(D.stim_pres=='Left' & D.Correct=='Yes')/sum(D.stim_pres=='Left');
       goodTrials = D.repeatNumber==1 & D.Correct=='Yes';
       accuracy = sum(D.Correct=='Yes')/totalNumTrials;

    else  
       accuracy_LargeRew = sum(D.value=='LargeReward' & D.rewardVolume>0)/sum(D.value=='LargeReward');
       accuracy_SmallRew = sum(D.value=='SmallReward' & D.rewardVolume>0)/sum(D.value=='SmallReward');

       accuracy_right = sum(D.stim_pres=='Right' & D.rewardVolume>0)/sum(D.stim_pres=='Right');
       accuracy_left = sum(D.stim_pres=='Left' & D.rewardVolume>0)/sum(D.stim_pres=='Left');
       goodTrials = D.repeatNumber==1 & D.rewardVolume>0;
       accuracy = sum(D.rewardVolume>0)/totalNumTrials;
    end
   
    
    D.RT = D.choiceCompleteTime - D.stimulusOnsetTime;
    
   
    % photometry
    t_sample_epoch = linspace(-0.5,3,200);


    %Define warp times
    warp_sizes = [50,100,20,100]; %number of elements for each epoch: pre-stim, stim-choice, choice-outcome, post-outcome
    if sum(warp_sizes) == length(D.choice) %This addresses a bug which happens later if the number of trials = number of warp timepoints
        warp_sizes = warp_sizes+1;
    end
    
    D.outcomeTime = nanmean([D.rewardTime D.punishSoundOnsetTime],2);
    
    %get time-warped activity for each trial
    warp_samples = nan(length(D.choice), sum(warp_sizes));
    for tr = 1:length(D.choice)
        epoch1 = linspace(D.stimulusOnsetTime(tr)-0.5, D.stimulusOnsetTime(tr), warp_sizes(1));
        epoch2 = linspace(D.stimulusOnsetTime(tr), D.choiceStartTime(tr), warp_sizes(2));
        epoch3 = linspace(D.choiceStartTime(tr), D.outcomeTime(tr), warp_sizes(3));
        epoch4 = linspace(D.outcomeTime(tr), D.outcomeTime(tr)+2, warp_sizes(4));
        warp_samples(tr,:) = [epoch1, epoch2, epoch3, epoch4];
    end
    
    
    block = dat.loadBlock(expRef);
    wheel_warped = interp1(block.inputs.wheelMMTimes, block.inputs.wheelMMValues, warp_samples);
    wheel_warped = wheel_warped - mean(wheel_warped(:,1:warp_sizes(1),:),2);
    
    % get the photometry data 

    bl = dat.loadBlock(expRef);

  chans = {'channel1_0G','channel2_2G','channel3_4G','channel4_6G'}; %green filtered channels

  


  D.stim_pres = string(D.stim_pres);   
  clear g 
  
if strcmp(unique(D.stim_pres), 'Left')

n=1
m=1
% g(1,2) = gramm('x',b.trialNumber,'y', cumsum(b.choice == 'Right')./b.trialNumber,'subset',goodTrials);
g(n,m) = gramm('x',D.trialNumber,'y', movmean(D.feedback == 'Rewarded', 10), 'subset', D.stim_pres=='Left');
g(n,m).geom_line();
g(n,m).axe_property('ylim',[0 1]);
g(n,m).geom_hline('yintercept',0.5,'style','k:');
g(n,m).set_names('x','Trial number','y','p(Correct) (10 trial av.)');
g(n,m).set_title('Rewarded choices over time');


n=1
m=2
g(n,m) = gramm('x',D.feedback,'y',D.choiceCompleteTime - D.stimulusOnsetTime,'color',D.feedback,'subset', D.stim_pres=='Left');
g(n,m).stat_summary('geom',{'bar','black_errorbar'}, 'dodge', 0.6, 'width', 0.5)
g(n,m).set_names('x','Contrast','y','RTs','color','Feedback');
g(n,m).set_title(sprintf('%s\n%d good trials, %d total trials\nAccuracy: %0.2f \n stim presented = Left',expRef,sum(goodTrials),totalNumTrials,accuracy_left));



       if all(cellfun(@isempty, channelLabels)) %if channels don't have labels           
         g.set_layout_options('redraw',true,'redraw_gap',0,'legend_width',0.2);
         figure('color','w','MenuBar','none','Position',[364 457 1112 299]);
         g.draw();
      
       else
           photometry = photometryAlign(expRef, 'numSecToDetrend', 25, 'alignWithRewards', true, 'plot', true);
            
           for y = 1:4
               if ~isempty(channelLabels{y})

                   dff = interp1(photometry.Timestamp,photometry.(chans{y}),warp_samples); %channel3_4G if you're using Pstim 1 and channel2_2G if you're using Pstim 2
                   baseline = dff(:,1:warp_sizes(1),:);
                   %dff_warped = interp1(photometry.Timestamp,photometry.channel2_2G,warp_samples);
                   dff_warped = dff - nanmean(baseline,2);
                   F_at_stim = interp1(photometry.Timestamp,photometry.(chans{y}), D.stimulusOnsetTime + t_sample_epoch);
                   F_at_outcome = interp1(photometry.Timestamp,photometry.(chans{y}), D.outcomeTime + t_sample_epoch);


                   %b.laserMode = categorical(b.laserMode);
                   D.([channelLabels{y} '_F_event']) = dff_warped;
                   D.([channelLabels{y} '_F_change']) = nanmean(dff_warped(:,warp_sizes(1):sum(warp_sizes)),2);
                   D.([channelLabels{y} 'F_at_stim']) = F_at_stim - nanmean(baseline,2);
                   D.([channelLabels{y} 'F_at_outcome']) = F_at_outcome - nanmean(baseline,2);       
       


                   n=1
                   m=3
                   g(n,m) = gramm('x',1:200,'y',D.([channelLabels{y} 'F_at_stim']),'color',D.feedback, 'column', D.value ,'subset', D.stim_pres=='Left')
                   g(n,m).set_layout_options('legend', false);
                   g(n,m).stat_summary('setylim','true');
                   %g(n,m).axe_property('ylim',val_y_1);
                   g(n,m).geom_vline('xintercept',30,'style','k:');
                   g(n,m).axe_property('XTickLabel',{'-0.5s', '0', '0.5s', '1s', '2s', '3s'}, 'XTick', [0 30 87 144 200]) %'TickDir', 45); % We deactivate tht ticks
                   g(n,m).set_names('x','','y','z-score & 95% CI', 'color', 'Feedback');
                   %g(n,m).axe_property('XTickLabel',{'Left', 'Right'}, 'XTick', [-3 3]); % We deactivate tht ticks
                   g(n,m).set_title('F at stim');



                   n=2
                   m=1
                   g(n,m) = gramm('x',1:sum(warp_sizes),'y',D.([channelLabels{y} '_F_event']),'color',D.feedback, 'column', D.value ,'subset', D.stim_pres=='Left')
                   g(n,m).set_layout_options('legend', false);
                   g(n,m).stat_summary('setylim','true');
                   %g(n,m).axe_property('ylim',val_y_1);
                   g(n,m).geom_vline('xintercept',cumsum(warp_sizes(1:3)),'style','k:');
                   g(n,m).axe_property('XTickLabel',{'S', 'C', 'R'}, 'XTick', [50 150 170]) %'TickDir', 45); % We deactivate tht ticks
                   g(n,m).set_names('x','','y','z-score & 95% CI', 'color', 'Feedback');
                   %g(n,m).axe_property('XTickLabel',{'Left', 'Right'}, 'XTick', [-3 3]); % We deactivate tht ticks
                   g(n,m).set_title('F signal time-warped');

                   n=2
                   m=2
                   % g(1,2) = gramm('x',b.trialNumber,'y', cumsum(b.choice == 'Right')./b.trialNumber,'subset',goodTrials);
                   g(n,m) = gramm('x',D.trialNumber,'y', D.([channelLabels{y} '_F_change']), 'color', D.feedback, 'subset', D.stim_pres=='Left');
                   g(n,m).geom_point();
                   %g(n,m).axe_property('ylim',[0 1]);
                   g(n,m).geom_hline('yintercept',0,'style','k:');
                   g(n,m).set_names('x','Trial number','y','Df/f baselined over prior stim');
                   g(n,m).set_title('Change in signal over time');

                   n=2
                   m=3
                   g(n,m) = gramm('x',1:200,'y',D.([channelLabels{y} 'F_at_outcome']),'color',D.feedback, 'column', D.value ,'subset', D.stim_pres=='Left')
                   g(n,m).set_layout_options('legend', false);
                   g(n,m).stat_summary('setylim','true');
                   %g(n,m).axe_property('ylim',val_y_1);
                   g(n,m).geom_vline('xintercept',30,'style','k:');
                   g(n,m).axe_property('XTickLabel',{'-0.5s', '0', '0.5s', '1s', '2s', '3s'}, 'XTick', [0 30 58 87 144 200]) %'TickDir', 45); % We deactivate tht ticks
                   g(n,m).set_names('x','','y','z-score & 95% CI', 'color', 'Feedback');
                   %g(n,m).axe_property('XTickLabel',{'Left', 'Right'}, 'XTick', [-3 3]); % We deactivate tht ticks
                   g(n,m).set_title('F at outcome');

                   %g.set_title(sprintf('%s\n%d good trials, %d total trials\nAccuracy: %0.2f \n stim presented = Left',expRef,goodTrials,totalNumTrials,accuracy_left));
                   figure('Position',[139.6667 179 2.0567e+03 1.1367e+03]);
                   g.draw();
              
               else                  
               end

           end
              
      
       end

       

else
  

n=1
m=1
% g(1,2) = gramm('x',b.trialNumber,'y', cumsum(b.choice == 'Right')./b.trialNumber,'subset',goodTrials);
g(n,m) = gramm('x',D.trialNumber,'y', movmean(D.feedback == 'Rewarded', 10), 'subset', D.stim_pres=='Right');
g(n,m).geom_line();
g(n,m).axe_property('ylim',[0 1]);
g(n,m).geom_hline('yintercept',0.5,'style','k:');
g(n,m).set_names('x','Trial number','y','p(Correct) (10 trial av.)');
g(n,m).set_title('Rewarded choices over time');


n=1
m=2
g(n,m) = gramm('x',D.feedback,'y',D.choiceCompleteTime - D.stimulusOnsetTime,'color',D.feedback,'subset', D.stim_pres=='Right');
g(n,m).stat_summary('geom',{'bar','black_errorbar'}, 'dodge', 0.6, 'width', 0.5)
g(n,m).set_names('x','Contrast','y','RTs','color','Feedback');
g(n,m).set_title(sprintf('%s\n%d good trials, %d total trials\nAccuracy: %0.2f \n stim presented = Right',expRef,sum(goodTrials),totalNumTrials,accuracy_right));


       if all(cellfun(@isempty, channelLabels)) %if channels don't have labels           
         g.set_layout_options('redraw',true,'redraw_gap',0,'legend_width',0.2);
         figure('color','w','MenuBar','none','Position',[364 457 1112 299]);
         g.draw();
      
       else
           photometry = photometryAlign(expRef, 'numSecToDetrend', 25, 'alignWithRewards', true, 'plot', true);
            
           for y = 1:4
               if ~isempty(channelLabels{y})

                   dff = interp1(photometry.Timestamp,photometry.(chans{y}),warp_samples); %channel3_4G if you're using Pstim 1 and channel2_2G if you're using Pstim 2
                   baseline = dff(:,1:warp_sizes(1),:);
                   %dff_warped = interp1(photometry.Timestamp,photometry.channel2_2G,warp_samples);
                   dff_warped = dff - nanmean(baseline,2);
                   F_at_stim = interp1(photometry.Timestamp,photometry.(chans{y}), D.stimulusOnsetTime + t_sample_epoch);
                   F_at_outcome = interp1(photometry.Timestamp,photometry.(chans{y}), D.outcomeTime + t_sample_epoch);


                   %b.laserMode = categorical(b.laserMode);
                   D.([channelLabels{y} '_F_event']) = dff_warped;
                   D.([channelLabels{y} '_F_change']) = nanmean(dff_warped(:,warp_sizes(1):sum(warp_sizes)),2);
                   D.([channelLabels{y} 'F_at_stim']) = F_at_stim - nanmean(baseline,2);
                   D.([channelLabels{y} 'F_at_outcome']) = F_at_outcome - nanmean(baseline,2);       
       


                   n=1
                   m=3
                   g(n,m) = gramm('x',1:200,'y',D.([channelLabels{y} 'F_at_stim']),'color',D.feedback, 'column', D.value ,'subset', D.stim_pres=='Right')
                   g(n,m).set_layout_options('legend', false);
                   g(n,m).stat_summary('setylim','true');
                   %g(n,m).axe_property('ylim',val_y_1);
                   g(n,m).geom_vline('xintercept',30,'style','k:');
                   g(n,m).axe_property('XTickLabel',{'-0.5s', '0', '0.5s', '1s', '2s', '3s'}, 'XTick', [0 30 87 144 200]) %'TickDir', 45); % We deactivate tht ticks
                   g(n,m).set_names('x','','y','z-score & 95% CI', 'color', 'Feedback');
                   %g(n,m).axe_property('XTickLabel',{'Left', 'Right'}, 'XTick', [-3 3]); % We deactivate tht ticks
                   g(n,m).set_title('F at stim');



                   n=2
                   m=1
                   g(n,m) = gramm('x',1:sum(warp_sizes),'y',D.([channelLabels{y} '_F_event']),'color',D.feedback, 'column', D.value ,'subset', D.stim_pres=='Right')
                   g(n,m).set_layout_options('legend', false);
                   g(n,m).stat_summary('setylim','true');
                   %g(n,m).axe_property('ylim',val_y_1);
                   g(n,m).geom_vline('xintercept',cumsum(warp_sizes(1:3)),'style','k:');
                   g(n,m).axe_property('XTickLabel',{'S', 'C', 'R'}, 'XTick', [50 150 170]) %'TickDir', 45); % We deactivate tht ticks
                   g(n,m).set_names('x','','y','z-score & 95% CI', 'color', 'Feedback');
                   %g(n,m).axe_property('XTickLabel',{'Left', 'Right'}, 'XTick', [-3 3]); % We deactivate tht ticks
                   g(n,m).set_title('F signal time-warped');

                   n=2
                   m=2
                   % g(1,2) = gramm('x',b.trialNumber,'y', cumsum(b.choice == 'Right')./b.trialNumber,'subset',goodTrials);
                   g(n,m) = gramm('x',D.trialNumber,'y', D.([channelLabels{y} '_F_change']), 'color', D.feedback, 'subset', D.stim_pres=='Right');
                   g(n,m).geom_point();
                   %g(n,m).axe_property('ylim',[0 1]);
                   g(n,m).geom_hline('yintercept',0,'style','k:');
                   g(n,m).set_names('x','Trial number','y','Df/f baselined over prior stim');
                   g(n,m).set_title('Change in signal over time');

                   n=2
                   m=3
                   g(n,m) = gramm('x',1:200,'y',D.([channelLabels{y} 'F_at_outcome']),'color',D.feedback, 'column', D.value ,'subset', D.stim_pres=='Right')
                   g(n,m).set_layout_options('legend', false);
                   g(n,m).stat_summary('setylim','true');
                   %g(n,m).axe_property('ylim',val_y_1);
                   g(n,m).geom_vline('xintercept',30,'style','k:');
                   g(n,m).axe_property('XTickLabel',{'-0.5s', '0', '0.5s', '1s', '2s', '3s'}, 'XTick', [0 30 58 87 144 200]) %'TickDir', 45); % We deactivate tht ticks
                   g(n,m).set_names('x','','y','z-score & 95% CI', 'color', 'Feedback');
                   %g(n,m).axe_property('XTickLabel',{'Left', 'Right'}, 'XTick', [-3 3]); % We deactivate tht ticks
                   g(n,m).set_title('F at outcome');

                   %g.set_title(sprintf('%s\n%d good trials, %d total trials\nAccuracy: %0.2f \n stim presented = Left',expRef,goodTrials,totalNumTrials,accuracy_left));
                   figure('Position',[139.6667 179 2.0567e+03 1.1367e+03]);
                   g.draw();
              
               else                  
               end

           end
              
      
       end

end






   
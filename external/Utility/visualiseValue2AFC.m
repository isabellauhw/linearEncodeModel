function visualiseValue2AFC(expRef, dataProfile)
% VISUALISE VALUE2AFC Plot the results of a Value2AFC experiment
%   visualiseValue2AFC(expRef, dataProfile) plots the experiment expRef
%   with data profile dataProfile
%
%   See also VISUALISETRAININGGRATING2AFC

    D = getBehavData(expRef, dataProfile);

    % Label value conditions and trial types
    for i = 1 : height(D)

        if isequal(D.stimulusLeftPayoff(i, :), [0 0])
            D.valueLeft(i) = {'Zero'};
        elseif isequal(D.stimulusLeftPayoff(i, :), [1.5 1.5])
            D.valueLeft(i) = {'MediumSafe'};
        elseif isequal(D.stimulusLeftPayoff(i, :), [3 3])
            D.valueLeft(i) = {'LargeSafe'};
        elseif isequal(D.stimulusLeftPayoff(i,  :), [0 3]) || isequal(D.stimulusLeftPayoff(i,  :), [3 0])
            D.valueLeft(i) = {'Gamble'};
        else
            D.valueLeft(i) = {'Unclassified'};
            warning('Unclassified value on left side!');
        end

        if isequal(D.stimulusRightPayoff(i, :), [0 0])
            D.valueRight(i) = {'Zero'};
        elseif isequal(D.stimulusRightPayoff(i, :), [1.5 1.5])
            D.valueRight(i) = {'MediumSafe'};
        elseif isequal(D.stimulusRightPayoff(i, :), [3 3])
            D.valueRight(i) = {'LargeSafe'};
        elseif isequal(D.stimulusRightPayoff(i,:), [0 3]) || isequal(D.stimulusRightPayoff(i,:), [3 0])
            D.valueRight(i) = {'Gamble'};
        else
            D.valueRight(i) = {'Unclassified'};
            warning('Unclassified value on left side!');
        end

        if (isequal(D.valueLeft(i), {'Zero'}) && isequal(D.valueRight(i), {'MediumSafe'})) || (isequal(D.valueRight(i), {'Zero'}) && isequal(D.valueLeft(i), {'MediumSafe'}))
            D.trialType(i) = {'MediumSafe_Imperative'};
        elseif (isequal(D.valueLeft(i), {'Zero'}) && isequal(D.valueRight(i), {'LargeSafe'})) || (isequal(D.valueRight(i), {'Zero'}) && isequal(D.valueLeft(i), {'LargeSafe'}))
            D.trialType(i) = {'LargeSafe_Imperative'};
        elseif (isequal(D.valueLeft(i), {'Zero'}) && isequal(D.valueRight(i), {'Gamble'})) || (isequal(D.valueRight(i), {'Zero'}) && isequal(D.valueLeft(i), {'Gamble'}))
            D.trialType(i) = {'Gamble_Imperative'};
        elseif (isequal(D.valueLeft(i), {'LargeSafe'}) && isequal(D.valueRight(i), {'MediumSafe'})) || (isequal(D.valueRight(i), {'LargeSafe'}) && isequal(D.valueLeft(i), {'MediumSafe'}))
            D.trialType(i) = {'LargeSafe_MediumSafe'};
        elseif (isequal(D.valueLeft(i), {'Gamble'}) && isequal(D.valueRight(i), {'MediumSafe'})) || (isequal(D.valueRight(i), {'Gamble'}) && isequal(D.valueLeft(i), {'MediumSafe'}))
            D.trialType(i) = {'MediumSafe_Gamble'};
        elseif (isequal(D.valueLeft(i), {'Gamble'}) && isequal(D.valueRight(i), {'LargeSafe'})) || (isequal(D.valueRight(i), {'Gamble'}) && isequal(D.valueLeft(i), {'LargeSafe'}))
            D.trialType(i) = {'LargeSafe_Gamble'};
        else
            D.trialType(i) = {'Unclassified'};
            warning('Unclassified trial type!')
        end

    end

    D.expectedValueLeft = sum(D.stimulusLeftPayoff, 2) / 2;
    D.expectedValueRight = sum(D.stimulusRightPayoff, 2) / 2;
    
    % Ensure string types are categorical to work nicely with gramm
    D.valueLeft = categorical(D.valueLeft);
    D.valueRight = categorical(D.valueRight);
    D.trialType = categorical(D.trialType);

    % Transform choseLeft and choseRight into numeric values for summary
    % statistics
    D.choseLeft = D.choice == 'Left';
    D.choseRight = D.choice == 'Right';

    D.reactionTime = D.choiceCompleteTime - D.stimulusOnsetTime;
    
    % Create a summary table for easy plotting
    E = grpstats(D, {'valueLeft', 'valueRight', 'trialType', 'expectedValueLeft', 'expectedValueRight'}, {'mean', 'median'}, 'DataVars', {'choseLeft', 'choseRight', 'reactionTime'});
    E.expectedValue = E.expectedValueRight - E.expectedValueLeft;
    
    
    clear g

    g(1,1) = gramm('x', E.valueLeft, 'y', E.mean_choseLeft, 'label', round(E.mean_choseLeft,2), 'subset', E.valueRight == 'Zero');
    g(1,1).geom_bar();
    g(1,1).axe_property('YLim', [0 1]);
    g(1,1).geom_hline('yintercept', 0.5, 'style', 'k:');
    g(1,1).geom_label('color', 'r', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontName', 'Courier');
    g(1,1).set_names('y', 'p(Left)', 'x', 'Left offer');
    g(1,1).set_title(sprintf('Left imperative trials,\n%d trials',  sum(E(E.valueRight == 'Zero', :).GroupCount)));

    g(1,2) = gramm('x', E.valueRight, 'y', E.mean_choseRight, 'label', round(E.mean_choseRight,2), 'subset', E.valueLeft == 'Zero');
    g(1,2).geom_bar();
    g(1,2).geom_hline('yintercept', 0.5, 'style', 'k:');
    g(1,2).geom_label('color', 'r', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontName', 'Courier');
    g(1,2).axe_property('YLim', [0 1]);
    g(1,2).set_names('y', 'p(Right)', 'x', 'Right offer');
    g(1,2).set_title(sprintf('Right imperative trials,\n%d trials',  sum(E(E.valueLeft == 'Zero', :).GroupCount)));

    g(2,1) = gramm('x', E.valueLeft, 'y', E.mean_choseLeft, 'label', round(E.mean_choseLeft,2), 'subset', E.valueRight == 'Gamble');
    g(2,1).geom_bar();
    g(2,1).axe_property('YLim', [0 1]);
    g(2,1).geom_hline('yintercept', 0.5, 'style', 'k:');
    g(2,1).geom_label('color', 'r', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontName', 'Courier');
    g(2,1).set_names('y', 'p(Left)', 'x', 'Left offer');
    g(2,1).set_title(sprintf('RIGHT gamble,\n%d trials',  sum(E(E.valueRight == 'Gamble', :).GroupCount)));

    g(2,2) = gramm('x', E.valueRight, 'y', E.mean_choseRight, 'label', round(E.mean_choseRight,2), 'subset', E.valueLeft == 'Gamble');
    g(2,2).geom_bar();
    g(2,2).axe_property('YLim', [0 1]);
    g(2,2).geom_hline('yintercept', 0.5, 'style', 'k:');
    g(2,2).geom_label('color', 'r', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontName', 'Courier');
    g(2,2).set_names('y', 'p(Right)', 'x', 'Right offer');
    g(2,2).set_title(sprintf('LEFT gamble,\n%d trials',  sum(E(E.valueLeft == 'Gamble', :).GroupCount)));
    
    g(3,1) = gramm('x', E.valueLeft, 'y', E.mean_choseLeft, 'label', round(E.mean_choseLeft,2), 'subset', E.valueRight == 'MediumSafe');
    g(3,1).geom_bar();
    g(3,1).axe_property('YLim', [0 1]);
    g(3,1).geom_hline('yintercept', 0.5, 'style', 'k:');
    g(3,1).geom_label('color', 'r', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontName', 'Courier');
    g(3,1).set_names('y', 'p(Left)', 'x', 'Left offer');
    g(3,1).set_title(sprintf('RIGHT medium safe\n%d trials',  sum(E(E.valueRight == 'MediumSafe', :).GroupCount)));
    
    g(3,2) = gramm('x', E.valueRight, 'y', E.mean_choseRight, 'label', round(E.mean_choseRight,2), 'subset', E.valueLeft == 'MediumSafe');
    g(3,2).geom_bar();
    g(3,2).axe_property('YLim', [0 1]);
    g(3,2).geom_hline('yintercept', 0.5, 'style', 'k--');
    g(3,2).geom_label('color', 'r', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontName', 'Courier');
    g(3,2).set_names('y', 'p(Right)', 'x', 'Right offer');
    g(3,2).set_title(sprintf('LEFT medium safe\n%d trials',  sum(E(E.valueRight == 'MediumSafe', :).GroupCount)));

    g(1,3) = gramm('x', E.expectedValue, 'y', E.mean_choseRight);
    g(1,3).stat_summary('geom', {'point'});
    g(1,3).stat_summary('geom', {'line'});
    g(1,3).axe_property('YLim', [0 1]);
    g(1,3).geom_hline('yintercept', 0.5, 'style', 'k--');
    g(1,3).set_names('y', 'p(Right)', 'x', 'Expected value');

    g(2,3) = gramm('x', D.reactionTime);
    g(2,3).set_names('x', 'Reaction time (s)');
    g(2,3).stat_bin();
    
    g(3,3) = gramm('x', E.expectedValue, 'y', E.median_reactionTime);
    g(3,3).stat_summary('geom', {'point'});
    g(3,3).stat_summary('geom', {'line'});
    g(3,3).set_names('y', 'Reaction time(s)', 'x', 'Expected value');
    
    figure('Position', [244,110,1182,868]);
    g.set_title(sprintf('%s, %d trials', expRef, height(D)));
    g.draw();
end
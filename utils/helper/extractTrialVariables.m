function vars = extractTrialVariables(trial)
% *extractTrialVariables*: a helper function that that extracts the needed variables for templating
    vars = struct();
    
     % --- Extract choice from cell array ---
    if iscell(trial.choice)
        choiceStr = trial.choice{1};  % Extract from cell
    else
        choiceStr = trial.choice;
    end

    % --- Choice side ---
    if strcmp(choiceStr, 'Left')
        vars.choiceSide = 'L';
    elseif strcmp(choiceStr, 'Right')
        vars.choiceSide = 'R';
    else
        vars.choiceSide = 'Unknown';
    end
    
    % Stimulus side
    contrast = trial.contrast;
    vars.side = 'R';
    if contrast < 0
        vars.side = 'L';
    end

    % Contrast key (stringified & mapped)
    contrastMap = containers.Map({'0','0.0625','0.125','0.25','0.5','1'}, ...
                                 {'0','00625','0125','025','05','1'});
    if contrast == 0
        vars.contrastKey = '0';
    else
        absStr = sprintf('%g', abs(contrast));
        if isKey(contrastMap, absStr)
            vars.contrastKey = contrastMap(absStr);
        else
            vars.contrastKey = 'unknown';
        end
    end
end
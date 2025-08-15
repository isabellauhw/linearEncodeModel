function D = loadIBLdataset()
% This function loads the IBL Behavioural dataset Version 7
% https://doi.org/10.6084/m9.figshare.11636748.v7

iblFile = '\\QNAP-AL001.dpag.ox.ac.uk\Data\compiledDatasets\ibl-behavioral-data-Dec2019.mat';

if ~exist(iblFile,'file') % Compile data if does not exist
    allFiles = dir('C:\Users\Peter Zatka-Haas\Downloads\11636748\ibl-behavior-data-Dec2019\ibl-behavioral-data-Dec2019\**\*\_ibl_trials.choice.npy');
    
    D = table;
    prevMouse = '';
    
    sessNum = 1;
    for sess = 1:length(allFiles)
        fprintf('%d/%d\n', sess, length(allFiles));
        
        d = parseIBLfolder( allFiles(sess).folder );
        
        f = strsplit(allFiles(sess).folder,'\');
        eRef = sprintf('%s_%d_%s', f{11}, str2num(f{12}), f{10});
        d.expRef = repmat({eRef}, height(d), 1);
        d.mouseName = repmat(f(10), height(d), 1);
        
        if strcmp( f(10), prevMouse )
            sessNum = sessNum + 1;
        else
            sessNum = 1;
        end
        d.sessionNum = ones(size(d.choice))*sessNum;
        
        prevMouse = f(10);
        
        D = [D; d];
    end
    
    D = D(:,{'expRef','mouseName','sessionNum','trialNum','contrastLeft','contrastRight','choice','RT','feedback','rewardVolume'});
    save(iblFile,'D');
    
end

%Load dataset
D=load(iblFile,'D');
D = D.D;

end


function D = parseIBLfolder(folder)
% This function loads the .npy files contained within the IBL data format

CL = readNPY(fullfile(folder, '_ibl_trials.contrastLeft.npy'));
CR = readNPY(fullfile(folder, '_ibl_trials.contrastRight.npy'));
CL(isnan(CL))=0;
CR(isnan(CR))=0;
CH = categorical( readNPY(fullfile(folder, '_ibl_trials.choice.npy')), [-1 0 1], {'Right choice','NoGo','Left choice'});
F = categorical( readNPY(fullfile(folder, '_ibl_trials.feedbackType.npy')), [-1 1], {'Unrewarded','Rewarded'});
RW = readNPY(fullfile(folder, '_ibl_trials.rewardVolume.npy'));
TN = (1:length(CH))';

try
    RN = readNPY(fullfile(folder, '_ibl_trials.repNum.npy'));
catch
    RN = zeros(size(CH));
end

try
    responseTimes = readNPY(fullfile(folder, '_ibl_trials.response_times.npy'));
    stimOnTimes = readNPY(fullfile(folder, '_ibl_trials.stimOn_times.npy'));
    RT = responseTimes - stimOnTimes;
    RT(CH=='NoGo')=NaN;
catch
    RT = nan(size(CH));
end

D = table;
D.trialNum = TN;
D.repeatNum = RN;
D.contrastLeft = CL;
D.contrastRight = CR;
D.choice = CH;
D.RT = RT;
D.feedback = F;
D.rewardVolume = RW;

end
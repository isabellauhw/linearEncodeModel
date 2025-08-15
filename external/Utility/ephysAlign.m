function varargout = ephysAlign(type, ephysDir, expRefs)
%   [..] = ephysAlign(type, ephysDir, expRefs)
%   This function performs alignment between ephys and behavioural data.
%   The type of alignment depends on 1) probe type (Phase 3A vs Phase 3B2),
%   2) the number of probes, 3) whether the ephys data is associated with
%   one or multiple expRefs.
%   
%   Input variable 'type' determines what alignment to perform.
%
%   'OneProbeToOneSession': This method returns the ephys data
%       realigned to the timebase of a single session. This is done by
%       matching the reward echos between the two data.
%
%   'MultipleSessionsToOneProbe': This method returns the coefficients
%       required to transform any behavoiural timing signal for each
%       session to the ephys timebase for one probe.
%
%   'MultipleProbesToOneSession': This method returns the collection of
%   ephys data from multiple probes, with each probe aligned to the
%   timebase of the single session. NOTE: This has not been coded yet.
%
%   'MultipleSessionsToMultipleProbes: This method aligns the timebase for
%   all probes to the timebase of the first probe and returns that ephys data. 
%   Then the method returns the collection of behavioural sessions with the timebases 
%   corrected to the 1st probe's timebase. NOTE: This has not been coded yet.

%check for spikes toolbox
assert(~isempty(which('loadKSdir')),'Please install the spikes toolbox https://github.com/cortex-lab/spikes/');

%check for communications toolbox
assert(~isempty(which('de2bi')),'Please install the MATLAB communications toolbox');

switch (type)
    case 'OneProbeToOneSession'
        assert(ischar(expRefs),'input should be a string with a single expRef');
        probe2block = OneProbeToOneSession(ephysDir,expRefs);
        varargout = {probe2block};
        
    case 'MultipleSessionsToOneProbe'
        blocks2probe = MultipleSessionsToOneProbe(ephysDir, expRefs);
        varargout = {blocks2probe};
        
    case {'MultipleProbesToOneSession','MultipleSessionsMultipleProbes'} %Only Phase 3B2 probes
        error('Not coded yet, please ask Peter to do it');
    otherwise
        error('Not handled');
end

end

function probe2block = OneProbeToOneSession(ephysDir,expRef)
%   ephysStruct = getAlignedSpikingData(ephysDir, expRef)
%   Loads and aligns ephys data (kilosort directory) based on reward alignments.
%   TWO MAIN ASSUMPTIONS: 1) One probe of data, 2) Ephys data is associated
%   a single expRef.
%
%   For Phase3A: assumes that the data has 385 channels, and the sync
%   channel is located at position 385. Also assumes that the LFP is
%   sampled at 2500 Hz.

p = inputParser;
addRequired(p,'ephysDir',@isfolder);
addRequired(p,'expRef',@ischar);
parse(p,ephysDir, expRef);

%Get reward echo from ephys
reward_echo_ephys = getRewardEcho(ephysDir);

%Load reward echos from timeline
b = dat.loadBlock(expRef);
if isfield(b,'events') %signals experiment
    reward_echo_behav = getEventTimes(expRef,'reward_echo');
else %choiceworld experiment
    reward_echo_behav = getEventTimes(expRef,'waterValve');
end

%check that the number of echos is the same
assert( length(reward_echo_behav)==length(reward_echo_ephys),...
    '%d timeline reward echos but %d ephys reward echos',length(reward_echo_behav),length(reward_echo_ephys));

%Compute alignment function
fprintf('Aligning probe reward echos to block reward times...\n');
[~,probe2block] = makeCorrection(reward_echo_behav, reward_echo_ephys, true);
end

function behav2probe = MultipleSessionsToOneProbe(ephysDir, expRefs)
%Function realigns the behavioural timestamps from each blockfile to the
%probe timebase.

%1) Load the behavoural data and get reward times from each
numSessions = length(expRefs);
reward_echo_behav = cell(numSessions,1);
for sess = 1:numSessions
    b = dat.loadBlock(expRefs{sess});
    
    %Check for whether the timeline file exists. If not, then use the block
    %file reward echoes. This is not usually recommended however.
    if exist(dat.expFilePath(expRefs{sess}, 'timeline','master'),'file')
        if isfield(b,'events') %signals experiment
            reward_echo_behav{sess} = getEventTimes(expRefs{sess},'reward_echo');
        else %choiceworld experiment
            reward_echo_behav{sess} = getEventTimes(expRefs{sess},'waterValve');
        end
    else
        warning('Timeline file not found for %s. Using block file instead for reward echos. NOT RECOMMENDED',expRefs{sess});
        if isfield(b,'events') %signals experiment
            error('Not coded yet. Ask peter to do it...');
        else %choiceworld experiment
            reward_echo_behav{sess} = b.rewardDeliveryTimes';
        end
    end
    
end

%2) Load reward times from the probe
reward_echo_ephys = getRewardEcho(ephysDir);

%3) Check that the total number of rewards match
numRewardEchoEphys = length(reward_echo_ephys);
numRewardEchoSessions = cellfun(@length,reward_echo_behav);

%If they don't match, then test for whether too many expRefs were provided:
%for example if ephys recording is associated with only a few of the
%expRefs which were provided
if numRewardEchoEphys ~= sum(numRewardEchoSessions)
    warning('Mismatch in number of ephys reward echoes %d and total reward echos in expRefs %d',numRewardEchoEphys,sum(numRewardEchoSessions));
    for numComb = 1:numSessions
        C = combnk(numRewardEchoSessions,numComb);
        Cname = combnk(expRefs,numComb);
        
        match = sum(C,2)==numRewardEchoEphys;
        if any(match)
            fprintf('Mismatch is fixed by using only these sessions\n');
            disp( Cname(match,:) );
        end
    end
    error('Mismatch problem. Please address and then re-run');
end

%4) For each session, get conversion weights to conver this block to the
%probe timebase
numRewardEchoEphysIdx = [0;cumsum(numRewardEchoSessions)];
behav2probe = cell(size(expRefs));
fprintf('Aligning multiple block reward times to probe reward echo...\n');
for sess = 1:numSessions
    %get the set of ephys reward echos corresponding to this session 
    idx = (numRewardEchoEphysIdx(sess)+1):numRewardEchoEphysIdx(sess+1);

    [~,behav2probe{sess}] = makeCorrection(reward_echo_ephys(idx), reward_echo_behav{sess}, true);
end

end

function rewardEchoEphys = getRewardEcho(ephysDir)
files = dir(ephysDir);
if any(contains({files.name},'nidq.bin')) %Phase 3B2, use .nidq file
    rewardEchoNI = readCatGTOutputFile('NIrewardEcho', ephysDir);
    
    %If IMEC and NI sync is available, then use that to correct the NI
    %reward echo times to the IMEC reward echo times
    try
        syncIMEC = readCatGTOutputFile('IMECsync',ephysDir);
        syncNI = readCatGTOutputFile('NIsync',ephysDir);
        
        if length(syncIMEC)==length(syncNI)
            fprintf('Aligning NI sync to IMEC sync...\n');
            [~,ni2imec] = makeCorrection(syncIMEC,syncNI,false);
            rewardEchoEphys = applyCorrection(rewardEchoNI, ni2imec);
        else
            warning('Mismatch in number of SYNCs in NI and IMEC, therefore cannot use this\n');
            error('error');
        end

    catch
        warning('No IMEC-NI sync used, therefore there may be a few msec drift in the alignment');
        rewardEchoEphys = rewardEchoNI;
    end
    
else %Phase 3A, use lfp file SY channel
    rewardEchoEphys = getRewardEcho_Phase3A(ephysDir);
end

end

function rewardEchoEphys = getRewardEcho_Phase3A(ephysDir)
% Function handles acquiring the reward echo times contained within
% Phase3B2 data, on the nidq data format. Output is a list of reward echo onset times.
lfBin = dir(fullfile(ephysDir,'*.lf.bin'));
assert( length(lfBin)==1, 'Too few or too many LF.BIN files detected');
syncDat = extractSyncChannelFromFile_cached_Phase3A(fullfile(lfBin.folder,lfBin.name), 385, 385);
eventTimes = spikeGLXdigitalParse(syncDat, 2500); %hard-coded 2500 sampling rate for LFP
rewardEchoEphys = eventTimes{1}{2};
end

function syncDat = extractSyncChannelFromFile_cached_Phase3A(filename, numChans, syncChanIndex)
% Function handles extracting the sync channel data from Phase3A probes,
% which is useful later for getting the reward echo times.
% extraChanIndices are 1-indexed

[folder,fn] = fileparts(filename);
syncFname =  fullfile(folder, [fn '_sync.dat']);

if ~exist(syncFname,'file')
    
    fprintf('Sync data not found for this session - generating now!\n');
    
    %Open files for reading and writing
    fidOut = fopen(syncFname, 'w'); 
    fid = fopen(filename, 'r');
    
    % skip over the first samples of the other channels
    q = fread(fid, (syncChanIndex-1), 'int16=>int16');
    
    d = dir(filename);
    nSamp = d.bytes/2/numChans;
    syncDat = zeros(1, nSamp, 'int16');

    maxReadSize = 1e9;
    nBatch = floor(nSamp/maxReadSize);
    for b = 1:nBatch
        dat = fread(fid, [1, maxReadSize], 'int16=>int16', (numChans-1)*2); % skipping other channels
        fwrite(fidOut, dat, 'int16');
        if nargout>0
            syncDat((b-1)*maxReadSize+1:b*maxReadSize) = dat;
        end
    end
    
    % all the other samples
    dat = fread(fid, [1, Inf], 'int16=>int16', (numChans-1)*2); % skipping other channels
    fwrite(fidOut, dat, 'int16');
    if nargout>0
        syncDat(nBatch*maxReadSize+1:end) = dat;
    end
    
    fclose(fid);
    fclose(fidOut);
    
    disp(' done.')

else
    fid = fopen(syncFname,'r');
    syncDat = fread(fid, [1 Inf], '*int16');
    fclose(fid);
end



end

function times = readCatGTOutputFile(type,ephysDir)

switch(type)
    case 'IMECsync'
        name = 'SY_384_6_500.txt';
    case 'NIrewardEcho'
        name = 'XA_0_0.txt';
    case 'NIsync'
    	name = 'XA_1_500.txt';
end

file = dir(fullfile(ephysDir, ['*' name]));
assert(length(file)==1,'Too many or too few files found in %s matching filter %s',ephysDir,name);

%Load values
times = dlmread(fullfile(file.folder,file.name), '\n')';

%Trim end value which is often a newline
if times(end)==0
    times(end)=[];
end
end
function varargout = twoPAlign(type, twoPDir, expRefs)
%   [..] = ephysAlign(type, ephysDir, expRefs)
%   This function performs alignment between 2P and behavioural data.
%   The type of alignment depends on whether the 2p data is associated with
%   one or multiple expRefs.
%   
%   Input variable 'type' determines what alignment to perform.
%
%   'OneRecordingToOneSession': This method returns the 2p data
%       realigned to the timebase of a single session. This is done by
%       matching the reward echos between the two data.
%
%   'MultipleSessionsToOneRecording': This method returns the coefficients
%       required to transform any behavoiural timing signal for each
%       session to the ephys timebase for one probe.
%
%check for spikes toolbox
% Armin 2023-07-07
assert(~isempty(which('loadKSdir')),'Please install the spikes toolbox https://github.com/cortex-lab/spikes/');

%check for communications toolbox
assert(~isempty(which('de2bi')),'Please install the MATLAB communications toolbox');

switch (type)
    case 'OneRecordingToOneSession'
        assert(ischar(expRefs),'input should be a string with a single expRef');
        probe2block = OneProbeToOneSession(ephysDir,expRefs);
        varargout = {probe2block};
        
    case 'MultipleSessionsToOneRecording'
        blocks2probe = MultipleSessionsToOneProbe(ephysDir, expRefs);
        varargout = {blocks2probe};
        
    otherwise
        error('Not handled');
end

end

function twoP2block = OneRecordingToOneSession(twoPDir,expRef)

p = inputParser;
addRequired(p,'ephysDir',@isfolder);
addRequired(p,'expRef',@ischar);
parse(p,ephysDir, expRef);

%Get reward echo from PAQ file (from text file extracted from PAQ file)
%Huriye and Orsi to do
reward_echo_twoP = small_Function_to_Read_Reward_text_File_from_twoP_folder(twoPDir);

%Load reward echos from timeline
b = dat.loadBlock(expRef);
reward_echo_behav = getEventTimes(expRef,'reward_echo');


%check that the number of echos is the same
assert( length(reward_echo_behav)==length(reward_echo_twoP),...
    '%d timeline reward echos but %d ephys reward echos',length(reward_echo_behav),length(reward_echo_twoP));

%Compute alignment function
fprintf('Aligning probe reward echos to block reward times...\n');
[~,twoP2block] = makeCorrection(reward_echo_behav, reward_echo_twoP, true);
end

function behav2probe = MultipleSessionsToOneRecording(twoPDir, expRefs)
%Function realigns the behavioural timestamps from each blockfile to the
%2p recoding timebase.
% Armin to do this at later times
end




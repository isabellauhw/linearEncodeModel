# This is the code for plotting daily licking pattern for differnet stimTypes
# IMPORTANT #
# The code reads in the Bock.mat file and plots the licking raster and lick density plot
# 1) This code is slow & requires Matlab. Make sure your python-matlab API is set correctly.
# 2) Please make sure you have the LakLabAnalysis folder in MATLAB search path
# 3) You have to add UTILITIES & +DAT in the MATLAB path to make this code work.
# 4) Change the necessary parameters in the code for your own data : Line 294-306
# 4) The code is written for the specific data structure of the Lak Lab, licking behaviour data.
# HA, 03/2024

# Make sure you have the libraries installed
############################################################################
#######  IMPORT LIBRARIES & DEFINE FUNCTIONS #####
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime
import easygui
import warnings 
import os
import glob, os
warnings.filterwarnings("ignore", category=DeprecationWarning)

# Define functions
def paq_read(file_path=None, plot=False, save_path=None):
    """
    Read PAQ file (from PackIO) into python
    Lloyd Russell 2015
    Parameters
    ==========
    file_path : str, optional
        full path to file to read in. if none is supplied a load file dialog
        is opened, buggy on mac osx - Tk/matplotlib. Default: None.
    plot : bool, optional
        plot the data after reading? Default: False.
    Returns
    =======
    data : ndarray
        the data as a m-by-n array where m is the number of channels and n is
        the number of datapoints
    chan_names : list of str
        the names of the channels provided in PackIO
    hw_chans : list of str
        the hardware lines corresponding to each channel
    units : list of str
        the units of measurement for each channel
    rate : int
        the acquisition sample rate, in Hz
    """

    # file load gui
    if file_path is None:
        print('No file path')

        file_path = easygui.fileopenbox(default="*.paq", filetypes=["*.paq"])

    # open file
    fid = open(file_path, 'rb')
    print('Reading file: ' + file_path)
    # get sample rate
    rate = int(np.fromfile(fid, dtype='>f', count=1))
    # get number of channels
    num_chans = int(np.fromfile(fid, dtype='>f', count=1))
    # get channel names
    chan_names = []
    for i in range(num_chans):
        num_chars = int(np.fromfile(fid, dtype='>f', count=1))
        chan_name = ''
        for j in range(num_chars):
            chan_name = chan_name + chr(int(np.fromfile(fid, dtype='>f', count=1)))
        chan_names.append(chan_name)

    # get channel hardware lines
    hw_chans = []
    for i in range(num_chans):
        num_chars = int(np.fromfile(fid, dtype='>f', count=1))
        hw_chan = ''
        for j in range(num_chars):
            hw_chan = hw_chan + chr(int(np.fromfile(fid, dtype='>f', count=1)))
        hw_chans.append(hw_chan)

    # get acquisition units
    units = []
    for i in range(num_chans):
        num_chars = int(np.fromfile(fid, dtype='>f', count=1))
        unit = ''
        for j in range(num_chars):
            unit = unit + chr(int(np.fromfile(fid, dtype='>f', count=1)))
        units.append(unit)

    # get data
    temp_data = np.fromfile(fid, dtype='>f', count=-1)
    num_datapoints = int(len(temp_data)/num_chans)
    data = np.reshape(temp_data, [num_datapoints, num_chans]).transpose()

    # close file
    fid.close()

    # plot
    if plot:
        f, axes = plt.subplots(num_chans, 1, sharex=True)
        for idx, ax in enumerate(axes):
            ax.plot(data[idx])
            ax.set_xlim([0, num_datapoints-1])
            ax.set_ylabel(units[idx])
            ax.set_title(chan_names[idx])
        plt.show()

    return  {"data": data,
            "chan_names": chan_names,
            "hw_chans": hw_chans,
            "units": units,
            "rate": rate}

# Functions for reading in data from .paq files
def paq_data(paq, chan_name, threshold, threshold_ttl = False, plot=False):
    '''
    Do not include any exclusion of data in this function
    returns the data in paq (from paq_read) from channel: chan_names
    if threshold_tll: returns sample that trigger occured on
    '''
    chan_idx = paq['chan_names'].index(chan_name)
    data = paq['data'][chan_idx, :]
    if threshold_ttl == False:
        data = data
    elif threshold_ttl == 'Mix':
        data = threshold_detect(data,threshold,cutoff = 5.1)
    elif threshold_ttl == 'Lick':
        threshold = 4.6 # to clean the reward signal from licking - there is some cross talk across channels
        data = threshold_detect(data,threshold,cutoff = False)
    else:
        data = threshold_detect(data,threshold, cutoff=False)

    if plot:     
        if threshold_ttl:
            plt.plot(data)#, np.ones(len(data)), '.')
        else:
            plt.plot(data)
    return data

def threshold_detect(signal, threshold, cutoff=True):
    '''lloyd russell, cutoff is added by HA'''
    if cutoff:
        thresh_signal = (signal > threshold) & (signal < cutoff)
        thresh_signal[1:][thresh_signal[:-1] & thresh_signal[1:]] = False
        times = np.where(thresh_signal)
    else:
        thresh_signal = signal > threshold
        thresh_signal[1:][thresh_signal[:-1] & thresh_signal[1:]] = False
        times = np.where(thresh_signal)

    return times[0]

def lick_binner(paqData,trial_start, stChanName, stimulation=True ):
    ''' makes new easytest binned lick variable in run object '''
    licks = paq_data (paqData, stChanName, 1, threshold_ttl='Lick')

    binned_licks = []

    for i, t_start in enumerate(trial_start):
        if i == len(trial_start) - 1:
            t_end = np.inf
        else:
            t_end = trial_start[i+1]

        trial_idx = np.where((licks >= t_start) & (licks <= t_end))[0]

        trial_licks = licks[trial_idx] - t_start

        binned_licks.append(trial_licks)

    licks = licks
    # attribute already exists called 'binned_licks' and cannot overwrite it
    binned_licks_easytest = binned_licks

    return licks, binned_licks

def fetch_and_convert(eng, variable_name, data_type='numeric'):
    if data_type == 'numeric':
        data = eng.eval(f"data.{variable_name}", nargout=1)
        return [float(x[0]) for x in data]
    elif data_type == 'categorical':
        data = eng.eval(f"cellstr(data.{variable_name})", nargout=1)
        return [str(x) for x in data]
    else:
        raise ValueError("Unsupported data_type. Use 'numeric' or 'categorical'.")

def extract_paq_data_frame(paq_filepath, rewardChanelName):
    """Return dict of frame numbers for
    imaging frames and reward times. These are taken as the RISE TIME of each event voltage pulse.
    
    :param: paq_filepath - filepath to PAQ file
    :param: imaging_frame_filename - filepath for storing frame number for imaging frames
    :param: reward_frame_filename - filepath for storing frame number for reward events
    """
    paq = paq_read(paq_filepath, plot=False)
    threshold_volts = 2.5

    idx_reward = paq["chan_names"].index(rewardChanelName)

    frame_count_reward = np.flatnonzero((paq["data"][idx_reward][:-1] < threshold_volts) & (paq["data"][idx_reward][1:] > threshold_volts))+1

    reward_frame_filename = paq_filepath.replace('.paq','_reward_frames.txt')
    with open(reward_frame_filename, "w") as f:
        f.write('\n'.join(str(f) for f in frame_count_reward))
    print("Saved file:", reward_frame_filename)

    if __name__ == "__main__":
        for file in glob.glob("*.paq"): 
            print("Found PAQ file", file)
            extract_paq_data_frame(file)

def behav_data(rawDataPath,sessionProfile,rewardChanelName):
    # set matlab API
    import matlab.engine
    eng = matlab.engine.start_matlab()
    print('Matlab engine is set correctly.')

    # get the data
    sessionName, twoPpath, paq_file_path = get_session_and_paq_path(rawDataPath)
    extract_paq_data_frame(paq_file_path,rewardChanelName)
    try:
        dataBeh = eng.getBehavData(sessionName,sessionProfile)
    except matlab.engine.MatlabExecutionError as e:
        eng.quit()
        print("An error occurred while trying to execute getBehavData.m function.")
        print("Most likely problem is getBehavData.m function is not in Matlab Path.")
        print('Please make sure LakLabAnalysis folder is in the MATLAB Path with all subfolders.')
        print(f"MATLAB Error: {e}")

    # Lets align the behData & paqData
    
    data, variance = eng.applySubtractionCorrection (dataBeh, twoPpath ,sessionName, False, savepathname, nargout=2)

    eng.workspace['data'] = data 

    # Use the MATLAB engine to fetch and convert data
    trialNumber = fetch_and_convert(eng, "trialNumber")
    stimulusType = fetch_and_convert(eng, "stimulusType", 'categorical')
    stimulusOnsetTime = fetch_and_convert(eng, "stimulusOnsetTime")
    rewardTime = fetch_and_convert(eng, "rewardTime")
    rewardVolume = fetch_and_convert(eng, "rewardVolume")

    # Prepare the data dictionary for DataFrame conversion
    data = {
        "trialNumber": trialNumber,
        "stimulusType": stimulusType,
        "stimulusOnsetTime": stimulusOnsetTime,
        "rewardTime": rewardTime,
        "rewardVolume": rewardVolume
    }

    # Convert to a Pandas DataFrame
    df = pd.DataFrame(data)
    eng.quit()

    return df, paq_file_path

def get_session_and_paq_path(rawDataPath):
    # Example format for user input: 2023-12-06_1_MAT003 (sessionName)
    sessionName = input("Please enter the Session Name (e.g., '2023-11-27_1_MAT003'): ")
    
    # Assuming the format is always date_sequence_animalID
    parts = sessionName.split('_')
    if len(parts) != 3:
        print("\nError: The session name format is incorrect.\n")
        return None, None
    
    date, _, animalID = parts
    
    # Constructing the folder path based on the provided structure
    # Note: Replace 'Y:' with the correct base path if this script runs on a different OS than Windows.
    folder_path = os.path.join(rawDataPath, animalID, date, "TwoP")
    
    # Finding the .paq file within the constructed path
    paq_file_path = None
    for file in os.listdir(folder_path):
        if file.endswith(".paq") and date in file and animalID in file:
            paq_file_path = os.path.join(folder_path, file)
            break
    
    if not paq_file_path:
        print(f"\nNo .paq file found in {folder_path}.\n")
        return sessionName, None
    
    return sessionName, folder_path, paq_file_path

###########################################################################
###########################################################################
###########################################################################
##### PAQ FILE PARAMETERS - CHANGE THEM ACCORDINGLY #####

# Get the paq file - Change parameters for your own paq file
rawDataPath = 'Y:\\'
fRate = 20000
fRate_beh = 1000
stChanName_lick = 'lick'
stChanName_reward = 'reward_echo' 
savepathname = 'C:\\Users\\Huriye\\Desktop\\'
plotChanelType = 'rewardVolume'
ymaxLikDensity = 5 # for plotting
preRewardTime = 3 # in sec, for plotting
visualStimDur = 2 # sec 
totalLength =  preRewardTime + visualStimDur +5 # sec, 5 seconds after reward for plotting

sessionProfile = 'Pavlov1'


############################################################################
#######  Create behaviour sessions plots

bin_width = 2  # Adjust this value to change the width of each bin

# Get the stim start times 
data,paq_file_path = behav_data(rawDataPath,sessionProfile, stChanName_reward)
paqData = paq_read( file_path=paq_file_path, plot=False, save_path=None)
#trialStartTimes = paq_data (paqData, stChanName_reward, 1, threshold_ttl=True, plot=False)
trialStartTimes = (data['stimulusOnsetTime'])*fRate
trialStartTimes = trialStartTimes - ((preRewardTime)*fRate)

# Get the lick times
licks, animal_lick = lick_binner(paqData, trialStartTimes,stChanName_lick, stimulation = False)

# Plot the figure
stimTypes = data[plotChanelType]
stimTypes = list(set(stimTypes))
fig, axs = plt.subplots(len(stimTypes)+2,1, figsize=(6, (len(stimTypes)+2)*2))
fig.suptitle(datetime.now().strftime('%Y-%m-%d'))
plt.subplots_adjust(hspace=0.3, wspace=1)

#### Plot the all trials
for i, array in enumerate(animal_lick):
    axs[0].plot(array, np.ones_like(array)+i, 'k.',markersize = 1)

ymax = len(animal_lick)
axs[0].set_xlim(0, totalLength*fRate)
axs[0].set_ylim(0, ymax)
axs[0].set_yticks(range(0,ymax, 25), range(ymax,0, -25))
axs[0].set_xticks (range(0,(totalLength*fRate)+1,fRate), range((preRewardTime*-1),(totalLength-preRewardTime+1),1))
axs[0].set_ylabel('Trials')
#axs[0].set_xlabel('Time (sec)') 
axs[0].set_title('Raster licking plot for all trials in order of occurance')

ax2 = axs[0].twinx()

# Lick density plot
num_bins = range(0, totalLength*fRate, int(fRate/bin_width))
animal_hist = np.zeros(len(num_bins)-1)
for i, array in enumerate(animal_lick):
    hist, bins = np.histogram(array, bins=num_bins, range=(0, totalLength*fRate))
    animal_hist = animal_hist + hist
animal_hist = animal_hist / (i+1) / bin_width
ax2.plot(bins[1:], animal_hist, 'k', linewidth=2, alpha=0.5)

# Set y-label for the secondary y-axis
ax2.set_ylabel('Lick density (Hz)', color='k')  
ax2.tick_params(axis='y', labelcolor='k')  # Set tick color to match the plot
ax2.axvline(x=((preRewardTime+visualStimDur)*fRate)+300, color='grey', linestyle='-', alpha=1, linewidth=10)
ax2.axvline(x=(preRewardTime*fRate), color='k', linestyle='--', alpha=1, linewidth=1)

##### Plot trials in different stimTypes
color = [ [0,0,0], [0.4, 0, 0], [0.7, 0, 0], [1, 0, 0]]
plotID = 1
for stimType in stimTypes:
    selectedTrials = np.where(data[plotChanelType] == stimType)[0]
    animal_lickSelected = [animal_lick[i] for i in selectedTrials]
    for i, array in enumerate(animal_lickSelected):
        axs[plotID].plot(array, np.ones_like(array)+i, 'k.',markersize = 1)
    
    ymax = len(animal_lickSelected)
    axs[plotID].set_xlim(0, totalLength*fRate)
    axs[plotID].set_ylim(0, ymax)
    axs[plotID].set_yticks(range(0,ymax, 25), range(ymax,0, -25))
    axs[plotID].set_xticks (range(0,(totalLength*fRate)+1,fRate), range(((preRewardTime)*-1),(totalLength-preRewardTime+1),1))
    axs[plotID].set_ylabel('Trials')
    ax2.set_ylim(0, ymaxLikDensity)
    #axs[plotID].set_xlabel('Time (sec)') 

    ax2 = axs[plotID].twinx()

    # Lick density plot
    num_bins = range(0, totalLength*fRate, int(fRate/bin_width))
    animal_hist = np.zeros(len(num_bins)-1)
    for i, array in enumerate(animal_lickSelected):
        hist, bins = np.histogram(array, bins=num_bins, range=(0, totalLength*fRate))
        animal_hist = animal_hist + hist
    animal_hist = animal_hist / (i+1) / bin_width
    ax2.plot(bins[1:], animal_hist,  color = color[plotID], linewidth=2, alpha=0.5)
    axs[len(stimTypes)+1].plot(bins[1:], animal_hist, linewidth=2, alpha=0.5, color = color[plotID])

    # Set y-label for the secondary y-axis
    ax2.set_ylabel('Lick density (Hz)', color=color[plotID])  
    ax2.tick_params(axis='y', labelcolor=color[plotID])
    ax2.set_ylim(0, ymaxLikDensity)
    ax2.axvline(x=((preRewardTime+visualStimDur)*fRate)+300, color='grey', linestyle='-', alpha=1, linewidth=10)
    ax2.axvline(x=(preRewardTime*fRate), color='k', linestyle='--', alpha=1, linewidth=1)
    ax2.set_title(f'Raster licking plot for {stimType} trials')

    plotID = plotID + 1

axs[len(stimTypes)+1].set_xlim(0, totalLength*fRate)
axs[len(stimTypes)+1].set_xticks (range(0,(totalLength*fRate)+1,fRate), range(((preRewardTime)*-1),(totalLength-preRewardTime+1),1))
axs[len(stimTypes)+1].set_ylabel('Lick Density (Hz)')
axs[len(stimTypes)+1].set_ylim(0, ymaxLikDensity)
axs[len(stimTypes)+1].set_xlabel('Time (sec)') 

plt.show()
fig.savefig(savepathname + datetime.now().strftime('%Y-%m-%d') + '_LickRastersMoreStimTypes.png')
print('Figure is saved as:', savepathname + datetime.now().strftime('%Y-%m-%d') + '_LickRastersMoreStimTypes.png')

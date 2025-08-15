# This is the code for plotting daily licking pattern
# The code reads in the .paq file and plots the licking raster and lick density plot
# This code cannot seperate stimTypes, it is fast but limited in its use
# HA, 03/2024

# Make sure you have the libraries installed
############################################################################
#######  IMPORT LIBRARIES & DEFINE FUNCTIONS #####
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
import easygui
import warnings 
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

    return {"data": data,
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

###########################################################################
###########################################################################
###########################################################################
##### PAQ FILE PARAMETERS - CHANGE THEM ACCORDINGLY #####

# Get the paq file - Change parameters for your own paq file
file_path = None
paqData = paq_read( file_path=file_path, plot=False, save_path=None)
fRate = 20000
ymax = 150
stChanName_lick = 'lick'
stChanName_reward = 'reward_echo' 
savepathname = 'C:\\Users\\Desktop\\'
preRewardTime = 10 # in sec, for plotting
totalLength =  preRewardTime + 5 # sec, 5 seconds after reward for plotting
visualStimDur = 2 # sec 

############################################################################
#######  Create behaviour sessions plots
bin_width = 10  # Adjust this value to change the width of each bin

# Get the stim start times 
trialStartTimes = paq_data (paqData, stChanName_reward, 1, threshold_ttl=True, plot=False)

trialStartTimes = trialStartTimes - (preRewardTime*fRate)

# Get the lick times
licks, animal_lick = lick_binner(paqData, trialStartTimes,stChanName_lick, stimulation = False)

# Plot the figure
fig, axs = plt.subplots(2)
fig.suptitle(datetime.now().strftime('%Y-%m-%d'))
plt.subplots_adjust(hspace=0.7, wspace=1)

for i, array in enumerate(animal_lick):
    axs[0].plot(array, np.ones_like(array)+i, 'k.',markersize = 1)

axs[0].set_xlim(0, totalLength*fRate)
axs[0].set_ylim(0, ymax)
axs[0].set_yticks(range(0,ymax, 25), range(ymax,0, -25))
axs[0].set_xticks (range(0,(totalLength*fRate)+1,fRate), range((preRewardTime*-1),(totalLength-preRewardTime+1),1))
axs[0].set_ylabel('Trials')
axs[0].set_xlabel('Time (sec)') 
axs[0].axvline(x=(preRewardTime*fRate)+visualStimDur+300, color='blue', linestyle='-', alpha=1, linewidth=10)
axs[0].axvline(x=((preRewardTime-visualStimDur)*fRate), color='red', linestyle='--', alpha=1, linewidth=1)
axs[0].set_title('Raster plot of licking behaviour')


num_bins = range(0, totalLength*fRate, int(fRate/bin_width))
animal_hist = np.zeros(len(num_bins)-1)
for i, array in enumerate(animal_lick):
    hist, bins = np.histogram(array, bins=num_bins, range=(0, totalLength*fRate))
    animal_hist = animal_hist + hist
animal_hist = animal_hist/ (i+1)/bin_width
axs[1].plot( bins[1:],animal_hist, 'k', linewidth =1, alpha= 0.5)
axs[1].axvline(x=(preRewardTime*fRate)+2300, color='blue', linestyle='-', alpha=1, linewidth=10)
axs[1].axvline(x=(8*fRate), color='red', linestyle='--', alpha=1, linewidth=1)

axs[1].set_title('Lick density plot')

axs[1].set_xlim(0, totalLength*fRate)
axs[1].set_xticks (range(0,(totalLength*fRate)+1,fRate), range((preRewardTime*-1),(totalLength-preRewardTime+1),1))
axs[1].set_xlabel('Time (sec)') 
axs[1].set_ylabel('Lick density (Hz)') 

plt.show()


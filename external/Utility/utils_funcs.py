# This code is from VAPE, Packer LAb 06/03/2022

import numpy as np
import pandas as pd
import json
import LakLabAnalysis.Utility.commonPlot_funcs as cpfun
import os
import matplotlib.pyplot as plt
import pickle
import matplotlib
import seaborn as sns
import csv
import math
import bisect
import copy
from scipy import stats
import scipy.io as spio
from scipy import signal
from scipy.io import loadmat
import glob
import tifffile
import re
from scipy.signal import find_peaks, detrend, savgol_filter
from time import time
import string
import warnings
from scipy.stats import zscore
import xmltodict



# global plotting params
params = {'legend.fontsize': 'x-large',
          'axes.labelsize': 'x-large',
          'axes.titlesize': 'x-large',
          'xtick.labelsize': 'x-large',
          'ytick.labelsize': 'x-large'}
plt.rcParams.update(params)
sns.set()
sns.set_style('white')

def check_makePath(dir_list):
    """Checks if given path exists (made to be a folder) and if not creates it for you.
    Also replaces \\ with /, because \\ annoys me and can result in unexpected results.
    Take note if you (for example) count backwards from the end of the path string to find the parent directory
    """
    for i, path_frag in enumerate(dir_list):
        if i==0:
            pathname = path_frag.replace('\\', '/')
            if not os.path.isdir:
                print(f'WARNING: {path_frag} is not an existing directory.')
        else:
            pathname = os.path.join(pathname, path_frag).replace('\\', '/')
    if not os.path.isdir(pathname):
        os.makedirs(pathname)
        print(pathname, 'created.')
    # else:
    #     print(pathname, 'exists.')
    return pathname

def constructPath(dir_list):
    "Only constructs the path, does not make/create/checks if exists."
    for i, path_frag in enumerate(dir_list):
        if i==0:
            pathname = path_frag.replace('\\', '/')
        else:
            pathname = os.path.join(pathname, path_frag).replace('\\', '/')
    return pathname

def walk_for_files(parent_folder, end='', start=''):
    return_list = []
    for root, dirs, files in os.walk(parent_folder):
        for file in files:
            if file.endswith(end) and file.startswith(start):
                return_list.append(os.path.join(root, file).replace('\\', '/'))
    return return_list

def customSort(listUnsorted, sortOrder, alphabet=False):
    """Custom sorts listUnsorted following sortOrder.
    State alphabet=False if you only want to sort by the first letter,
    alphabet=True if you want to index through every character in each word
    =========
    :param: listUnsorted - **list** of strings to be sorted
    :param: sortOrder - **string vector** of characters by which listUnsorted is to be sorted
    """
    if alphabet:
        # Create custom alphabet with all characters, beginning from digit > uppercase > lowercase > symbols
        alphabet = string.digits + string.ascii_uppercase + string.ascii_lowercase + string.punctuation + ' '
        #Rearrange alphabet so characters for sorting order are at the very front
        for char in list(sortOrder):
            alphabet = alphabet.replace(char,'') 
        alphabet = sortOrder+alphabet
        listSorted = sorted(listUnsorted, key=lambda word: [alphabet.index(c) for c in word])
    else:
        listSorted = sorted(listUnsorted, key=lambda word: [sortOrder.index(c) for c in word[0]])
    return listSorted

def flatten_lists(xss):
    "ST 2025: Flatten list of lists ([[list1], [list2], ...])"
    return [x for xs in xss for x in xs]

def palette_order(data_stimTypes, stimType_forColor, plotColor, sortOrder='0591', alphabet=False):
    """ST 2025: Sorts and returns stimulus types with their associated colors
    Good for use with sns.lineplot palette, hue, hue_order kwargs
    :param: data_stimTypes      - list of stimulus types from data (can have repetition)
    :param: stimType_forColor   - list of stimulus types in order corresponding to color for plotting in plotColor
    :param: plotColor           - list of colors in order to plot corresponding list of stimType_forColor
    :param: sortOrder           - list of characters/strings or a string of characters by which to sort stimulus types

    :output: stimTypesList      - sorted unique list of stimulus types from data_stimTypes
    :output: colorPalette       - list of colors from plotColor for each stimulus type in stimTypesList
    """
    stimTypesList = list(set(data_stimTypes))
    # print(stimTypesList)
    stimTypesList = customSort(stimTypesList, sortOrder, alphabet=alphabet)
    
    colorPalette = []
    for stimType in stimTypesList:
        color_ind = np.where([stimType.startswith(i) for i in stimType_forColor])[0][0]
        colorPalette.append(plotColor[color_ind])
    return stimTypesList, colorPalette

def sns_palette_style(data_stimTypes, stimType_forColor, plotColor, 
                      style_type='tuple', sortOrder='05NPur91', alphabet=True):
    """ ST 04/2025: generates color palette and style based on trial type, for use with seaborn plotting functions
    """
    stimTypesList = list(set(data_stimTypes)) #unique stim types only
    stimTypesList = customSort(stimTypesList, sortOrder, alphabet=alphabet) #sort
    
    palette = {}
    style = {}

    for stimType in stimTypesList:
        ## Choose linestyle
        if (('unrewarded' in stimType) or (stimType.endswith('-'))):
            style[stimType] =  (2,1) if style_type=='tuple' else ':'# dash, gap
        elif  ('Nonlicked' in stimType):
            style[stimType] =  (1,5) if style_type=='tuple' else ':' # 
        elif (('Prelicked' in stimType) or ('rewarded' in stimType)):
            style[stimType] = (5,2) if style_type=='tuple' else '--' #'--' 
        else: style[stimType] = '' if style_type=='tuple' else '-'  #'-' / 'solid'

        ## Choose colours
        if ('Prelicked' in stimType or 'Nonlicked' in stimType): #i.e. color for stimTypes
            stimType_key = stimType.replace('Prelicked ', '').replace('Nonlicked ', '')
        else:
            stimType_key = stimType
        palette[stimType] = plotColor[np.where([stimType_key.startswith(i) for i in stimType_forColor])[0][0]]
        if '50%' in stimType:
            palette[stimType] = plotColor[np.where([i==('50%') for i in stimType_forColor])[0][0]]

    return stimTypesList, palette, style

def truncateDictionary(input_dict, truncate_ind, start_ind=0, dont_truncate_keys=[]):
    output_dict = {}
    # if type(truncate_ind)==float or type(truncate_ind)==int:
    #     # make a list with the 
    for k, v in input_dict.items():
        if k not in dont_truncate_keys:
            if isinstance(v, dict):
                output_dict[k] = {}
                for vk, vv in v.items():
                    output_dict[k][vk] = vv[start_ind:truncate_ind]
            else: 
                output_dict[k] = v[start_ind:truncate_ind]
        else: output_dict[k]=v
    return output_dict

def truncateDataframe(df, colname, first_ind=False, last_ind=False, list_keep=False):
    """ ST 11/2024: truncate input dataframe df in index-wise fashion, based on values in df.colname
    """
    if list_keep is False: #based on a sorted list of unique elements in df[colname], find the values to keep
        list_colname = list(set(df[colname]))
        list_colname.sort()
        # print(list_colname)
        list_keep = list_colname[first_ind:last_ind]
    else: list_keep = list_keep

    df_indices_keep = np.where(np.isin(df[colname], list_keep))[0]
    df_output = df.iloc[df_indices_keep]
    return df_output

def makeDict_keyValue(keysList, valuesList):
    """ Automatically creates a dictionary with keys and values as ordered in the input arguments
    Essentially like a zip, but to make a dictionary
    """
    if len(keysList)==len(valuesList):
        dict1={}
        for i, key in enumerate(keysList):
            dict1[key] = valuesList[i]
    else:
        print('WARNING: input lists must be of same length. NoneType dictionary returned.')
        dict1=None
    return dict1

def extract_paq_data_frame(paq_filepath, rewardChanelName, twoPChannelName = '2p_frame', paqExtracted = False):
    """Return dict of frame numbers for
    imaging frames and reward times. These are taken as the RISE TIME of each event voltage pulse.
    
    :param: paq_filepath - filepath to PAQ file
    :param: imaging_frame_filename - filepath for storing frame number for imaging frames
    :param: reward_frame_filename - filepath for storing frame number for reward events
    """
    if paqExtracted == False: 
        paq = paq_read(paq_filepath, plot=False)
    else:
        filenamePAQ  = os.path.join(paq_filepath, 'paq-data.pkl')
        paq_filepath = os.path.join(paq_filepath, paq_filepath.split('/')[-1]+'.paq') 
        print(paq_filepath)
        paq = pd.read_pickle(filenamePAQ)
    threshold_volts = 2.5

    # Extract reward frame numbers
    idx_reward = paq["chan_names"].index(rewardChanelName)
    frame_count_reward = np.flatnonzero((paq["data"][idx_reward][:-1] < threshold_volts) & (paq["data"][idx_reward][1:] > threshold_volts))+1
    reward_frame_filename = paq_filepath.replace('.paq','_reward_frames.txt')
    with open(reward_frame_filename, "w") as f:
        f.write('\n'.join(str(f) for f in frame_count_reward))
    #print("Saved file:", reward_frame_filename)

    # Extract imaging frame numbers
    if twoPChannelName is not None:
        idx_reward = paq["chan_names"].index(twoPChannelName)
        frame_count_imaging = np.flatnonzero((paq["data"][idx_reward][:-1] < threshold_volts) & (paq["data"][idx_reward][1:] > threshold_volts))+1
        reward_frame_filename = paq_filepath.replace('.paq','_imaging_frames.txt')
        with open(reward_frame_filename, "w") as f:
            f.write('\n'.join(str(f) for f in frame_count_imaging))
        #print("Saved file:", reward_frame_filename)
    else:
        print('No imaging frame for this session.')

    if __name__ == "__main__":
        for file in glob.glob("*.paq"): 
            print("Found PAQ file", file)
            extract_paq_data_frame(file)

    return paq, frame_count_reward

def extract_paqPkl_data_frame(paqpkl_filepath, paq_filepath, rewardChanelName, twoPChannelName = '2p_frame'):
    """Return dict of frame numbers for
    imaging frames and reward times. These are taken as the RISE TIME of each event voltage pulse.
    
    :param: paq_filepath - filepath to PAQ-DATA.PKL file
    :param: imaging_frame_filename - filepath for storing frame number for imaging frames
    :param: reward_frame_filename - filepath for storing frame number for reward events
    """
    paq = pd.read_pickle(paqpkl_filepath)
    threshold_volts = 2.5

    # Extract reward frame numbers
    idx_reward = paq["chan_names"].index(rewardChanelName)
    frame_count_reward = np.flatnonzero((paq["data"][idx_reward][:-1] < threshold_volts) & (paq["data"][idx_reward][1:] > threshold_volts))+1
    if paq_filepath.endswith('.paq'):
        reward_frame_filename = paq_filepath.replace('.paq','_reward_frames.txt')
    elif paq_filepath.endswith('.mat'):
        reward_frame_filename = paq_filepath.replace('.mat','_reward_frames.txt')
    with open(reward_frame_filename, "w") as f:
        f.write('\n'.join(str(f) for f in frame_count_reward))
    print("Saved file:", reward_frame_filename)

    # Extract imaging frame numbers
    if twoPChannelName is not None:
        idx_reward = paq["chan_names"].index(twoPChannelName)
        frame_count_imaging = np.flatnonzero((paq["data"][idx_reward][:-1] < threshold_volts) & (paq["data"][idx_reward][1:] > threshold_volts))+1
        reward_frame_filename = paq_filepath.replace('.paq','_imaging_frames.txt').replace('.mat','_imaging_frames.txt')
        with open(reward_frame_filename, "w") as f:
            f.write('\n'.join(str(f) for f in frame_count_imaging))
        print("Saved file:", reward_frame_filename)
    else:
        print('No imaging frame for this session.')

    if __name__ == "__main__":
        for file in glob.glob("*.paq"): 
            print("Found PAQ file", file)
            extract_paq_data_frame(file)

    return paq, frame_count_reward

def extract_frames_from_timeline(timeline_filepath, rewardChannel = 'reward_echo', imagingChannel = 'frameClock',
                                 reward_threshold=4.9, imaging_threshold=4.9):
    # Performs function of extract_paqPkl_data_frame(), but with _Timeline.mat path, where reward and imaging frames are logged in timeline file
    """
    """
    timeline = timeline_mat_load(timeline_filepath)

    # Extract reward frame numbers, in DAQ frames
    frame_count_reward = paq_data(timeline, rewardChannel,threshold=reward_threshold,threshold_ttl=True, plot=False) 
    reward_frame_filename = timeline_filepath.replace('.mat','_reward_frames.txt')
    with open(reward_frame_filename, "w") as f:
        f.write('\n'.join(str(f) for f in frame_count_reward))
    print("Saved file:", reward_frame_filename)

    # Extract imaging frame numbers, in DAQ frames
    frame_count_imaging = paq_data(timeline, imagingChannel,threshold=imaging_threshold,threshold_ttl=True, plot=False) 
    imaging_frame_filename = timeline_filepath.replace('.mat','_imaging_frames.txt')
    with open(imaging_frame_filename, "w") as f:
        f.write('\n'.join(str(f) for f in frame_count_imaging))
    print("Saved file:", imaging_frame_filename)

    return frame_count_reward, frame_count_imaging


def extract_daqPkl_data_frame(daqpkl_filepath, daq_filepath, rewardChanelName):
    """Return dict of frame numbers for
    imaging frames and reward times. These are taken as the RISE TIME of each event voltage pulse.
    
    :param: paq_filepath - filepath to PAQ-DATA.PKL file
    :param: imaging_frame_filename - filepath for storing frame number for imaging frames
    :param: reward_frame_filename - filepath for storing frame number for reward events

    ST 06/08: investigate if this and extract_daqPkl2_data_frame can be merged somehow
    """
    paq = pd.read_pickle(daqpkl_filepath)
    threshold_volts = 2.5

    # Extract reward frame numbers
    idx_reward = paq["chan_names"].index(rewardChanelName)
    frame_count_reward = np.flatnonzero((paq["data"][idx_reward][:-1] < threshold_volts) & (paq["data"][idx_reward][1:] > threshold_volts))+1
    reward_frame_filename = daq_filepath.replace('.mat','_reward_frames.txt')
    with open(reward_frame_filename, "w") as f:
        f.write('\n'.join(str(f) for f in frame_count_reward))
    print("Saved file:", reward_frame_filename)

    if __name__ == "__main__":
        for file in glob.glob("*.paq"): 
            print("Found PAQ file", file)
            extract_paq_data_frame(file)

    return paq, frame_count_reward

def extract_daqPkl2_data_frame(daqpkl_filepath, daq_filepath, rewardChanelName):
    """Return dict of frame numbers for
    imaging frames and reward times. These are taken as the RISE TIME of each event voltage pulse.
    
    :param: paq_filepath - filepath to PAQ-DATA.PKL file
    :param: imaging_frame_filename - filepath for storing frame number for imaging frames
    :param: reward_frame_filename - filepath for storing frame number for reward events
    """
    paq = pd.read_pickle(daqpkl_filepath)
    threshold_volts = 2.5

    daq_filepath = os.path.join(daq_filepath, daq_filepath.split('/')[-1]+'.mat') 
    # Extract reward frame numbers
    idx_reward = paq["chan_names"].index(rewardChanelName)
    frame_count_reward = np.flatnonzero((paq["data"][idx_reward][:-1] < threshold_volts) & (paq["data"][idx_reward][1:] > threshold_volts))+1
    reward_frame_filename = daq_filepath.replace('.mat','_reward_frames.txt')
    with open(reward_frame_filename, "w") as f:
        f.write('\n'.join(str(f) for f in frame_count_reward))
    print("Saved file:", reward_frame_filename)

    if __name__ == "__main__":
        for file in glob.glob("*.paq"): 
            print("Found PAQ file", file)
            extract_paq_data_frame(file)

    return paq, frame_count_reward

def timeline_mat_load(timeline_mat_path, plot = False, save_path = None):
    """Find _Timeline.mat file and load data into a dictionary for DAQ data from black boxes"""

    print('Loading Timeline file: ', timeline_mat_path)
    timeline_mat = loadmat(timeline_mat_path, simplify_cells = True) # large file, data is in Timeline key
    # timeline_mat['Timeline'].keys()
    timelineData = timeline_mat['Timeline']
    rawDaqData = timelineData['rawDAQData']
    rawDaqData = rawDaqData.transpose() #transpose for daq data in columns instead of rows

    rate = timelineData['hw']['daqSampleRate']
    hw_inputs = timelineData['hw']['inputs'] #len(hw_inputs) gives number of channels

    num_chans = len(hw_inputs)
    num_datapoints = len(rawDaqData[0])
    # print(f'rawDaqData is {type(rawDaqData[0])}')
    # print(hw_inputs[0].keys())

    # Find channel names and acquisition units, in order by hw.inputs[arrayColumn]
    chan_names = []
    units = []
    column_idx = []
    for i in range(num_chans):
        arr_col = hw_inputs[i]['arrayColumn'] 
        column_idx.insert(arr_col-1, arr_col-1) # arr_col starts from 1. Hence, -1 to specify list position
        chan_names.insert(arr_col-1, hw_inputs[i]['name'])
        units.insert(arr_col-1, hw_inputs[i]['measurement'])  
    # print(column_idx)
    # print(chan_names)
    # print(units)

    # plot daq data
    f, axes = plt.subplots(num_chans, 1, sharex=True)
    for idx, ax in enumerate(axes):
        ax.plot(rawDaqData[idx])
        ax.set_xlim([0, num_datapoints - 1])
        ax.set_ylabel(units[idx])
        ax.set_title(chan_names[idx])
    # plt.tight_layout()

    if save_path is not None:
        png_name = 'rawDaq.png'
        save_path = os.path.join(save_path, png_name).replace('\\', '/')
        f.savefig(save_path)
        print('Saved '+save_path)

    if plot is not False:
        # matplotlib.use("AGG")
        plt.show()
        plt.close()
    else:
        plt.close()

    daq_dict = {"data": rawDaqData,
                "chan_names": chan_names,
                "column_idx": column_idx,
                "units": units,
                "sample_rate": rate}
    # print(daq_dict)
    return daq_dict

def block_mat_load(block_mat_path, block_field, keys_toLoad = ['stimulusType', 'rewardProbability']):
    """ ST 09/2024: Loads specific values from block file into a dictionary
    :param: block_mat_path  - path to Block.mat file
    :param: block_field     - 'events' or 'paramsValues'
    :param: keys_toLoad     = None, to retrieve events or params, or list of string values corresponding to key values in events or params
    """
    temp = loadmat(block_mat_path, simplify_cells=True)
    block_paramsValues = temp['block'][block_field] #for block_field=paramsValues, returns a list of dictionaries, each dictionary representing all values in a single trial
    
    if block_field == 'paramsValues':
        # block.paramsValues is returned as a list of dictionaries, as many as there are trials
        if keys_toLoad is not None and isinstance(keys_toLoad, list):
            chosen_paramsValues = {}
            for key_toExtract in keys_toLoad: #to reshape these dictionaries into trial x param instead of param x trial
                key_column = []
                for sub_dict in block_paramsValues:
                    # print(key_toExtract, block_paramsValues[0][key_toExtract])
                    key_column.append(sub_dict[key_toExtract])
                chosen_paramsValues[key_toExtract] = key_column
            return (chosen_paramsValues)
        elif keys_toLoad is None:
            return temp['block'][block_field]
    
    elif block_field == 'events':
        # block.events is a dictionary, with each key 
        if keys_toLoad is not None and isinstance(keys_toLoad, list):
            chosen_paramsValues = {}
            for key_toExtract in keys_toLoad:
                key_column = block_paramsValues[key_toExtract]
                chosen_paramsValues[key_toExtract] = key_column
            return (chosen_paramsValues)
    
    elif block_field == 'expDef':
        keys_toLoad = None #defunct
        expDef_path = temp['block'][block_field] #.item().item() #get the string
        expDef_path = expDef_path.replace('\\', '/')
        expDef = expDef_path.split('/')[-1].split('.m')[0]
        return expDef

def stimTypeName_getBehData(expDef):
    """ST 01/2025: Return a dictionary of stim type codes and names based on expDef
    and maintained from getBehavData.m
    """
    if ('Pavlov1' in expDef) and ('Pavlov1_switchingProb' not in expDef):
        return {'number': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,23],
                'name': ['None','Cross','Circle',"50%GratingLeft",'25%GratingLeft','50%GratingRight','25%GratingRight','100%GratingCentre', 'Rectangle', '0%Grating', '4000Hz', '8000Hz', 'WNoise', 
                        'CrossBlack', 'CircleLarge', '2000Hz', 'CircleBlack', 'Grating0', 'Grating90', 'Grating45', 'Gabor0', 'Gabor90', 'Gabor45', 'Gabor135']}
    else: print('utils.stimTypeName_getBehData() is returning None, expect error.')

def expDefParameters_fromBlockMat(block_mat_path, return_stim_as_name = True):
    """ ST 09/2024: Return a dictionary of all experiment def parameters (assumes parameters remain constant through session)
    :param: block_mat_path - string: path to Block.mat file
    !!! This is an inelegant solution, consider migrating to expParams_fromBlock_parameters()
    """
    expDef = block_mat_load(block_mat_path, 'expDef')
    # if ('Pavlov1_pseudo' in expDef) or ('Pavlov1_stimRewardJitters' in expDef):
    stimulusType_code = stimTypeName_getBehData(expDef)
    temp = loadmat(block_mat_path, simplify_cells=True)
    block_params = temp['block']['paramsValues']
    try: 
        iter(block_params)
        block_params = block_params[0]
    except: 
        if isinstance(block_params, dict): block_params = block_params
    block_paramsKeys = list(block_params.keys()) #list(block_params[0].keys())
    flattened_block_params = {} #assumes every subdict in block_params shares the same key-value pair 
    for key_toExtract in block_paramsKeys:
        if key_toExtract == 'stimulusType' and return_stim_as_name:
            try: iter(block_params[key_toExtract])
            except: block_params[key_toExtract] = [block_params[key_toExtract]] 
            print(block_params[key_toExtract])
            flattened_block_params[key_toExtract] = [stimulusType_code['name'][stimulusType_code['number'].index(code)] for code in block_params[key_toExtract]]
        else: flattened_block_params[key_toExtract] = block_params[key_toExtract]
    # elif 'Pavlov1_switchingProb' in expDef:
    #     # load from 
    return flattened_block_params

def expParams_fromBlock_parameters(mat_path, return_stim_as_name = True):
    """ ST 09/2024: Return a dictionary of all experiment def parameters (assumes parameters remain constant through session)
    :param: mat_path - string: path to Block.mat or parameters.mat file
    """
    if mat_path.endswith('_Block.mat'): mat_path = mat_path.replace('_Block', '_parameters')
    elif mat_path.endswith('_parameters.mat'): mat_path = mat_path

    parameters = loadmat(mat_path, simplify_cells=True)['parameters']
    expDef = parameters['defFunction'].split('\\')[-1].split('.m')[0]
    if expDef=='Pavlov1_switchingProb':
        # define stimulusType by stimulusOrientation of Gabor patches, assume stimuli in center
        # get relevant index within parameters['stimulusOrientation']
        try: 
            iter(parameters['stimulusOrientation'][0])
            num_stimuli = len(parameters['stimulusOrientation'][0]) 
        except: num_stimuli = 1
        try: 
            iter(parameters['stimulusType']) #for sessions where stimulusType is defined per stimulus
            stimOri_idxs = [parameters['stimulusType'][i]-1 for i in range(num_stimuli)] #Matlab is 1-index, Python is 0-index
        except: #for sessions where stimulusType is a global condition
            stimOri_idxs = [parameters['stimulusType']-1 for i in range(num_stimuli)]

        # print(parameters['stimulusOrientation'], f'{num_stimuli} stimuli', )
        # print(parameters['stimulusType'], stimOri_idxs)
        if num_stimuli > 1:
            parameters['stimulusType'] = [f"Gabor{(parameters['stimulusOrientation'][stimOri_idxs[i]][i])}" for i in range(num_stimuli)]
        else: 
            parameters['stimulusType'] = [f"Gabor{(parameters['stimulusOrientation'][stimOri_idxs[0]])}"]
    elif ('Pavlov1' in expDef) and return_stim_as_name: #(('Pavlov1_pseudo' in expDef) or ('Pavlov1_stimRew' in expDef))
        stimulusType_code = stimTypeName_getBehData(expDef)
        parameters['stimulusType'] = [stimulusType_code['name'][stimulusType_code['number'].index(code)] for code in parameters['stimulusType'].copy()]
    
    return parameters

def nonZero_expDefParameters(block_mat_path, keys_toCheck):
    expDefParams = expParams_fromBlock_parameters(block_mat_path)
    if isinstance(keys_toCheck, str):
        keys_toCheck = [keys_toCheck]
    assert isinstance(keys_toCheck, list), '2nd input argument should be a list of keys in block.paramsValues'
    output_dict = {}
    for k in keys_toCheck:
        if k in list(expDefParams.keys()):
            if isinstance(expDefParams[k], np.ndarray) and len(expDefParams[k])>1:
                if any(element!=0 for element in list(expDefParams[k])): #expDefParams[k] may be an array
                    output_dict[k] = expDefParams[k]
            elif isinstance(expDefParams[k], float) or isinstance(expDefParams[k], int):
                if expDefParams[k]!=0:
                    output_dict[k] = expDefParams[k]
    return output_dict

def add_expDefParameters_toParams(analysisParams, block_mat_path, keys_toCheck):
    expSpecificParams = nonZero_expDefParameters(block_mat_path, keys_toCheck)
    for k in keys_toCheck:
        if k not in list(expSpecificParams.keys()):
            analysisParams[k] = np.nan
        else:
            analysisParams[k] = expSpecificParams[k]
    return analysisParams

def xml_to_dict(parent_folder):
    """ ST 01/2025: Written to convert PrairieView xml file to a more easily-digestible dictionary format.
    Could be expanded for more forms
    :param: parent_folder - path to TwoP folder **containing** .xml file. There should only be one .xml
    
    :output: 
    """
    if '.tif' in parent_folder: #image file path was passed instead
        parent_folder=os.path.dirname(parent_folder)
    xml_files = [f for f in glob.glob(parent_folder + f'/*.xml')]
    assert len(xml_files)==1, f"> 1 .xml file in {parent_folder}"
    xml_path = xml_files[0]
    with open(xml_path, encoding='utf8') as fd: #specify encoding as utf8 to avoid an error
        xml = xmltodict.parse(fd.read(), attr_prefix="@")
    
    # Case 1: PVScan means xml file is PrairieView backup log file of recording parameters
    if 'PVScan' in xml.keys():
        print('Opening .xml file as PVScan settings')
        output_dict = {}
        for d in xml['PVScan']['PVStateShard']['PVStateValue']:
            d_keys = list(d.keys())
            d_valuekey = [k for k in d_keys if k!='@key'][0]
            # print(d_valuekey)
            sub_dict = d[d_valuekey]
            if isinstance(sub_dict, list): 
                try: 
                    output_dict[f"{d['@key']}"] = {}
                    sub_dict_keys =  list(sub_dict[0].keys())
                    # print(sub_dict_keys, 'in', d_valuekey)
                    for k in sub_dict_keys:
                        output_dict[f"{d['@key']}"][k.replace('@', '')] = [sd[k] for sd in sub_dict]
                except: output_dict[f"{d['@key']}"] = sub_dict
            else: output_dict[f"{d['@key']}"] = sub_dict
    return output_dict

def get_tif_tags(tiff_filepath):
    assert os.path.isfile(tiff_filepath) and tiff_filepath.endswith('.tif'), f"{tiff_filepath} does not exist or is not a .tif file"
    
    with tifffile.TiffFile(tiff_filepath) as tif:
        tif_tags = {}
        for tag in tif.pages[0].tags.values():
            name, value = tag.name, tag.value
            tif_tags[name] = value
    return tif_tags

def get_imaging_frate(recordingList, blockName):
    tiffFolder = recordingList.imagingTiffFileNames[dfIndFromValue(blockName, recordingList.blockName)[0]]
    assert os.path.exists(tiffFolder), f"WARNING: {tiffFolder} not found to exist; expect error"
    try: #Prairie View method
        xml_dict = xml_to_dict(tiffFolder)
        fRateImag = np.floor(1/float(xml_dict['framePeriod']))
    except: # ScanImage method (3P)
        tiff_file = [f for f in glob.glob(tiffFolder+'/*.tif')]
        # print(tiff_file)
        tif_tags = get_tif_tags(tiff_file[0])
        fRateImag = float(tif_tags['Software'][(re.search('scanVolumeRate = ', tif_tags['Software'])).span()[-1]:].split('SI')[0])
 
    return fRateImag

def get_pixel_resolution(ops = False, xml_path = False):
    if ops and isinstance(ops, dict):
        assert 'filelist' in ops.keys(), 'Could not find filelist in ops, are you sure you passed an ops dictionary?'
        xml_path = ops['filelist'][0]
    
    if xml_path:
        xml = xml_to_dict(xml_path)
        um_per_pixel = float(xml['micronsPerPixel']['value'][xml['micronsPerPixel']['index'].index('XAxis')])
    else:
        print('WARNING: utils.get_pixel_resolution() could not return resolution, expect an error.')
    return um_per_pixel

def extractPaqDaqChannels(dictData, strChanName, savePathName=None, replaceChanName=False):
    """
    If data dictionary was built using utils.timeline_mat_load or utils.paq_read, use this.
    This function pulls out a specific channel data from each key based on value-indexing in chan_names
    and saves it in a pared-down dictionary. Dictionary structure is preserved, but only the relevant channel data
    is retained.

    :param: dictData - dictionary of paq or daq data
    :param: strChanName - string (or list of strings) of channel name/s you wish to extract - must be present in dictData['chan_names']
    :param: savePathName - **kwarg** path name of file you wish to store the extracted data dictionary in  
    """
    if isinstance(strChanName, str):
        strChanName = [strChanName]
    if replaceChanName:
        if isinstance(replaceChanName, str):
            replaceChanName = [replaceChanName]
        # print(replaceChanName)
        # Sort items in strChanName and replaceChanName to be in same order as in dictData['chan_names']
        str_replaceChanName = list(zip(strChanName, replaceChanName))
        str_replaceChanName.sort(key=lambda i: dictData['chan_names'].index(i[0]))
        strChanName = [i[0] for i in str_replaceChanName]
        replaceChanName = [i[1] for i in str_replaceChanName]
    else:
        strChanName = sorted(strChanName, key=list(dictData['chan_names']).index)


    dictKeyNames = list(dictData.keys())
    smallDict = dict.fromkeys(dictKeyNames)
    # if 'data' in dictKeyNames: #initialise 'data' in dictionary
    #     smallDict['data'] = np.empty((0,dictData['data'].shape[1]))
    #     print(smallDict['data'].shape)
    for i, chan in enumerate(strChanName):
        try:
            chan_ind = dictData['chan_names'].index(chan)
        except:
            print("Error: Check your 2nd input argument - channel name must be present in ['chan_names'].")
        
        for dictKey in dictKeyNames:
            # print(dictKey)
            if smallDict[dictKey] is None: #i.e. smallDict has not been filled yet
                if dictKey == 'sample_rate' or dictKey == 'rate': #sample_rate is typically not a list but a float
                    smallDict['sample_rate'] = dictData[dictKey]
                elif dictKey == 'data':
                    smallDict[dictKey] = np.array([dictData[dictKey][chan_ind, :]]) #[] may seem unnecessary but are needed to ensure correct array dimensions
                elif dictKey == 'chan_names' and replaceChanName:
                    smallDict[dictKey] = [replaceChanName[i]]
                else:
                    smallDict[dictKey] = [dictData[dictKey][chan_ind]]

            else:
                if dictKey != 'sample_rate':
                    if dictKey == 'chan_names' and replaceChanName:
                        smallDict[dictKey].append(replaceChanName[i])
                    elif dictKey=='data': #in original dictionaries, 'data' is not a list, but concatenated arrays joined on axis0
                        smallDict[dictKey] = np.stack((smallDict[dictKey], np.array([dictData[dictKey][chan_ind, :]])))
                    else:
                        smallDict[dictKey].append(dictData[dictKey][chan_ind])

    if savePathName is not None:
        with open(savePathName, 'wb') as f:
            pickle.dump(smallDict, f)
        print('Extracted channels saved in '+savePathName)
        
    return smallDict

def correct_signal_shifts(paq_data, channel_name_for_2p_frame,savepathname, fRateImaging =15):
    """
    Corrects vertical shifts in signals due to an electrical switch that changes recording channel orders.
    Deletes data if the shift occurs in the last 5 minutes, otherwise corrects the channels.

    :param paq_data: A dictionary containing 'data' (signals matrix), 'chan_names' (channel names), and 'rate' (sampling rate).
    :param channel_name_for_2p_frame: The name of the channel used for 2p frame signal.
    :return: Updated paq_data with corrected signals.
    """
    signals = paq_data['data']
    #print(signals.shape[0])
    # This code will only work for max 3 channels - otherwise will give an error
    if signals.shape[0]>3:
        print('The code is only for 3 channels. Please modify the code for more channels')
    
    channel_names = paq_data['chan_names']
    fRate = paq_data['rate']

    # Get the index of the 2p frame channel
    channel_idx = [i for i, s in enumerate(channel_names) if s.lower() == channel_name_for_2p_frame][0]
    # Get the 2p frame signal
    signal_2p = signals[channel_idx, :]

    # Ignore first and last 30 seconds of the recording to avoid initial and final transients
    ignore_samples = 30* fRate
    #diffs = np.diff(signal_2p[ignore_samples:])
    # # Find rising edges of the TTL pulses
    hsignal  = np.percentile(signal_2p, 99.9)
    peaks, _ = find_peaks(signal_2p, height=hsignal, distance=1e3, prominence=1)
    #print(peaks)
    peak_intervals = np.diff(peaks)
    mean_interval = np.mean(peak_intervals)
    std_interval = np.std(peak_intervals)*4

    # Find intervals that differ from the mean by a certain number of standard deviations
    shift_points = peaks[np.where(abs(peak_intervals - mean_interval) > std_interval)[0] + 1]
    paq_dataN = paq_data.copy()
    # If shift point is detected
    if shift_points.size > 2: # if there are more than couple indices, then correct the signal!
        cutoff_idx = shift_points[0] +(1*fRate) # Check after 2 (1?) seconds
        # Lets find out if moved to up or down in chnannel Order

        if np.sum(signals[2, cutoff_idx:(cutoff_idx+(3*fRate))]>4) > 3*fRateImaging: # There should be at least 20 TTL pulses in next second
            print('Channels swap is detected. Correcting upward channel swaps..')
            channelOrder = [2,0,1]
        elif np.sum(signals[1, cutoff_idx:(cutoff_idx+(3*fRate))]>4) > 3*fRateImaging: 
            print('Channels swap is detected. Correcting downward channel swaps..')
            channelOrder = [1,2,0]
        else:
            print('Correction failed! - Check if correction is needed!')
        # If the shift is in the middle, correct the signals by swapping the affected sections
        corrected_signals = []
        cutoff_idx = shift_points[0]
        for i in range(signals.shape[0]):  # Reverse order to rotate channels
            next_channel = channelOrder[i]
            corrected_signals.append(np.concatenate([signals[i, :cutoff_idx], 
                                                    signals[next_channel, cutoff_idx:]]))
        signals = np.vstack(corrected_signals)

        paq_dataN['data'] = signals
        figName = 'paqRaw_Corrected.png'
        paq_plot(paq_dataN['data'], paq_dataN['units'], paq_dataN['chan_names'],savepathname, figName)
    else:
        print('Nothing wrong found in .paq data')
    return paq_dataN
    
# def correct_reward_miscounts(eng, paqRewardArray, data, filenameBeh, info, ind):
#     ''' Check if reward counts across paqPkl and behavData are equal. If not, truncate the longer dataset
#         so that both have same number of total rewards, and save/output the files as needed for 
#         applySubtractionCorrection
#     '''
#     paqRewardCount = len(paqRewardArray)
#     # Get reward counts from behavData
#     eng.workspace['data'] = data #Add data into eng.worksapce to work with
#     data_rewardVolume = fetch_and_convert(eng, "rewardVolume")
#     behavRewardCount = np.count_nonzero(~np.isnan(data_rewardVolume))

#     if paqRewardCount < behavRewardCount: # Means paqIO stopped before session ended
#         print(f'behavData > paqData reward counts: {behavRewardCount} > {paqRewardCount}')
#         eng.writetable(data, filenameBeh.replace('CorrectedeventTimes.csv', 'Original.csv'), nargout=0)
#         print('Original behData saved in: '+filenameBeh.replace('CorrectedeventTimes.csv', 'Original.csv'))
#         # Find the trial where paqIO crashed, write some .csv files for future reference
#         cut_off_trial = np.where(~np.isnan(data_rewardVolume))[0][paqRewardCount-1]
#         data = eng.eval(f'data(1:{cut_off_trial+1}, :)')
#         eng.workspace['data'] = data
#         eng.writetable(data, filenameBeh.replace('CorrectedeventTimes.csv', 'Truncated.csv'), nargout=0)
#         print(f'Cut-off-trial is {cut_off_trial}. New data table has height of', eng.eval('height(data)'))
        
        
        
#     # if paqRewardCount > behavRewardCount: # Assume this means manual rewards were given...after session stopped?  
#     # # Rewrite paq_reward_frames.txt
#     #     paq_filepath = info.recordingList.rawPaqFilePath[ind]
#     #     reward_frame_filename = paq_filepath.replace('.paq','_reward_frames.txt')
#     #     if os.path.isfile(reward_frame_filename):
#     #         with open(filepath, 'r+') as f: #Read
#     #             text = f.readlines()
#     #             f.seek(0) #moves file pointer to start of file
#     #             f.truncate() #presumably, removes content below the file pointer 
#     #             f.writelines(text[:cut_off_trial]) 

#     return data

def extract_daq_data_frame(daq_dict, rewardChanelName, timeline_mat_path):
    ''' Return dict of frame numbers for reward times from a prepared dictionary. These are taken as the RISE TIME of each event voltage pulse.

        :param: daq_dict - daq data returned from timeline_mat_load
        :param: rewardChanelName - string of channel name for reward events
    '''

    threshold_volts = 2.5

    idx_reward = daq_dict["chan_names"].index(rewardChanelName)

    frame_count_reward = np.flatnonzero(
        (daq_dict["data"][idx_reward][:-1] < threshold_volts) & (daq_dict["data"][idx_reward][1:] > threshold_volts)) + 1

    if timeline_mat_path.endswith('_Timeline.mat'):
        reward_frame_filename = timeline_mat_path.replace('.mat', '_reward_frames.txt')
    
    with open(reward_frame_filename, "w") as f:
        f.write('\n'.join(str(f) for f in frame_count_reward))
    print("Saved file:", reward_frame_filename)

def tiff_metadata(folderTIFF, ch2=True):

    ''' takes input of list of tiff folders and returns 
        number of frames in the first of each tiff folder '''
    
    # First check if tiff file is good and correct
    tiff_list = []
    tseries_nframes = []
    tiffs = get_tiffs(folderTIFF)
    if not tiffs:
        raise print('cannot find tiff in '
                                    'folder {}'.format(tseries_nframes))
    elif len(tiffs) == 1 and ch2==True:
        assert tiffs[0][-7:] == 'Ch2.tif', 'channel not understood '\
                                            'for tiff {}'.format(tiffs)
        tiff_list.append(tiffs[0])
    elif len(tiffs) == 1 and ch2!=True:
        if tiffs[0][-7:] != 'Ch2.tif':
            print('tiff {} is not Ch2.tif, ensure this is what you want.'.format(tiffs))
        tiff_list.append(tiffs[0])
    elif len(tiffs) == 2:  # two channels recorded (red is too dim)
        print('There are more than one tiff file - check: '+ folderTIFF)

    with tifffile.TiffFile(tiffs[0]) as tif:
        tif_tags = {}
        for tag in tif.pages[0].tags.values():
            name, value = tag.name, tag.value
            tif_tags[name] = value
        tif_npages=len(tif.pages)

    x_px = tif_tags['ImageWidth']
    y_px = tif_tags['ImageLength']
    image_dims = [x_px, y_px]
    try: 
        n_frames = re.search('(?<=\[)(.*?)(?=\,)', 
                            tif_tags['ImageDescription'])

        n_frames = int(n_frames.group(0))
    except: 
        print('utils.tiff_metadata: Inferring n imaging frames from frames in tiff, which may not be accurate if tiff is a dual-channel recording')
        n_frames = tif_npages
    tseries_nframes.append(n_frames)

    return image_dims, tseries_nframes

def tiff_meanImg(tiff_path):
    """ST 03/2025: return mean image array (xdim x ydim in pixels) from path of tiff file or path to folder containing tiff file
    """
    if not tiff_path.endswith('.tif'): #tiff_path leads to the folder containing tiffs
        tiff_list = [f for f in glob.glob(tiff_path+"/*.tif")]
        if len(tiff_list)==1: tiff_file = tiff_list[0]
        elif len(tiff_list)>1:
            print("2 tif files found in folder:", [os.path.basename(i) for i in tiff_list])
            choice = input("Which tif file index?")
            tiff_file = tiff_list[int(choice)]
    else: tiff_file = tiff_path
    print(f"Processing {os.path.basename(tiff_file)} for utils.tiff_meanImg()")
    with tifffile.TiffFile(tiff_file) as tif:
        tif_array = tifffile.TiffFile.asarray(tif) #time x 1024 x 1024
        meanImg_tif = np.nanmean(tif_array, axis=0) # 2D array of xy (or yx) pixels

    return meanImg_tif

def s2p_stat_cellpix_xy(stat_cell):
    ypix = [stat_cell['ypix'][i] for i in range(len(stat_cell['ypix'])) if not stat_cell['overlap'][i]]
    xpix = [stat_cell['xpix'][i] for i in range(len(stat_cell['xpix'])) if not stat_cell['overlap'][i]]
    return ypix, xpix

def cellmasks_from_s2pstat(stat, shape=(1024,1024), meanImg_measure=None, cells_ind=None, 
                           cells_cmap='random', alpha=0.5):
    """

    cell_mask_intensity will return as a list of the unique and original cell indexes
    """
    if shape is None and meanImg_measure is not None: 
        shape = meanImg_measure.shape
        print(f"In utils,s2p_cellFOVs(): shape inferred from meanImg_measure.shape = {meanImg_measure.shape}")
    if cells_ind is None: cells_ind = np.arange(len(stat)) #defaults to all cells
    # colour
    if isinstance(cells_cmap, str):
        if cells_cmap=='random': 
            cells_cmap = np.random.choice(range(256), size=(len(stat), 3))  # random rgb codes (0-255, 0-255, 0-255) for every cell (len(stat))
    elif isinstance(cells_cmap, tuple) and len(cells_cmap)==3: # RGB tuple
        cells_cmap = [cells_cmap for _ in range(len(stat))]
    elif isinstance(cells_cmap, np.ndarray) and cells_cmap.shape[1] == 3: #2D array, RGB code for every cell
        # cells_cmap.shape[0] needs to be >= num cells
        cells_cmap = cells_cmap

    if meanImg_measure is not None:
        cell_mask_intensity = np.empty_like(stat) # array to store mean intensity from meanImg_measure per ROI, filled with None values
    cell_mask_colour = np.ndarray(shape=(shape[0], shape[1], 4), dtype=int) # every pixel associated with 4 values (RGBA)
    
    for cell_number in cells_ind:
        stat_cell = stat[cell_number]
        ypix, xpix = s2p_stat_cellpix_xy(stat_cell)
        # [stat_cell['ypix'][i] for i in range(len(stat_cell['ypix'])) if not stat_cell['overlap'][i]]
        # xpix = [stat_cell['xpix'][i] for i in range(len(stat_cell['xpix'])) if not stat_cell['overlap'][i]]
        if meanImg_measure is not None:
            cell_mask_intensity[cell_number] = np.nanmean(meanImg_measure[ypix,xpix])
        # cell_mask = np.array([np.array([0,0,0]) for i in meanImg])
        cell_mask_colour[ypix,xpix] = np.array([i for i in cells_cmap[cell_number]]+[256*alpha]) # RGB+A

    if meanImg_measure is not None: 
        cell_mask_intensity = np.array(cell_mask_intensity, dtype=float) #replaces None with NaN, for calculating mean using np.nanmean
        return cell_mask_colour, cell_mask_intensity
    else: return cell_mask_colour

def calculateDFF (tiff_folderpath, frameClockfromPAQ, suite2pOutputPath=None, 
                  dynamic=True, allROIsAreCells=False, rig=None):
    ''' ST 28/05/2024: 
        Added suite2pOutputPath if s2p_path and tiff_folderpath are different
        Added allROIsAreCells to s2p_loader, and so include argument here. By default, is False and so will 
            follow iscell.npy to distinguish traces from 'cells' and 'not cells'. 
            If True, will disregard iscell.npy and let all traces be cells
    '''
    if suite2pOutputPath is None:
        s2p_path = tiff_folderpath +'\\suite2p\\plane0\\'
    else: 
        if dynamic:
            s2p_path = suite2pOutputPath +'\\plane0\\'
            ch2=True
        else:
            s2p_path = suite2pOutputPath +'\\plane0_red\\'
            ch2=False
    ch2=True if rig=='Dual2p' else False
    # from Vape - catcher file: 
    flu_raw, _, _ = s2p_loader(s2p_path, subtract_neuropil=False,allROIsAreCells=allROIsAreCells) 

    flu_raw_subtracted, spks, stat = s2p_loader(s2p_path, allROIsAreCells=allROIsAreCells)
    flu = dfof2(flu_raw_subtracted)

    _, n_frames = tiff_metadata(tiff_folderpath, ch2=ch2)
    tseries_lens = n_frames
    print(n_frames, tseries_lens, len(frameClockfromPAQ))

    proceed_despite_frame_difference=False
    # deal with the extra frames 
    if tseries_lens[0] < len(frameClockfromPAQ):
        frameClockfromPAQ = frameClockfromPAQ[:tseries_lens[0]] # get rid of foxy bonus frames
    
    elif abs(tseries_lens[0]-len(frameClockfromPAQ))>0:# and abs(tseries_lens[0]-len(frameClockfromPAQ))<101:
        # if paqio was stopped before behaviour, but for very short interval (e.g. 101 frames; <7s in 15fps)
        user_ans = input(f"NOTE: {(tseries_lens[0]-len(frameClockfromPAQ))} frames missing from PAQio, proceed? [y/n]")
        if (user_ans=='y' or user_ans=='Y'):
            print(f"Will now truncate imaging data frames to be in line with paqIO frames")
            proceed_despite_frame_difference=True
            frameClockfromPAQ = frameClockfromPAQ
            n_frames=len(frameClockfromPAQ)
            flu=flu[:,:len(frameClockfromPAQ)]
            spks= spks[:,:len(frameClockfromPAQ)]
            flu_raw=flu_raw[:,:len(frameClockfromPAQ)]
    
    # correspond to analysed tseries
    paq_rate = 2000 if rig=='3p' else 20000
    paqio_frames = tseries_finder(tseries_lens, frameClockfromPAQ, paq_rate=paq_rate)
    # paqio_frames = paqio_frames

    if len(paqio_frames) == sum(tseries_lens) or proceed_despite_frame_difference==True:
        print('Dff extraction is completed: ' +tiff_folderpath)
        imagingDataQaulity = True
       # print('All tseries chunks found in frame clock')
    else:
        imagingDataQaulity = False
        print('WARNING: Could not find all tseries chunks in '
              'frame clock, check this')
        print('Total number of frames detected in clock is {}'
               .format(len(paqio_frames)))
        print('These are the lengths of the tseries from '
               'spreadsheet {}'.format(tseries_lens))
        print('The total length of the tseries spreasheets is {}'
               .format(sum(tseries_lens)))
        missing_frames = sum(tseries_lens) - len(paqio_frames)
        print('The missing chunk is {} long'.format(missing_frames))
        try:
            print('A single tseries in the spreadsheet list is '
                  'missing, number {}'.format(tseries_lens.index
                                             (missing_frames) + 1))
        except ValueError:
            print('Missing chunk cannot be attributed to a single '
                   'tseries')
    return {"imagingDataQuality": imagingDataQaulity,
            "frame-clock": frameClockfromPAQ,
            "paqio_frames":paqio_frames,
            "n_frames":n_frames,
            "flu": flu,
            "spks": spks,
            "stat": stat,
            "flu_raw": flu_raw}

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
        import Tkinter
        import tkFileDialog
        root = Tkinter.Tk()
        root.withdraw()
        file_path = tkFileDialog.askopenfilename()
        root.destroy()

    # open file
    fid = open(file_path, 'rb')
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
        import matplotlib
        import os
        matplotlib.use('Agg')
        import matplotlib.pylab as plt
        f, axes = plt.subplots(num_chans, 1, sharex=True)
        for idx, ax in enumerate(axes):
            ax.plot(data[idx])
            ax.set_xlim([0, num_datapoints-1])
            ax.set_ylabel(units[idx])
            ax.set_title(chan_names[idx])
        if save_path is not None:
            plt.savefig(os.path.join(save_path, 'paqRaw.png'), transparent=False)
        f.clear()
        plt.close(f)

    return {"data": data,
            "chan_names": chan_names,
            "hw_chans": hw_chans,
            "units": units,
            "rate": rate}

def paq_plot(data, units, chan_names,save_path, figName):
    num_chans = data.shape[0]
    f, axes = plt.subplots(num_chans, 1, sharex=True)
    for idx, ax in enumerate(axes):
        ax.plot(data[idx])
        ax.set_ylabel(units[idx])
        ax.set_title(chan_names[idx])
    plt.savefig(os.path.join(save_path, figName), transparent=False)
    f.clear()
    plt.close(f)

def dfof2(flu):
    '''
    delta f over f, this function is orders of magnitude faster 
    than the dumb one above takes input matrix flu 
    (num_cells x num_frames)
    (JR 2019)

    '''

    flu_mean = np.mean(flu, 1)
    flu_mean = np.reshape(flu_mean, (len(flu_mean), 1))
    return (flu - flu_mean) / flu_mean

def s2p_loader(s2p_path, subtract_neuropil=True, neuropil_coeff=0.7, allROIsAreCells=False):
    '''28/05/2024: ST added allROIsAreCells to tell s2p_loader whether to consider all ROIs as cells or 
                    follow iscell.npy
    '''
    found_stat = False

    for root, dirs, files in os.walk(s2p_path):

        for file in files:

            if file == 'F.npy':
                all_cells = np.load(os.path.join(root, file), allow_pickle=True)
            elif file == 'Fneu.npy':
                neuropil = np.load(os.path.join(root, file), allow_pickle=True)
            elif file == 'iscell.npy':
                is_cells = np.load(os.path.join(root, file), 
                                   allow_pickle=True)[:, 0]
                is_cells = np.ndarray.astype(is_cells, 'bool')
                if allROIsAreCells:
                    is_cells = np.full(len(is_cells), True)
                    print(f"loading {sum(is_cells)} traces (ignoring True/False set by iscell.npy)")
                else:
                    is_cells = is_cells
                    print('loading {} traces labelled as cells'.format(sum(is_cells)))
            elif file == 'spks.npy':
                spks = np.load(os.path.join(root, file), allow_pickle=True)
            elif file == 'stat.npy':
                stat = np.load(os.path.join(root, file), allow_pickle=True)
                found_stat = True

    if not found_stat:
        raise FileNotFoundError('Could not find stat, '
                                'this is likely not a suit2p folder')
    for i, s in enumerate(stat):
        s['original_index'] = i

    all_cells = all_cells[is_cells, :]
    neuropil = neuropil[is_cells, :]
    spks = spks[is_cells, :]
    stat = stat[is_cells]


    if not subtract_neuropil:
        return all_cells, spks, stat

    else:
        print('subtracting neuropil with a coefficient of {}'
              .format(neuropil_coeff))
        neuropil_corrected = all_cells - neuropil * neuropil_coeff
        return neuropil_corrected, spks, stat
    
def detrend_flu(fluR, plot=False, ax=None):
    """ST: Detrend dff as 2d-array (cell x time)"""
    # First, remove any nan values 
    fluR = fluR.reshape(fluR.shape[0], fluR.shape[1])
    flu = detrend(fluR, axis=1, type='linear')
    if plot: #plot mean temporal activity, averaging across cells
        if ax is None:
            fig = plt.figure(figsize=(8,3))
            ax = fig.gca()
        ax.plot(np.nanmean(fluR, axis=0), color='red', alpha=0.5, label='raw')
        ax.plot(np.nanmean(flu, axis=0), color='blue', alpha=0.5, label='detrended')
        ax.set_ylabel('Mean dF/F of all cells')
        ax.set_xlabel('frames')
        ax.legend()
    return flu, ax

def zscore_smooth_flu(fluR, do_zscore=True, smooth_method='savgol', smooth_first=True, **kwargs):
    if do_zscore and not smooth_first: 
        print('z-scoring first')
        fluR = zscore(fluR, axis=1) #[np.logical_not(pd.isna(fluR))]
    
    if smooth_method == 'savgol':
        defaults = {'window_length': 11,
                    'polyorder': 1,}
        argin = {**defaults, **kwargs}
        fluR = savgol_filter(fluR, argin['window_length'], argin['polyorder'], axis=1)
    
    flu = fluR
    if do_zscore and smooth_first: 
        print('z-scoring after')
        flu = zscore(flu, axis=1) 
    
    return flu
    
def preprocess_flu(dfof, detrend=True, smooth_method='savgol', smooth_kw={}, do_zscore=True, 
                   smooth_first=True, plot=False, plot_kw={},
                   blockName=None, savefigfolder=None):
    """ST 12/2024: Detrends dfof (imaging-data.pkl ['flu']), with options to z-score and smooth
     and save plots validating these too """
    fig, axs = plt.subplots(2, 1, figsize=(8, 8))
    # else: fig, axs= None, None
    if detrend: flu_detrend, axs[0] = detrend_flu(dfof, plot=plot, ax=axs[0])
    else: flu_detrend = dfof
    flu = zscore_smooth_flu(flu_detrend, smooth_first=smooth_first,
                            do_zscore=do_zscore, smooth_method=smooth_method, 
                            **smooth_kw)
    
    if plot: 
        plot_defaults = {'cell_idx': 0,
                         'start_s': 300, #plot from 5th minute
                         'end_s': 420, #for 2min/120s
                         'fRate': 15,}
        
        # Set time window of plotting and set x-axis settings
        plot_params = {**plot_defaults, **plot_kw}
        fRate = plot_params['fRate']
        session_duration = int(np.ceil(dfof.shape[1]/fRate)) #in seconds
        # print(f"Session was {session_duration} sec long")
        start_s = int(np.arange(session_duration)[plot_params['start_s']])
        end_s = int(np.arange(session_duration)[plot_params['end_s']])
        # print(start_s, end_s)
        start_frame, end_frame = int(np.ceil(start_s*fRate)), int(np.ceil(end_s*fRate))
        # Which cells to plot
        if 'cell_idx' not in plot_kw:
            variance_per_cell = np.var(flu[:, start_frame:end_frame], axis=1) #np.var(fluR_zscore, axis=1) #returns in shape (ncell,)
            sorted_cells_ascending_variance = np.argsort(variance_per_cell, axis=None) #[::-1] in reverse i.e. descending fashion
            plot_params['cell_idx'] = np.concatenate((sorted_cells_ascending_variance[:5], sorted_cells_ascending_variance[-5:]))
        optimal_step = int(np.ceil((end_s-start_s)/20)) # How much interval in seconds to get 20 x ticks
        xlabels = np.arange(int(start_s), int(end_s), optimal_step)
        xticks = [int(np.ceil(fRate*i)) for i in xlabels] #np.arange(int(start_frame), int(end_frame), )
        assert len(xlabels)==len(xticks), f'Number of x tick-labels {len(xlabels)} not the same as x ticks {len(xticks)}'
        x = np.arange(int(start_frame), int(end_frame))

        labels = ['smoothed (detrended)', 'unsmoothed (detrended)']
        c = ['blue','red']
        previous_peak = 0 #y-offset 
        for c_i, cell in enumerate(plot_params['cell_idx']):
            for i, plot_flu in enumerate([flu, zscore(flu_detrend,axis=1)]):
                plot_flu_sub = (plot_flu[cell, start_frame:end_frame])
                axs[1].plot(x, plot_flu_sub + previous_peak, alpha=0.5, color=c[i], label=labels[i] if c_i==0 else '')
                if i>0: 
                    # Annotate cell ID left of data
                    axs[1].annotate(f'{cell}', xy=(x[0]-10, previous_peak), xycoords='data')
                    # Decide y-offset for margins between cells
                    previous_peak = previous_peak+ np.nanmax(plot_flu_sub) #plot_flu[cell, start_frame:end_frame]
                    
        axs[1].set_xticks(xticks, xlabels)
        axs[1].set_xlabel('Time (s)') 
        ylabel = f'dF/F of {len(plot_params["cell_idx"])} cells'
        ylabel = ylabel + ' (z-score)' if do_zscore else ylabel
        axs[1].set_ylabel(ylabel)
        axs[1].legend()

        fig.suptitle(blockName)

        if savefigfolder is not None:
            savefigname = f"detrend{detrend}_smooth{smooth_method}_zscore{do_zscore}_{blockName}"
            cpfun.save_figure(savefigname, savefigfolder, format='png')
    plt.close()
    
    return flu

def flu_preprocess_splitter(info_recList, blockName, params, **preprocess_flu_kwargs):
    """ ST 04/2025: Code that converts extracted s2p-flu in imaging-data.pkl into a 3-dimensional 
    flu block of cell x time x trial
    """

    default_params = {'preStim_s': 3,
                      'postStim_s': 6, 
                      'fRate': 15,}
    params = {**default_params, **params}

    default_preprocess_flu = {'detrend':True, 
                              'plot':False, 
                              'smooth_method': 'savgol', 
                              'do_zscore': True}
    preprocess_flu_argin = {**default_preprocess_flu, **preprocess_flu_kwargs}
    ind = dfIndFromValue(blockName, info_recList.blockName)[0]
    imData = pd.read_pickle(os.path.join(info_recList.analysisPath[ind], 'imaging-data.pkl'))
    filenameTXT = os.path.join(info_recList.rawBlockPath[ind]) + '\*_imaging_frames.txt'
    filenameTXT= [f for f in glob.glob(filenameTXT)]  
    frame_clock = pd.read_csv(filenameTXT[0],  header= None)
    beh_df = pd.read_csv(info_recList.behFileName[ind].replace('.csv', '_withLicks.csv'))

    preStim_s = params['preStim_s']
    postStim_s = params['postStim_s']
    fRate = params['fRate']
    pre_frames, post_frames = int(np.ceil(preStim_s*fRate)), int(np.ceil(postStim_s*fRate))
    visTimes    = beh_df['stimulusOnsetTime'] + beh_df['trialOffsets']
    # Express stim, reward, choice times as paqIO indices
    stimFrameTimes    = stim_start_frame_Dual2Psetup (frame_clock, visTimes)
    # Convert paqIO indices into 2p_frame imaging frames
    stim2pFrames = dfIndFromValue(stimFrameTimes, frame_clock)

    # Load data
    fluR = imData['flu']
    flu = preprocess_flu(fluR, blockName=blockName, **preprocess_flu_argin)
    data = flu_splitter(flu, stim2pFrames, pre_frames, post_frames)
    # print(data.shape) # cell x time x trials
    return data

def select_by_peak_distance(peaks, vector_peaks, distance):
    """ ST: copied from scipy/scipy/signal/
    Evaluate which peaks fulfill the distance condition.

    Parameters
    ----------
    peaks : ndarray
        Indices of peaks in `vector`.
    vector_peaks : ndarray (can be vector[peaks])
        An array matching `peaks` used to determine priority of each peak. A
        peak with a higher priority value is kept over one with a lower one.
    distance : np.float64
        Minimal distance that peaks must be spaced.

    Returns
    -------
    keep : ndarray[bool]
        A boolean mask evaluating to true where `peaks` fulfill the distance
        condition.

    Notes
    -----
    Declaring the input arrays as C-contiguous doesn't seem to have performance
    advantages.

    .. versionadded:: 1.1.0
    """
    peaks_size = peaks.shape[0]
    # Round up because actual peak distance can only be natural number
    distance_ = int(distance)
    keep = np.ones(peaks_size, dtype=np.uint8)  # Prepare array of flags

    # Create map from `i` (index for `peaks` sorted by `priority`) to `j` (index
    # for `peaks` sorted by position). This allows to iterate `peaks` and `keep`
    # with `j` by order of `priority` while still maintaining the ability to
    # step to neighbouring peaks with (`j` + 1) or (`j` - 1).
    priority_to_position = np.argsort(vector_peaks)

    # Highest priority first -> iterate in reverse order (decreasing)
    for i in range(peaks_size - 1, -1, -1):
        # "Translate" `i` to `j` which points to current peak whose
        # neighbours are to be evaluated
        j = priority_to_position[i]
        if keep[j] == 0:
            # Skip evaluation for peak already marked as "don't keep"
            continue

        k = j - 1
        # Flag "earlier" peaks for removal until minimal distance is exceeded
        while 0 <= k and peaks[j] - peaks[k] < distance_:
            keep[k] = 0
            k -= 1

        k = j + 1
        # Flag "later" peaks for removal until minimal distance is exceeded
        while k < peaks_size and peaks[k] - peaks[j] < distance_:
            keep[k] = 0
            k += 1

    return keep  # Return as boolean array

def threshold_detect(signal, threshold, cutoff=False, distance=False):
    '''lloyd russell, cutoff is added by HA. 
    Aug 2024: ST edited cutoff=False so any numerical value would activate cutoff
                also added functionality to define minimum distance between times, in cases where
                threshold_detect identifies 'thresholds' from square waves that dip and then rebound
    '''
    # thresh_signal = signal > threshold
    # thresh_signal[1:][thresh_signal[:-1] & thresh_signal[1:]] = False
    # times = np.where(thresh_signal)
    # return times[0]
    if cutoff:
        thresh_signal = (signal > threshold) & (signal < cutoff)
        thresh_signal[1:][thresh_signal[:-1] & thresh_signal[1:]] = False
        times = np.where(thresh_signal)[0]
    else:
        thresh_signal = signal > threshold
        thresh_signal[1:][thresh_signal[:-1] & thresh_signal[1:]] = False
        times = np.where(thresh_signal)[0]

    if distance: #if distance is specified as a numerical value, filter 
        keep = select_by_peak_distance(times, signal[times], distance)
        times_filtered = times[np.where(np.array(keep))[0]]
        return times_filtered
    else:
        return times

# Functions for reading in data from .paq files
def paq_data(paq, chan_name, threshold=1, distance=False, threshold_ttl=False, plot=False):
    '''
    Do not include any exclusion of data in this function
    returns the data in paq dictionary (from paq_read) from channel: chan_names
    if threshold_tll: returns sample that trigger occured on
    '''

    chan_idx = paq['chan_names'].index(chan_name)
    if len(paq['data'].shape) > 1:
        data = paq['data'][chan_idx, :]
    else: #if len(paq['data'].shape) == 1, paq['data'] is a one-dimensional array, calling a tuple will not work
        data = paq['data'][chan_idx]
    if threshold_ttl:
        data = threshold_detect(data,threshold, cutoff=False, distance=distance)

    if plot:
        if threshold_ttl:
            plt.plot(data, np.ones(len(data)), '.')
            plt.show()
        else:
            plt.plot(data)
            plt.show()
        plt.close()
    return data



def fetch_and_convert(eng, variable_name, data_type='numeric'):
    if data_type == 'numeric':
        data = eng.eval(f"data.{variable_name}", nargout=1)
        try: return [float(x[0]) for x in data]
        except: return[float(x) for x in data]
    elif data_type == 'categorical':
        data = eng.eval(f"cellstr(data.{variable_name})", nargout=1)
        return [str(x) for x in data]
    else:
        raise ValueError("Unsupported data_type. Use 'numeric' or 'categorical'.")
    
def read_json_file(filefolder, filename):
    """Sandra Tan 24/07/2024: Load data from json file"""
    json_file = constructPath([filefolder, filename])
    with open(json_file) as f:
        data = json.load(f)
    return data

def infoFromJSON(filepath, key='name', returnJSON=False):
    """Sandra Tan 24/07/2024
    Written to load _hardwareInfo.json file from filefolder (i.e. where block.mat files are stored)
    into a dictionary json_data, and use key-value pair to return the desired variable. 
    In this case use 'name' key to look for rig PC name and infer the rig e.g. BStim, dual2p etc"""
    if isinstance(filepath, list):
        json_file = constructPath(filepath)
    elif isinstance(filepath, string) and filepath.endswith('.json'):
        json_file = filepath
    else:
        print('There might be something wrong with your 1st argin, the filepath to .json file')
    with open(json_file) as f:
        json_data = json.load(f)
    valueToFind = json_data[key]
    if returnJSON:
        return json_data, valueToFind
    else:
        return valueToFind

def rig_from_PC(pc_name):
    """ Sandra Tan 24/07/2024
    Return the appropriate rig name depending on the user-inputted pc_name
    MAKE SURE THE ORDER BETWEEN PCnames and rigNames IS CORRECT """
    PCnames = ['win-al001', 'win-al002', 'win-al009', 'win-al010', 'win-al027', 'win-amp011', 'win-amp019']
    rigNames = ['BStim1', 'BStim2', 'BStim3', 'BStim4', 'Dual2p', 'Packer1', '3p']
    if pc_name in PCnames:
        rig_from_pc = rigNames[PCnames.index(pc_name)]
    else:
        print(f"WARNING: The PC name you gave ({pc_name}) is not one of these:", PCnames)
        rig_from_pc = None
    return rig_from_pc

def rig_from_JSON(filepath):
    pc_name = infoFromJSON(filepath, key='name')
    rig = rig_from_PC(pc_name)
    return rig

def dfIndFromValue(values_to_find, df_column):
    """Return list of indexes from dataframe df, where df_column matches values_to_find
    values_to_find: list
    df_column: e.g. info.recordingList.blockName"""
    indList = []
    if isinstance(values_to_find, str):
        values_to_find = [values_to_find]
    
    for value in values_to_find:
        try:
            ind = np.where(df_column == value)[0]
            if len(ind) == 1:
                indList.append(int(ind))
            elif len(ind)>1:
                for i in ind: indList.append(int(i)) #'flatten' the list
            elif len(ind) ==0:
                indList.append(np.nan) #not sure about this yet
        except:
            print(f'np.where() failed for {value}. NaN')
            indList.append(np.nan)
    return indList

def findDisengagTrialCutOff(beh_df, str_trialTypeCol, str_dataCmp, params, motiv_how='>', motiv_thresh=0):
    """Prune away trials where animal disengaged from task
    :param: beh_df = complete dataframe of all trials in session, must have the trial/stimulus type in a column
    :param: str_trialTypeCol = name of beh_df column with trial/stimulus type information
    :param: str_dataCmp = name of beh_df column storing behavioural engagement measured (e.g. list of lick rates). Should be of same length as beh_df 
    :param: motiv_how = how motivation is defined - e.g. dataCmp [>/</!=] motiv_thresh
    :param: motiv_thresh = quantitative measure by which engagement is defined through dataCmp 
    """
    default_params = {'ttype': '100% Rewarded',
                    'fraction_lastTrials':0.3, #last 30% of trials (of ttype) in which code will look for disengagement
                      'fraction_maxLastTrials': 0.85, #if disengagement is found within first 85% of all trials, code will suggest removing
    }
    original_params = copy.deepcopy(params)
    if params is None:
        params = default_params
    else:
        # Update params with any defaults for missing keys
        for key, value in default_params.items():
            params.setdefault(key, value)
    
    motiv_how_choices = ['<', '>', '!=']
    if motiv_how not in motiv_how_choices:
        raise ValueError("Invalid motiv_how. Expected one of: %s" % motiv_how_choices)
    
    fraction_lastTrials = params['fraction_lastTrials']
    fraction_maxLastTrials = params['fraction_maxLastTrials']

    tTypeTrialIdxs = np.where(beh_df[str_trialTypeCol]==params['ttype'])[0] #indexes of the selected trial type
    n_lastTrials = int(np.ceil(fraction_lastTrials*len(tTypeTrialIdxs)))
    lastTrials = beh_df.loc[tTypeTrialIdxs[-n_lastTrials:]] #slices out beh_df for the last 20% of tType trials
    # print(lastTrials[[str_trialTypeCol,str_dataCmp]])
    # lastTrialsDataCmp = lastTrials[str_dataCmp]
    if motiv_how == '>': #greater than
        lastTrialsEngaged = np.where(lastTrials[str_dataCmp]>motiv_thresh)[0]
    elif motiv_how == '<': #less than
        lastTrialsEngaged = np.where(lastTrials[str_dataCmp]<motiv_thresh)[0]
    elif motiv_how == '!=': #not equals to
        lastTrialsEngaged = np.where(lastTrials[str_dataCmp]!=motiv_thresh)[0]
    
    # print(lastTrialsEngaged)
    if len(lastTrialsEngaged)>0:
        idx_lastEngaged = int(lastTrials.index[lastTrialsEngaged[-1]]) #last index of tType identified with engagement

        if idx_lastEngaged/len(beh_df) < fraction_maxLastTrials:
            print(f"Mouse stopped engaging in {params['ttype']} trials after {int(idx_lastEngaged*100/len(beh_df))}% of session (Truncate at trial {idx_lastEngaged})")
            toTruncate = True
        else:
            print(f"Prelicks to {params['ttype']} stimulus stopped after trial {idx_lastEngaged} (Not recommending truncation)")
            idx_lastEngaged = None
            toTruncate = False
    else:
        print(f"Data suggests no disengagement found in last {fraction_lastTrials*100}% of {params['ttype']} trials.")
        idx_lastEngaged = None
        toTruncate = False

    return idx_lastEngaged, toTruncate

def test_responsive_pre_post(dff_pre, dff_post, testType='ttest'):
    """ ST 03/2025: Input the 'pre' and 'post' parts of the same 3D array as first 2 argin, in cell x time x trial format
    """
    assert (dff_pre.shape[0]==dff_post.shape[0]) & (dff_pre.shape[2]==dff_post.shape[2]), \
            f'Both 3D arrays must have same 1st and 3rd dimensions: {dff_pre.shape} vs {dff_post.shape}'
    meandff_pre = np.nanmean(dff_pre, axis=1) #cell x trial
    meandff_post = np.nanmean(dff_post, axis=1) #cell x trial
    #t test for signif differences between mean DFF 1 and DFF 2
    if testType =='ttest':
        _, pvals = stats.ttest_ind(meandff_pre, meandff_post, axis=1)
    elif testType =='wilcoxon':
        _, pvals = stats.wilcoxon(meandff_pre, meandff_post, axis=1)

    return meandff_pre, meandff_post, pvals

def test_responsive_acrossTrialTypes(dffTrace_aligned, params, frate=15, normalise=False,
                                     trialTypes=None, p_alpha=0.05):
    """ ST 03/2025: Iteratively return all cells in a dffTrace (cell x time x trial) 
        that respond significantly to any 1 trial type 
    """

    default_params = {'pre_stim_s': 3,
                   'post_stim_s': 6, # dffTrace time runs from -3s to +6s (aligned to stim)

                   'ttest_pre_stim_s':2,
                   'ttest_post_stim_s':4,
                   'verbose': False
                   }
    
    params = {**default_params, **params}
    trialTypes = list(dffTrace_aligned.keys()) if trialTypes is None else trialTypes

    dffTrace_startframe = int(np.ceil((params['pre_stim_s']-params['ttest_pre_stim_s'])*frate))
    dffTrace_endframe = int(np.ceil((params['pre_stim_s']+params['ttest_post_stim_s'])*frate))
    dffTrace_framerange = range(dffTrace_startframe, dffTrace_endframe)
    
    ttest_pre = int(np.ceil(params['ttest_pre_stim_s'])*frate)

    pval_alltrialTypes = {}
    significant_cells = []
    for tType in trialTypes:
            dffTrace_aligned_tType = dffTrace_aligned[tType][:,dffTrace_framerange,:] #cell x time x trial
            if normalise:
                dffTrace_aligned_tType = dFF_BaselineNormalisation(dffTrace_aligned_tType, 
                                                                   range(int(np.ceil(params['ttest_pre_stim_s']*frate))), 3)
            dffTrace_pre = dffTrace_aligned_tType[:,:ttest_pre,:]
            dffTrace_post = dffTrace_aligned_tType[:,ttest_pre:,:]
            
            _,_,pvals = test_responsive_pre_post(dffTrace_pre, dffTrace_post, testType='wilcoxon')
            pval_alltrialTypes[tType] = pvals

            significant_cells.append(np.where(pvals<p_alpha)[0])
            if params['verbose']: print(f"{len(np.where(pvals<p_alpha)[0])} / {pvals.shape[0]} cells significant for {tType} trials")

    significant_cells = flatten_lists(significant_cells)
    significant_cells = np.unique(significant_cells)
    print(f"{len(significant_cells)} / {pvals.shape[0]} unique cells significant (-{params['ttest_pre_stim_s']}s vs +{params['ttest_post_stim_s']}s) (alpha = {p_alpha})")
    print("--------------------")

    return pval_alltrialTypes, significant_cells

def wide_long_df_from_dffTrace(dffTrace, info_session, alignment='StimulusAligned', frate=15, normalise=False,
                             cells_ind=None, stack_time=False, return_params=False, save=False, **params):
    """ ST 03/2025: Creates a dictionary which can be converted into a longform dataframe by using pd.DataFrame({session_dict})
    :param: dffTrace        = (dict) from pd.read_pickle('.../.../imaging-dffTrace.pkl')
    :param: info_session    = row from info.recordingList.iloc[row_index] with the session's info (info.recordingList given by mfun.analysis())
    :param: alignment       = (str) 'StimulusAligned' or 'RewardAligned'; keys in dffTrace which lead to further dictionary with trialType > dff_cellxtimextrial
    :param: params          = (dict) stimulus duration and trial type information
    :param: frate           = (num) imaging frame rate in fps
    :param: normalise       = (bool) whether or not to normalise dff per cell per trial to its prewindow_s baseline
    :param: cells_ind       = (num or list) indexes of cells to include in dictionary output (if default None, will include all cells in dffTrace)
    :param: stack_time      = (bool or str) default False: dff as array in column dff / 
                              'row': dff for each frame is stacked in row, and denoted by new column frame_number (allows plotting using sns.lineplot(x='frame_number'), but takes time)
                              'column': dff for each frame is stacked along column, frame number denoted by column name 'frame_#' (for Antara's decoding analysis)

    :output: session_dict   = (dict) with keys: expRef, animalID, cellID, trialNumber, trialType, 
                                                (dff or frame_# of nframes), (opt: frame_number)
    """
    
    default_params = {'prestim_s': 3, # pre-stimulus duration in dffTrace (default is -3 based on cingulateDMS_extraction)
                      'poststim_s': 6, # post-stimulus duration in dffTrace (default is +6)
                      'stimDur_s': 2,

                      'prewindow_s':1, #desired pre-stimulus window in output
                      'postwindow_s':4, #desired post-stimulus window in output

                      'include_all_frames': False,

                      'trialTypes': ['100%', '50%', '0%'], #trial types' dff you want in output
                      'beh_df_tType_col': 'rewardProb',
                      }
    
    params = {**default_params, **params}
    frame_start = int(np.ceil(frate*(params['prestim_s']-params['prewindow_s'])))
    frame_end = int(np.ceil(frate*(params['prestim_s']+params['postwindow_s'])))
    dffTrace_framerange = np.arange(frame_start, frame_end)
    params['fRate'] = frate

    blockName = info_session['blockName']
    animal = info_session['animalID']
    beh_df = pd.read_csv(info_session['behFileName'])
    beh_df_tType_col = params['beh_df_tType_col']

    dffTrace_aligned = dffTrace[alignment]
    ncells = dffTrace_aligned[list(dffTrace_aligned.keys())[0]].shape[0]
    cells_ind = range(ncells) if cells_ind is None else cells_ind  # some cells or all cells
    try: iter(cells_ind)
    except: cells_ind = cells_ind

    print(f"utils: Creating a longform dictionary for {len(cells_ind)} cells in {blockName} (stacking dff: {stack_time})")

    expRef, animalID, cellID, trialNumber, trialType, frame_number, dff = [], [], [], [], [], [], []
    #Determine which trials to include
    trialTypes = params['trialTypes']
    
    for tType in trialTypes:
        # print(tType)
        if not params['include_all_frames']:
            dffTrace_stimAligned_tType = dffTrace_aligned[tType][:,dffTrace_framerange,:] #cell x time x trial
        else: dffTrace_stimAligned_tType = dffTrace_aligned[tType][:,:,:] #cell x time x trial

        if normalise:
            dffTrace_celltimetrial = dFF_BaselineNormalisation(dffTrace_stimAligned_tType, 
                                                               range(int(np.ceil(params['prewindow_s']*frate))), 3)
        else: dffTrace_celltimetrial = dffTrace_stimAligned_tType
        
        for cell in cells_ind:
            for trial_ind, trial in enumerate(dffTrace['trialIndices'][tType]):
                sub_dff = dffTrace_celltimetrial[cell,:,trial_ind] #1D array, of dff over frames/time
                # If this error occurs, the trial type assignment has gone out of order
                # assert beh_df[beh_df_tType_col][trial] == tType or beh_df[beh_df_tType_col][trial].startswith(tType), \
                #     f"Expected {tType}, found {beh_df[beh_df_tType_col][trial]} in beh_df instead"
                dff.append(sub_dff) #array with n flu for n frames

                trialNumber = trialNumber + [int(trial+1) for _ in range(len(dff)-len(trialNumber))] 
            cellID = cellID + [cell for _ in range(len(dff)-len(cellID))]
        trialType = trialType + [tType for _ in range(len(dff)-len(trialType))]

    expRef = [blockName for _ in range(len(dff))]
    animalID = [animal for _ in range(len(dff))]

    session_dict = {'expRef': expRef, 'animalID':animalID, 'cellID': cellID, 
                    'trialNumber': trialNumber, 'trialType': trialType}
    
    if not stack_time: 
        output_df = pd.DataFrame({**session_dict, 'dff':dff})
    elif stack_time=='column' or stack_time=='row': # needs more testing
        if len(np.array(dff).shape)>1: #.shape comes as a two-digit tuple corresponding to cell/trial x time
            output_df = pd.DataFrame(session_dict)
            output_df = pd.concat([output_df, pd.DataFrame(dff)], axis=1)
            if stack_time=='row': 
                output_df = output_df.melt(id_vars=['animalID', 'expRef', 'cellID', 'trialNumber', 'trialType'], var_name='frame_number', value_name='dff')
    else: print(f"stack_time should be False, 'column' or 'row', but is: {stack_time}")
    if save:
        output_pickle = params.copy()
        output_pickle['stack_time'] = stack_time
        output_pickle['df'] = output_df
        with open(os.path.join(info_session.analysisPath, f"widelongform_df.pkl"), 'wb') as f:
            pickle.dump(output_pickle, f)
        print(f"Saved wide/longform dataframe with params in {info_session.analysisPath}")

    if return_params: return output_df, params
    else: return output_df


############### OLD CODES ####################
def intersect(lst1, lst2):
    return list(set(lst1) & set(lst2)) 

def dfof(arr):
    '''takes 1d list or array or 2d array and returns dfof array of same
       dim (JR 2019) This is extraordinarily slow, use dfof2'''

    if type(arr) is list or type(arr) == np.ndarray and len(arr.shape) == 1:
        F = np.mean(arr)
        dfof_arr = [((f - F) / F) * 100 for f in arr]

    elif type(arr) == np.ndarray and len(arr.shape) == 2:
        dfof_arr = []
        for trace in arr:
            F = np.mean(trace)
            dfof_arr.append([((f - F) / F) * 100 for f in trace])

    else:
        raise NotImplementedError('input type not recognised')

    return np.array(dfof_arr)

def get_tiffs(path):

    tiff_files = []
    for file in os.listdir(path):
        if file.endswith('.tif') or file.endswith('.tiff'):
            tiff_files.append(os.path.join(path, file))

    return tiff_files

def correct_s2p_combined(s2p_path, n_planes):

    len_count = 0
    for i in range(n_planes):

        iscell = np.load(os.path.join(s2p_path, 'plane{}'.format(i), 
                                     'iscell.npy'), allow_pickle=True)

        if i == 0:
            allcells = iscell
        else:
            allcells = np.vstack((allcells, iscell))

        len_count += len(iscell)

    combined_iscell = os.path.join(s2p_path, 'combined', 'iscell.npy')

    ic = np.load(combined_iscell, allow_pickle=True)
    assert ic.shape == allcells.shape
    assert len_count == len(ic)

    np.save(combined_iscell, allcells)


def read_fiji(csv_path):
    '''reads the csv file saved through plot z axis profile in fiji'''

    data = []

    with open(csv_path, 'r') as csvfile:
        spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for i, row in enumerate(spamreader):
            if i == 0:
                continue
            data.append(float(row[0].split(',')[1]))

    return np.array(data)


# def save_fiji(arr):  # commented out by Thijs for compatibility
#     '''saves numpy array in current folder as fiji friendly tiff'''
#     tf.imsave('Vape_array.tiff', arr.astype('int16'))

def clean_traces(signalMain, **kwargs):
    '''takes a 2d array of traces and returns a 2d array of cleaned traces
       (HA 2023)
       
       '''

    signalMain[np.logical_not(pd.isna(signalMain))] = signal.detrend(signalMain[np.logical_not(pd.isna(signalMain))], **kwargs)

    return np.array(signalMain)

def pade_approx_norminv(p):
    q = math.sqrt(2*math.pi) * (p - 1/2) - (157/231) * math.sqrt(2) * \
        math.pi**(3/2) * (p - 1/2)**3
    r = 1 - (78/77) * math.pi * (p - 1/2)**2 + (241 * math.pi**2 / 2310) * \
        (p - 1/2)**4
    return q/r

def d_prime(hit_rate, false_alarm_rate):
    return pade_approx_norminv(hit_rate) - \
        pade_approx_norminv(false_alarm_rate)

def shutter_start_frame(paq=None, stim_chan_name=None, frame_clock=None,
                     stim_times=None, plane=0, n_planes=1,threshold=1,):
    ''' Only differences is NOT NEXT FRAME'''
    '''Returns the frames from a frame_clock that a stim occured on.
       Either give paq and stim_chan_name as arugments if using 
       unprocessed paq. 
       Or predigitised frame_clock and stim_times in reference frame
       of that clock

    '''

    if frame_clock is None:
        frame_clock = paq_data(paq, 'prairieFrame',threshold, threshold_ttl=True)
        stim_times = paq_data(paq, stim_chan_name,threshold, threshold_ttl=True)

    stim_times = [stim for stim in stim_times if stim < np.nanmax(frame_clock)]
    frames = []

    for stim in stim_times:
        # the sample time of the frame immediately preceeding stim
#         frame = next(frame_clock[i-1] for i, sample in enumerate(frame_clock[plane::n_planes])
#                      if sample - stim > 0)
        frame = next(i-1 for i, sample in enumerate(frame_clock[plane::n_planes])
                     if sample - stim > 0)
        frames.append(frame)
    frames = np.transpose(frames)
    return frames

def stim_start_frame_Dual2Psetup(frame_clock, stim_times, fs=20000):
    # used in the analysis code.
    ''' Returns the frames from the frame_clock immediately preeceding stim.
    This code needs the frame_clock from txt_file
    stim_times should be in sec, as it is multiplied by fs in the code to be comparable to frame_clock
    frame output is in terms of absolute paqIO frames (2p-frame), aligned to an imaging frame
    :param: fs  = 20000Hz (for PAQio) or 2000Hz for daq
    '''
    if isinstance(frame_clock, np.ndarray)==False and isinstance(frame_clock, list)==False:
        frame_clock = frame_clock.values #is this for if frame_clock is a dataframe, or a series?
    if isinstance(stim_times, np.ndarray)==False and isinstance(stim_times, list)==False:
        stim_times = stim_times.values

    plane=0
    n_planes=1 # might be useful in the future
    stim_times = [np.round(i*fs) for i in stim_times] #ST take this out if input stim_times is already multiplied by 20000
    # print(len(stim_times))
    stim_times = [stim if (stim < np.nanmax(frame_clock)) or np.isnan(stim) else stim_times[i] for i, stim in enumerate(stim_times)]
    # print(len(stim_times))
    frames = []

    for stim in stim_times:
        if ~np.isnan(stim) and (stim < np.nanmax(frame_clock)) and (stim > np.nanmin(frame_clock)):
        # the 2p frame number immediately preceding stim
            frame = next(frame_clock[i-1] for i, sample in enumerate(frame_clock[plane::n_planes])
                        if sample - stim > 0)
            frame = int(frame) #ST added this to avoid function outputting a list of [(ndarray())...]
        else:
            frame = np.nan

        frames.append(frame)
    return (frames)

def stim_start_frame(paq=None, stim_chan_name=None, frame_clock=None,
                     stim_times=None, threshold=1, plane=0, n_planes=1):
    # used in _analysis code.
    '''Returns the frames from a frame_clock that a stim occured on.
       Either give paq and stim_chan_name as arugments if using 
       unprocessed paq. 
       Or predigitised frame_clock and stim_times in reference frame
       of that clock

    '''

    if frame_clock is None:
        frame_clock = paq_data(paq, 'frame_clock',threshold, threshold_ttl=True)
        stim_times  = paq_data(paq, stim_chan_name,threshold, threshold_ttl=True)
        interStimFrameMin = 30 # 30 frames = 1 second
    elif frame_clock == 'BehOnly':
        frame_clock = paq_data(paq, 'pupilLoopback',threshold, threshold_ttl=True)
        stim_times  = paq_data(paq, stim_chan_name,threshold, threshold_ttl=True)
        interStimFrameMin = 0 # 30 frames = 1 second

    stim_times = [stim for stim in stim_times if stim < np.nanmax(frame_clock)]

    frames = []

    for stim in stim_times:
        # the sample time of the frame immediately preceeding stim
#         frame = next(frame_clock[i-1] for i, sample in enumerate(frame_clock[plane::n_planes])
#                      if sample - stim > 0)
        frame = next(i-1 for i, sample in enumerate(frame_clock[plane::n_planes])
                     if sample - stim > 0)
        frames.append(frame)

     # Exclude frames that are too close together
    first_ind = np.where(np.diff(frames)>interStimFrameMin)
    first_ind = np.concatenate(([0], first_ind[0]+1))
    frames = np.array(frames)
    frames = frames[first_ind]

    return (frames)

def myround(x, base=5):
    '''allow rounding to nearest base number for
       use with multiplane stack slicing'''

    return base * round(x/base)

def tseries_finder(tseries_lens, frame_clock, paq_rate=20000):

    ''' Finds chunks of frame clock that correspond to the tseries in 
        tseries lens
        tseries_lens -- list of the number of frames each tseries you want 
                        to find contains
        frame_clock  -- thresholded times each frame recorded in paqio occured
        paq_rate     -- input sampling rate of paqio

        '''

    # frame clock recorded in paqio, includes TTLs from cliking 'live' 
    # and foxy extras
    clock = frame_clock / paq_rate

    # break the recorded frame clock up into individual aquisitions
    # where TTLs are seperated by more than 1s
    gap_idx = np.where(np.diff(clock) > 1)
    gap_idx = np.insert(gap_idx, 0, 0)
    gap_idx = np.append(gap_idx, len(clock))
    chunked_paqio = np.diff(gap_idx)

    # are each of the frames recorded by the frame clock actually 
    # in processed tseries?
    real_frames = np.zeros(len(clock))
    # the max number of extra frames foxy could spit out
    foxy_limit = 20
    # the number of tseries blocks that have already been found
    series_found = 0
    # count how many frames have been labelled as real or not
    counter = 0

    for chunk in chunked_paqio:
        is_tseries = False

        # iterate through the actual length of each analysed tseries
        for idx, ts in enumerate(tseries_lens): 
            # ignore previously found tseries
            if idx < series_found:
                continue

            # the frame clock block matches the number of frames in a tseries
            if chunk >= ts and chunk <= ts + foxy_limit:
                # this chunk of paqio clock is a recorded tseries
                is_tseries = True
                # advance the number of tseries found so they are not 
                # detected twice
                series_found += 1
                break

        if is_tseries:
            # foxy bonus frames
            extra_frames = chunk - ts
            # mark tseries frames as real
            real_frames[counter:counter+ts] = 1
            # move the counter on by the length of the real tseries
            counter += ts
            # set foxy bonus frames to not real
            real_frames[counter:counter+extra_frames] = 0
            # move the counter along by the number of foxy bonus frames
            counter += extra_frames

        else:
            # not a tseries so just move the counter along by the chunk 
            # of paqio clock
            # this could be wrong, not sure if i've fixed the ob1 error,
            # go careful
            counter += chunk + 1

    real_idx = np.where(real_frames == 1)

    return frame_clock[real_idx]

def trace_splitter(trace,t_starts, pre_frames, post_frames):
    '''Split a fluoresence matrix into trial by trial array

       flu -- fluoresence matrix [num_cells x num_frames]
       t_starts -- the time each frame started
       pre_frames -- the number of frames before t_start
                     to include in the trial
       post_frames --  the number of frames after t_start
                       to include in the trial

       returns 
       trial_flu -- trial by trial array 
                    [num_cells x trial frames x num_trials]

       '''
    initial=True
    trial_trace = np.array
    for trial, t_start in enumerate(t_starts):
        # the trial occured before imaging started
    
        if (t_start-pre_frames) > 0: #ignore first trial 
        #     print('prb')
        #     continue
            flu_chunk = trace[t_start-pre_frames:t_start+post_frames]

            if initial==True:
                trial_trace = flu_chunk
                initial = False
            else:
                trial_trace = np.dstack((trial_trace, flu_chunk))

    return trial_trace

def flu_splitter(flu,t_starts, pre_frames, post_frames):
    '''Split a fluoresence matrix into trial by trial array

       flu -- fluoresence matrix [num_cells x num_frames]
       t_starts -- the time each frame started (ST: OR the imaging frame number of interest??)
       pre_frames -- the number of frames before t_start
                     to include in the trial
       post_frames --  the number of frames after t_start
                       to include in the trial

       returns 
       trial_flu -- trial by trial array 
                    [num_cells x trial frames x num_trials]

       '''
    initial = True
    # trial_flu = np.array
    for trial, t_start in enumerate(t_starts):
        # the trial occured before imaging started
        if ((t_start-pre_frames) > 0 ) & ((t_start+post_frames)<flu.shape[1]):
            flu_chunk = flu[:, t_start-pre_frames:t_start+post_frames]

            if initial == True:
                trial_flu = flu_chunk
                initial = False
            else:
                trial_flu = np.dstack((trial_flu, flu_chunk))

    return trial_flu


def flu_splitter2(flu, stim_times, frames_ms, pre_frames=10, post_frames=30):

    stim_idxs = stim_start_frame_Dual2Psetup (frames_ms, stim_times)

    stim_idxs = stim_idxs[:, np.where((stim_idxs[0, :]-pre_frames > 0) &
                                      (stim_idxs[0, :] + post_frames 
                                      < flu.shape[1]))[0]]

    n_trials = stim_idxs.shape[1]
    n_cells = frames_ms.shape[0]

    for i, shift in enumerate(np.arange(-pre_frames, post_frames)):
        if i == 0:
            trial_idx = stim_idxs + shift
        else:
            trial_idx = np.dstack((trial_idx, stim_idxs + shift))

    tot_frames = pre_frames + post_frames
    trial_idx = trial_idx.reshape((n_cells, n_trials*tot_frames))

    flu_trials = []
    for i, idxs in enumerate(trial_idx):
        idxs = idxs[~np.isnan(idxs)].astype('int')
        flu_trials.append(flu[i, idxs])

    n_trials_valid = len(idxs)
    flu_trials = np.array(flu_trials).reshape(
        (n_cells, int(n_trials_valid/tot_frames), tot_frames))

    return flu_trials

def flu_splitter3(flu, stim_times, frames_ms, pre_frames=10, post_frames=30):

    stim_idxs = stim_start_frame_Dual2Psetup (frames_ms, stim_times)

    # not 100% sure about this line, keep an eye
    stim_idxs[:, np.where((stim_idxs[0, :]-pre_frames <= 0) |
                          (stim_idxs[0, :] + post_frames 
                           >= flu.shape[1]))[0]] = np.nan

    n_trials = stim_idxs.shape[1]
    n_cells = frames_ms.shape[0]

    for i, shift in enumerate(np.arange(-pre_frames, post_frames)):
        if i == 0:
            trial_idx = stim_idxs + shift
        else:
            trial_idx = np.dstack((trial_idx, stim_idxs + shift))

    tot_frames = pre_frames + post_frames
    trial_idx = trial_idx.reshape((n_cells, n_trials*tot_frames))

    # flu_trials = np.repeat(np.nan, n_cells*n_trials*tot_frames)
    # flu_trials = np.reshape(flu_trials, (n_cells, n_trials, tot_frames))
    flu_trials = np.full_like(trial_idx, np.nan)
    # iterate through each cell and add trial frames
    for i, idxs in enumerate(trial_idx):

        non_nan = ~np.isnan(idxs)
        idxs = idxs[~np.isnan(idxs)].astype('int')
        flu_trials[i, non_nan] = flu[i, idxs]

    flu_trials = np.reshape(flu_trials, (n_cells, n_trials, tot_frames))
    return flu_trials

def closest_frame_before(clock, t):
    ''' Returns the idx of the frame immediately preceeding 
        the time t.
        Frame clock must be digitised and expressed
        in the same reference frame as t.
        '''
    subbed = np.array(clock) - t
    return np.where(subbed < 0, subbed, -np.inf).argmax()

def closest_frame(clock, t):
    ''' Returns the idx of the frame closest to  
        the time t. 
        Frame clock must be digitised and expressed
        in the same reference frame as t.
        '''
    subbed = np.array(clock) - t
    return np.argmin(abs(subbed))

def test_responsive(flu, frame_clock, stim_times, pre_frames=10, 
                    post_frames=10, pre_offset=0, offset=0, testType = 'ttest', fluMean=False):
    ''' Tests if cells in a fluoresence array are significantly responsive 
        to a stimulus

        Inputs:
        flu -- fluoresence matrix [n_cells x n_frames] likely dfof from suite2p
        frame_clock -- timing of the frames, must be digitised and in same 
                       reference frame as stim_times [ST: UNUTILISED?]
        stim_times -- times that stims to test responsiveness on occured, 
                      must be digitised and in same reference frame 
                      as frame_clock i.e. paqIO absolute beat
        pre_frames -- the number of frames before the stimulus occured to 
                      baseline with
        post_frames -- the number of frames after stimulus to test differnece 
                       compared
                       to baseline
        offset -- the number of frames to offset post_frames from the 
                  stimulus, so don't take into account e.g. stimulus artifact
        ##Added by ST 28/05/24
        pre_offset -- the number of frames to 'pre'-set pre_frames (i.e. from the reward so begin baseline from 2s before reward-frame in stim_times)
                        (don't recommend using both pre_offset and offset together, unless very clear understanding)
                        use for taking pre-reward-pre-stim baseline trace 
        ##
        
        Returns:
        pre -- matrix of fluorescence values in the pre_frames period 
               [n_cells x n_frames]
        post -- matrix of fluorescence values in the post_frames period 
                [n_cells x n_frames]
        pvals -- vector of pvalues from the significance test [n_cells]

        '''

    n_frames = flu.shape[1]

    pre_idx = np.repeat(False, n_frames)
    post_idx = np.repeat(False, n_frames)

    if fluMean==False: #means: flu -- fluoresence matrix [n_cells x n_frames] likely continuous dfof from suite2p
        # keep track of the previous stim frame to warn against overlap
        prev_frame = 0

        for i, stim_frame in enumerate(stim_times):
            if not np.isnan(stim_frame):
                stim_frame = int(stim_frame)
                if stim_frame-pre_frames-pre_offset <= 0 or stim_frame+post_frames+offset \
                >= n_frames:
                    continue
                elif stim_frame - pre_frames - pre_offset <= prev_frame:
                    print('WARNING: STA for stim number {} overlaps with the '
                        'previous stim pre and post arrays can not be '
                        'reshaped to trial by trial'.format(i))

                prev_frame = stim_frame

                pre_idx[stim_frame-pre_frames-pre_offset: stim_frame-pre_offset] = True
                post_idx[stim_frame+offset: stim_frame+post_frames+offset] = True
    else: # means: flu -- trial-averaged fluoresence matrix [Cell x frames]
        stim_frame = stim_times
        pre_idx[stim_frame-pre_frames-pre_offset: stim_frame-pre_offset] = True
        post_idx[stim_frame+offset: stim_frame+post_frames+offset] = True

    pre = flu[:, pre_idx]
    post = flu[:, post_idx]

    if testType =='ttest':
        _, pvals = stats.ttest_ind(pre, post, axis=1)
    elif testType =='wilcoxon':
        _, pvals = stats.wilcoxon(pre, post, axis=1)

    return pre, post, pvals

def test_responsive_timeXtrial(dff1, dff2, stim_frame, post_frames=10, testType='ttest'):
    # dff1 and dff2 should be cell x time x trials, post-stim activity, different trial blocks within session
    # Find mean dff1 and mean dff2 within analysis window (determined by stim_frame and post_frames) for each trial over each trial
    n_frames = dff1.shape[1]
    if n_frames != dff2.shape[1]:
        print('Error: dff1 and dff2 must have the same 2nd dimension (i.e. n_frames). cell x frame x trial')
    # Create Boolean mask for analysis window
    analysis_idx = np.repeat(False, n_frames)
    analysis_idx[stim_frame : stim_frame+post_frames] = True
    
    mean_dff1 = np.nanmean(dff1[:,analysis_idx, :], axis=1) # cell x trial
    mean_dff2 = np.nanmean(dff2[:,analysis_idx, :], axis=1)
    
    #t test for signif differences between mean DFF 1 and DFF 2
    if testType =='ttest':
        _, pvals = stats.ttest_ind(mean_dff1, mean_dff2, axis=1)
    elif testType =='wilcoxon':
        _, pvals = stats.wilcoxon(mean_dff1, mean_dff2, axis=1)

    return mean_dff1, mean_dff2, pvals

def cohend(d1, d2, axis=None):
    # calculate the size of samples
    if axis==None:
        n1, n2 = len(d1), len(d2)
    elif (type(axis)==float) or (type(axis)==int):
        n1, n2 = d1.shape[axis], d2.shape[axis]
    # calculate the variance of the samples
    s1, s2 = np.var(d1, ddof=1, axis=axis), np.var(d2, ddof=1, axis=axis)
    # calculate the pooled standard deviation
    s = np.sqrt(((n1 - 1) * s1 + (n2 - 1) * s2) / (n1 + n2 - 2))
    # calculate the means of the samples
    u1, u2 = np.nanmean(d1, axis=axis), np.nanmean(d2, axis=axis)
    # calculate the effect size
    return (u2 - u1) / s

def test_cohens_d(flu, stim_times, pre_frames=10, 
                    post_frames=10, pre_offset=0, offset=0, fluMean=False):
    ''' Tests if cells in a fluoresence array are significantly responsive 
        to a stimulus

        Inputs:
        flu -- fluoresence matrix [n_cells x n_frames] likely dfof from suite2p
        stim_times -- times that stims to test responsiveness on occured, 
                      must be digitised and in same reference frame 
                      as frame_clock i.e. paqIO absolute beat
        pre_frames -- the number of frames before the stimulus occured to 
                      baseline with
        post_frames -- the number of frames after stimulus to test differnece 
                       compared
                       to baseline
        offset -- the number of frames to offset post_frames from the 
                  stimulus, so don't take into account e.g. stimulus artifact
        ##Added by ST 28/05/24
        pre_offset -- the number of frames to 'pre'-set pre_frames (i.e. from the reward so begin baseline from 2s before reward-frame in stim_times)
                        (don't recommend using both pre_offset and offset together, unless very clear understanding)
                        use for taking pre-reward-pre-stim baseline trace 
        ##
        
        Returns:
        pre -- matrix of fluorescence values in the pre_frames period 
               [n_cells x n_frames]
        post -- matrix of fluorescence values in the post_frames period 
                [n_cells x n_frames]
        pvals -- vector of pvalues from the significance test [n_cells]

        '''
    n_frames = flu.shape[1]
    pre_idx = np.repeat(False, n_frames)
    post_idx = np.repeat(False, n_frames)

    if fluMean==False: #means: flu -- fluoresence matrix [n_cells x n_frames] likely continuous dfof from suite2p
        # keep track of the previous stim frame to warn against overlap
        prev_frame = 0

        for i, stim_frame in enumerate(stim_times):
            stim_frame = int(stim_frame)
            if stim_frame-pre_frames-pre_offset <= 0 or stim_frame+post_frames+offset \
            >= n_frames:
                continue
            elif stim_frame - pre_frames - pre_offset <= prev_frame:
                print('WARNING: STA for stim number {} overlaps with the '
                    'previous stim pre and post arrays can not be '
                    'reshaped to trial by trial'.format(i))

            prev_frame = stim_frame

            pre_idx[stim_frame-pre_frames-pre_offset: stim_frame-pre_offset] = True
            post_idx[stim_frame+offset: stim_frame+post_frames+offset] = True
    else: # means: flu -- trial-averaged fluoresence matrix [Cell x frames]
        stim_frame = stim_times
        pre_idx[stim_frame-pre_frames-pre_offset: stim_frame-pre_offset] = True
        post_idx[stim_frame+offset: stim_frame+post_frames+offset] = True

    pre = flu[:, pre_idx]
    post = flu[:, post_idx]

    d = cohend(pre, post, axis=1)
    return d


def build_flu_array(run, stim_times, pre_frames=10, post_frames=50,
                    use_spks=False, use_comps=False, is_prereward=False):

    ''' converts [n_cells x n_frames] matrix to trial by trial array
        [n_cells x n_trials x pre_frames+post_frames]

        Inputs:
        run -- BlimpImport object with attributes flu and frames_ms
        stim_times -- times of trial start stims, should be same
                      reference frame as frames_ms
        pre_frames -- number of frames before stim to include in
                      trial
        post_frames -- number of frames after stim to include 
                       in trial

        Returns:
        flu_array -- array [n_cells x n_trials x pre_frames+post_frames]

    '''

    if use_spks:
        flu = run.spks
    elif use_comps:
        flu = run.comps
    else:
        flu = run.flu

    if is_prereward:
        frames_ms = run.frames_ms_pre
    else:
        frames_ms = run.frames_ms

    # split flu matrix into trials based on stim time
    flu_array = flu_splitter3(flu, stim_times, frames_ms,
                              pre_frames=pre_frames, post_frames=post_frames)

    return flu_array

def averager(array_list, pre_frames=10, post_frames=50, offset=0, 
             trial_filter=None, plot=False, fs=5):

    ''' Averages list of trial by trial fluoresence arrays and can 
        visualise results

        Inputs:
        array_list -- list of tbt fluoresence arrays
        pre_frames -- number of frames before stim to include in
                      trial
        post_frames -- number of frames after stim to include 
                       in trial
        offset -- number of frames to offset post_frames to avoid artifacts
        trial_filter -- list of trial indexs to include 
        plot -- whether to plot result
        fs -- frame rate / plane

        Returns:
        session_average -- mean array [n_sessions x pre_frames+post_frames]
        scaled_average -- same as session average but all traces start 
                          at dfof = 0
        grand_average -- average across all sessions [pre_frames + post_frames]
        cell_average -- list with length n_sessions contains arrays 
                        [n_cells x pre_frames+post_frames]

        '''

    if trial_filter:
        assert len(trial_filter) == len(array_list)
        array_list = [arr[:, filt, :]
                      for arr, filt in zip(array_list, trial_filter)]

    n_sessions = len(array_list)

    cell_average = [np.nanmean(k, 1) for k in array_list]

    session_average = np.array([np.nanmean(np.nanmean(k, 0), 0)
                               for k in array_list])

    scaled_average = np.array([session_average[i, :] - session_average[i, 0]
                               for i in range(n_sessions)])

    grand_average = np.nanmean(scaled_average, 0)

    if plot:
        x_axis = range(len(grand_average))
        plt.plot(x_axis, grand_average)
        plt.plot(x_axis[0:pre_frames],
                 grand_average[0:pre_frames], color='red')
        plt.plot(x_axis[pre_frames+offset:pre_frames+offset
                 +(post_frames-offset)], grand_average[pre_frames+offset:
                 pre_frames+offset+(post_frames-offset)], color='red')
        for s in scaled_average:
            plt.plot(x_axis, s, alpha=0.2, color='grey')

        plt.ylabel(r'$\Delta $F/F')
        plt.xlabel('Time (Seconds)')
        plt.axvline(x=pre_frames-1, ls='--', color='red')

    return session_average, scaled_average, grand_average, cell_average

def lick_binner(paqData, trial_start, stChanName, threshold=1, distance=False, stimulation=False):
    ''' makes new easytest binned lick variable in run object 
    ST 06/08/2024: edited to accept lick data 
    directly stored in paqData (i.e. no need to pull out stChanName if stChanName=None)
    also added optional input threshold to specify your own threshold'''

    if stChanName is not None:
        licks = paq_data(paqData, stChanName, threshold=threshold, distance=distance, threshold_ttl=True)
    else:
        licks = threshold_detect(paq_data, threshold, cutoff=False, distance=distance)

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

def preprocessLicks(unpickledLicks, beh_df, behStr_OnsetTime, preStimTime=None, 
                    stChanName='lick', lickInterval=160, fRate=2000, rig=False):
    """ ST 09/24: 
    """
    # unpickledLicks = pd.read_pickle(recordingList[str_lickFileName][ind])
    # beh_df = pd.read_csv(recordingList.behFileName[ind])

    if rig:
        if rig =='BStim2': #BStim2 has variable signal max
            if np.nanmax(unpickledLicks['data']) < 9: threshold_lick = 4.9
            else: threshold_lick = 9
        else: 
            if 'BStim' in rig: threshold_lick = 4.9
            else: threshold_lick = 4.9
    else: 
        print('Rig not defined, lick threshold set as 4.9')
        threshold_lick = 4.9
    # print(f"threshold_lick is {threshold_lick}")

    trial_startTimes = (beh_df[behStr_OnsetTime] - preStimTime)*fRate
    licks, session_lick = lick_binner(unpickledLicks, trial_startTimes, stChanName, 
                                      threshold=threshold_lick, distance=lickInterval)
    
    if (preStimTime is not None) and ((rig=='BStim2') or (rig=='BStim4') or (rig=='BStim1')):
        # Remove first lick from all rewarded trials if rig is BStim1/2/4, due to bleedover from reward signal
        #if 1 of these rigs, scrub the false 1st 'lick' in rewarded trials 
        trials_areRewarded = beh_df['rewardVolume']>0 #true/false series with as many elements as there are trials
        # print(trials_areRewarded.values)
        for i in np.where(trials_areRewarded.values==True)[0]: #for rewarded trial indices 
            if len(session_lick[i]) >0:
                # reward time in terms of trialStartTimes
                rewardFrame = (preStimTime + (beh_df['rewardTime'][i] - beh_df['stimulusOnsetTime'][i])) * fRate #beh_df['trialOffsets'] not added here because this is only for BStim experiments
                postRewardFrame = rewardFrame+(preStimTime*fRate) #look for licks within preRewardTime=3 seconds post-outcome
                if (np.where(session_lick[i]>rewardFrame) & (session_lick[i]<postRewardFrame)[0]).size != 0: #array of indices in animal_lick with values i.e. timings >rewardFrame and <postRewardFrame
                    session_lick[i] = np.delete(session_lick[i], np.where((session_lick[i]>rewardFrame))[0][0]) #delete the first lick event after reward onset, because this is just a reward delivery
    
    return licks, session_lick

def dFF_BaselineNormalisation(dff, baselineWindow, expectedDim, axis_time=1, is_cell=None):
    """ ST 10/2024: for every signal value across time in dff, subtract mean signal during baselineWindow, on a cell-by-cell and trial-by-trial (if applicable) basis
    :param: dff             - can be dffTrace_mean (cell x time) or dffTrace (cell x time x trial); use expectedDim to confirm this
    :param: baselineWindow  - use something like np.arange(windowStart:windowEnd). Specifies baseline time epoch in dff to calculate mean baseline
    :param: expectedDim     - expected number of dimensions (2 or 3) of dff
    :param: axis_time       - axis along which time is computed (likely 1)
    :param: zScore_across_time - default False, best would be to zscore flu (cell x all time)
    """
    if not (dff is None or (dff== np.asarray(None)).all()):
        if ~np.isnan(dff).all():
            assert len(dff.shape)==expectedDim, f"dff is {len(dff.shape)}D array, but expected {expectedDim} dimensions"
            assert axis_time < expectedDim, f"Axis of time given as {axis_time}, but this is greater than expected dimensions {expectedDim}"

            # make is_cell accordingly
            is_cell = np.arange(0, dff.shape[0]) if is_cell is None else is_cell

            if expectedDim==2 and axis_time==1: # dff mean dimensions = cell x time
                baselineMean = np.mean(dff[:, baselineWindow], axis=axis_time) # each cell's baseline mean, 1D array (ncell,)
                dff_minusBaselineMean = dff-baselineMean[:,None] # cell x time # Must broadcast baselineMean to a compatible array shape for dff
                answer=dff_minusBaselineMean[is_cell]
            elif expectedDim==3 and axis_time==1: # dff dimensions = cell x time x trial
                baselineMean = np.mean(dff[:,baselineWindow,:], axis=axis_time) # baseline mean of each trial for every cell, 2D array (ncell, trial)
                # print(f"baselineMean shape: {baselineMean[:,None, :].shape}")
                dff_minusBaselineMean = dff-baselineMean[:,None, :] # cell x time x trial -- by broadcasting cell x trial into a 3D array like this (cell x time x trial), it subtracts the cell x trial mean across time dimensions 
                answer = dff_minusBaselineMean[is_cell]
        else: answer = None
    else: answer = None

    return answer

def scale_cell_activity(neural_data): 
    # min-max scaling for each neuron for values between [0,1] *(removes negative values)
    # neural_data = np.array([d / np.nanmax(d) for d in np.array([d - np.nanmin(d) for d in neural_data])])
    neural_data = np.array([(d-np.nanmin(d))/np.nanmax(d) for d in neural_data])
    return neural_data

def prepost_diff(array_list, pre_frames=10,
                 post_frames=50, offset=0, filter_list=None):

    n_sessions = len(array_list)

    if filter_list:
        array_list = [array_list[i][:, filter_list[i], :]
                      for i in range(n_sessions)]

    session_average, _, _, cell_average = averager(
        array_list, pre_frames, post_frames)

    post = np.nanmean(
                      session_average[:, pre_frames+offset:pre_frames+offset
                      +(post_frames-offset)], 1
                     )
    pre = np.nanmean(session_average[:, 0:pre_frames], 1)

    return post - pre

def raster_plot(arr, y_pos=1, color=np.random.rand(3,), alpha=1,
                marker='.', markersize=12, label=None):

    plt.plot(arr, np.ones(len(arr)) * y_pos, marker,
             color=color, alpha=alpha, markersize=markersize,
             label=label)

def get_spiral_start(x_galvo, debounce_time):
    
    """ Get the sample at which the first spiral in a trial began 
    
    Experimental function involving lots of magic numbers
    to detect spiral onsets.
    Failures should be caught by assertion at end
    Inputs:
    x_galvo -- x_galvo signal recorded in paqio
    debouce_time -- length of time (samples) encapulsating a whole trial
                    ensures only spiral at start of trial is captured
    
    """
    #x_galvo = np.round(x_galvo, 2)
    x_galvo = my_floor(x_galvo, 2)
    
    # Threshold above which to determine signal as onset of square pulse
    square_thresh = 0.02
    # Threshold above which to consider signal a spiral (empirically determined)
    diff_thresh = 10
    
    # remove noise from parked galvo signal
    x_galvo[x_galvo < -0.5] = -0.6
    
    diffed = np.diff(x_galvo)
    # remove the onset of galvo movement from f' signal
    diffed[diffed > square_thresh] = 0
    diffed = non_zero_smoother(diffed, window_size=200)
    diffed[diffed>30] = 0
    
    # detect onset of sprials
    spiral_start = threshold_detect(diffed, diff_thresh) #if cutoff is needed, please see threshold_detect() def
    
    if len(spiral_start) == 0:
        print('No spirals found')
        return None
    else:
        # Debounce to remove spirals that are not the onset of the trial
        spiral_start = spiral_start[np.hstack((np.inf, np.diff(spiral_start))) > debounce_time]
        n_squares = len(threshold_detect(x_galvo, -0.5))
        assert len(spiral_start) == n_squares, \
        'spiral_start has len {} but there are {} square pulses'.format(len(spiral_start), n_squares)
        return spiral_start

def non_zero_smoother(arr, window_size=200):
    
    """ Smooths an array by changing values to the number of
        non-0 elements with window
        
        """
    
    windows = np.arange(0, len(arr), window_size)
    windows = np.append(windows, len(arr))

    for idx in range(len(windows)):

        chunk_start = windows[idx]
        
        if idx == len(windows) - 1:
            chunk_end = len(arr)
        else:
            chunk_end = windows[idx+1]
            
        arr[chunk_start:chunk_end] = np.count_nonzero(arr[chunk_start:chunk_end])
    
    return arr

def my_floor(a, precision=0):
    # Floors to a specified number of dps
    return np.round(a - 0.5 * 10**(-precision), precision)

def get_trial_frames(clock, start, pre_frames, post_frames, paq_rate=2000, fs=30):

    # The frames immediately preceeding stim
    start_idx = closest_frame_before(clock, start)
    frames = np.arange(start_idx-pre_frames, start_idx+post_frames)
    
    # Is the trial outside of the frame clock
    is_beyond_clock = np.max(frames) >= len(clock) or np.min(frames) < 0
    
    if is_beyond_clock:
        return None, None
    
    frame_to_start = (start - clock[start_idx]) / paq_rate  # time (s) from frame to trial_start
    frame_time_diff = np.diff(clock[frames]) / paq_rate  # ifi (s)
    
    # did the function find the correct frame
    is_not_correct_frame = clock[start_idx+1]  < start or clock[start_idx] > start
    # the nearest frame to trial start was not during trial
    # if the time to the nearest frame is less than upper bound of inter-frame-interval
    trial_not_running = frame_to_start > 1/(fs-1)
    frames_not_consecutive = np.max(frame_time_diff) > 1/(fs-1)
    
    if trial_not_running or frames_not_consecutive:
        return None, None
    
    return frames, start_idx

def adamiser(string):
    words = string.split(' ')
    n_pleases = int(len(words) / 10)
    
    for please in range(n_pleases):
        idx = randrange(len(words))
        words.insert(idx, 'please')
        
    n_caps = int(len(words) / 3)
    for cap in range(n_caps):
        idx = randrange(len(words))
        words[idx] = words[idx].upper()
        
    return ' '.join(words)

def between_two_hits(idxs, easy_idxs, easy_outcome):
    
    assert len(easy_idxs) == len(easy_outcome)
    
    # Next easy trial from each test trial
    closest_after = np.array([bisect.bisect_left(easy_idxs, idx) for idx in idxs])
    # Previous easy trial from each test trial
    closest_before = closest_after - 1
    # Test trials before the first easy trial should have both previous and next
    # as the first easy trial
    closest_before[closest_before==-1] = 0
    # Test trials after the last easy trial should have both previous and next
    # as the last easy trial
    closest_after[idxs>easy_idxs[-1]] = len(easy_idxs)-1
    
    assert len(idxs) == len(closest_before) == len(closest_after)
    
    between_two = []
    for before, after in zip(closest_before, closest_after):
        if easy_outcome[before] and easy_outcome[after] == 'hit':
            between_two.append(True)
        else:
            between_two.append(False)
    
    assert len(between_two) == len(idxs)
    
    return between_two

def points_in_circle_np(radius, x0=0, y0=0, ):
    x_ = np.arange(x0 - radius - 1, x0 + radius + 1, dtype=int)
    y_ = np.arange(y0 - radius - 1, y0 + radius + 1, dtype=int)
    x, y = np.where((x_[:,np.newaxis] - x0)**2 + (y_ - y0)**2 <= radius**2)
    for x, y in zip(x_[x], y_[y]):
        yield x, y

def build_frames_ms(flu, cell_plane, paqio_frames, aligner, num_planes):

    ''' builds frames_ms matrix (see preprocess_flu)
        aligner -- rsync object from rsync_aligner
   
        '''
    # convert paqio recorded frames to pycontrol ms
    ms_vector = aligner.B_to_A(paqio_frames) # flat list of plane 
                                             # times
    if num_planes == 1:
        return ms_vector
    
    # matrix of frame times in ms for each fluorescent value 
    # in the flu matrix
    frames_ms = np.empty(flu.shape)
    frames_ms.fill(np.nan)
 
    # mark each frame with a time in ms based on its plane
    for plane in range(num_planes):
        frame_times = ms_vector[plane::num_planes]
        plane_idx = np.where(cell_plane==plane)[0]
        frames_ms[plane_idx, 0:len(frame_times)] = frame_times

    return frames_ms

def seriesStrings_to_list(seriesA, str_split=', ', str_remove="'[]"):
    """Takes a series in which each value is a string instead of a list, and converts it back into a list.
        Do this by removing characters (such as [ ] ') and then splitting using a string (e.g. ', ' or '\n')
    """
    if isinstance(seriesA, pd.Series):
        output = []
        for a_string in seriesA:
            a_list = a_string.translate({ord(i):None for i in str_remove})
            a_list = a_list.split(str_split)
            output.append(a_list)
    else: print('First input argument is not a series; please rectify.')
    return output

def find_max_list(list1):
    list_lens = [len(i) for i in list1]
    return max(list_lens)

def userWarn():
    """Function for suppressing user warnings
        To use, write problematic code as such:

        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            utils.userWarn()
            #Code starts here#
    """
    warnings.warn("UserWarning arose", UserWarning)
def futureWarn():
    warnings.warn("UserWarning arose", FutureWarning)

class LoadMat():
    def __init__(self, filename):

        '''
        This function should be called instead of direct spio.loadmat
        as it cures the problem of not properly recovering python dictionaries
        from mat files. It calls the function check keys to cure all entries
        which are still mat-objects
        
        Mostly stolen from some hero https://stackoverflow.com/a/8832212
        
        '''

        self.dict_ = spio.loadmat(filename, struct_as_record=False, squeeze_me=True)

        self._check_keys()

    def _check_keys(self):

        '''
        checks if entries in dictionary are mat-objects. If yes
        todict is called to change them to nested dictionaries
        '''
        for key in self.dict_:
            if isinstance(self.dict_[key], spio.matlab.mio5_params.mat_struct):
                self.dict_[key] = self._todict(self.dict_[key])

    @staticmethod
    def _todict(matobj):
        '''
        A recursive function which constructs from matobjects nested dictionaries
        '''
        dict_ = {}
        for strg in matobj._fieldnames:
            elem = matobj.__dict__[strg]
            if isinstance(elem, spio.matlab.mio5_params.mat_struct):
                dict_[strg] = LoadMat._todict(elem)
            else:
                dict_[strg] = elem
        return dict_


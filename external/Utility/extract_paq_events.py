import paq2py
import numpy as np
import glob, os

def extract_paq_data_frame(paq_filepath):
    """Return dict of frame numbers for
    imaging frames and reward times. These are taken as the RISE TIME of each event voltage pulse.
    
    :param: paq_filepath - filepath to PAQ file
    :param: imaging_frame_filename - filepath for storing frame number for imaging frames
    :param: reward_frame_filename - filepath for storing frame number for reward events
    """
    paq = paq2py.paq_read(paq_filepath, plot=False)
    threshold_volts = 2.5

    idx_imaging = paq["chan_names"].index('frame_clock')
    idx_reward = paq["chan_names"].index('reward')

    frame_count_imaging = np.flatnonzero((paq["data"][idx_imaging][:-1] < threshold_volts) & (paq["data"][idx_imaging][1:] > threshold_volts))+1
    frame_count_reward = np.flatnonzero((paq["data"][idx_reward][:-1] < threshold_volts) & (paq["data"][idx_reward][1:] > threshold_volts))+1

    imaging_frame_filename = paq_filepath.replace('.paq','_imaging_frames.txt')
    with open(imaging_frame_filename, "w") as f:
        f.write('\n'.join(str(f) for f in frame_count_imaging))
    print("Saved file:", imaging_frame_filename)

    reward_frame_filename = paq_filepath.replace('.paq','_reward_frames.txt')
    with open(reward_frame_filename, "w") as f:
        f.write('\n'.join(str(f) for f in frame_count_reward))
    print("Saved file:", reward_frame_filename)

if __name__ == "__main__":
    for file in glob.glob("*.paq"): 
        print("Found PAQ file", file)
        extract_paq_data_frame(file)
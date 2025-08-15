# This code is from VAPE, Packer LAb 06/03/2022

import numpy as np
import pandas as pd
import LakLabAnalysis.Utility.utils_funcs as utils # utils is from Vape - catcher file: 
import plot_funcs as pfun
import os
from scipy.stats import zscore
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib
import matplotlib.offsetbox
from matplotlib.lines import Line2D 
import main_funcs as mfun
import copy
import matplotlib
from scipy import stats
import statsmodels.api as sm
import glob

def plot_paq_pickle(paqpklfilepath, plot = False):
    temp = pd.read_pickle(paqpklfilepath)
    num_chans = len(temp['chan_names'])
    chan_names = temp['chan_names']
    data = temp['data']
    num_datapoints = len(data[0])
    units = temp['units']
    f, axes = plt.subplots(num_chans, 1, sharex=True)

    for idx, ax in enumerate(axes):
        ax.plot(data[idx])
        ax.set_xlim([0, num_datapoints - 1])
        ax.set_ylabel(units[idx])
        ax.set_title(chan_names[idx])
    if plot:
        plt.show()
    return temp

def set_figure():
    from matplotlib import rcParams
        # set the plotting values
    rcParams['figure.figsize'] = [12, 12]
    rcParams['font.size'] = 12
    rcParams['font.family'] = 'sans-serif'
    rcParams['font.sans-serif'] = ['Arial']

    rcParams['axes.spines.right']  = False
    rcParams['axes.spines.top']    = False
    rcParams['axes.spines.left']   = True
    rcParams['axes.spines.bottom'] = True

    params = {'axes.labelsize': 'large',
            'axes.titlesize':'large',
            'xtick.labelsize':'large',
            'ytick.labelsize':'large',
            'legend.fontsize': 'large'}
    
    rcParams.update(params)

def save_figure(name, base_path, format='png'):
    if isinstance(base_path, str): #to enable saving same figure to multiple folders, without needing to redraw
        base_path = [base_path]
    if isinstance(format, str):
        format = [format]

    for base_path_n in base_path:
        if not os.path.exists(base_path_n):
            os.makedirs(base_path_n)
        for format_n in format:
            plt.savefig(os.path.join(base_path_n, f'{name}.{format_n}'), 
                bbox_inches='tight', transparent=False, format=format_n)
            
    if len(base_path)>1: print(f'Saved "{name}" as {", ".join(format)} in {base_path[0]} and {len(base_path[1:])} others')
    else: print(f'Saved "{name}" as {", ".join(format)} in {base_path[0]}')
    
def save_figureAll(name,base_path):
    plt.savefig(os.path.join(base_path, f'{name}.png'), 
                bbox_inches='tight', transparent=False)
    plt.savefig(os.path.join(base_path, f'{name}.svg'), 
               bbox_inches='tight', transparent=True)

# def xticklabels_range(start, end, interval, include_end=False):
#     if start==0:
#         start_to_lastMultiple = np.arange(start, end, interval)
#     elif start==1:
#         start_to_lastMultiple = np.arange(interval, end, interval)
#         start_to_lastMultiple = np.insert(start_to_lastMultiple, 0, 1)
#     if include_end and end not in start_to_lastMultiple:
#         final = np.append(start_to_lastMultiple, end)
#     else: final = start_to_lastMultiple
#     return final

def xtick_locs_framestoseconds(pre_zero_s=0, post_zero_s=6, fRate=15):
    """ST 04/2025: When converting from frames to seconds, gives the appropriate x tick labels and x tick locations
    for the x axis"""
    xticklabels = list(np.arange(-1*pre_zero_s, post_zero_s, dtype=int))
    xticklocs = [int(np.ceil(i * fRate)) for i in range(len(xticklabels))]

    return xticklabels, xticklocs # use ax.set_xticks(xticklocs) and ax.set_xticklabels(xticklabels)

class AnchoredHScaleBar(matplotlib.offsetbox.AnchoredOffsetbox):
    """ size: length of bar in data units
        extent : height of bar ends in axes units """
    def __init__(self, size=1, extent = 0.03, label="", loc=2, ax=None,
                pad=0.4, borderpad=0.5, ppad = 0, sep=2, prop=None, 
                frameon=True, linekw={'color': 'k'}, **kwargs):
        if not ax:
            ax = plt.gca()
        trans = ax.get_yaxis_transform()
        size_bar = matplotlib.offsetbox.AuxTransformBox(trans)
        line = Line2D([0,0],[size,0], **linekw)
        hline1 = Line2D([-extent/2.,0],[0,0], **linekw)
        hline2 = Line2D([-extent/2.,0],[size,size], **linekw)
        size_bar.add_artist(line)
        size_bar.add_artist(hline1)
        size_bar.add_artist(hline2)


        txt = matplotlib.offsetbox.TextArea(label, textprops={'color': linekw['color']})
        self.vpac = matplotlib.offsetbox.VPacker(children=[size_bar,txt],  
                                align="center", pad=ppad, sep=sep) 
        matplotlib.offsetbox.AnchoredOffsetbox.__init__(self, loc, pad=pad, 
                borderpad=borderpad, child=self.vpac, prop=prop, frameon=frameon,
                **kwargs) 
        
class AnchoredHorizontalScaleBar(matplotlib.offsetbox.AnchoredOffsetbox):
    """ size: length of bar in data units
        extent : height of bar ends in axes units 
        Creates a **horizontal** object to add to your axs using Axes.add_artist(self)"""
    def __init__(self, size=1, extent = 0.03, label="", loc=2, ax=None,
                pad=0.4, borderpad=0.5, ppad = 0, sep=2, prop=None, 
                frameon=True, linekw={'color': 'k'}, **kwargs):
        if not ax:
            ax = plt.gca()
        trans = ax.get_yaxis_transform()
        size_bar = matplotlib.offsetbox.AuxTransformBox(trans)
        line = Line2D([0,size],[0,0], **linekw)
        hline1 = Line2D([-extent/2.,0],[0,0], **linekw)
        hline2 = Line2D([-extent/2.,0],[size,size], **linekw)
        size_bar.add_artist(line)
        size_bar.add_artist(hline1)
        size_bar.add_artist(hline2)

        txt = matplotlib.offsetbox.TextArea(label, textprops=linekw)
        self.vpac = matplotlib.offsetbox.VPacker(children=[size_bar,txt],  
                                align="center", pad=ppad, sep=sep) 
        matplotlib.offsetbox.AnchoredOffsetbox.__init__(self, loc, pad=pad, 
                borderpad=borderpad, child=self.vpac, prop=prop, frameon=frameon,
                **kwargs) 

def fig_legend(fig, **kwdargs):
    ## ST 2024: by gboffi https://stackoverflow.com/questions/9834452/how-do-i-make-a-single-legend-for-many-subplots
    ## iterates over subplots in fig and gets their legend handles and labels

    # Generate a sequence of tuples, each contains
    #  - a list of handles (lohand) and
    #  - a list of labels (lolbl)
    tuples_lohand_lolbl = (ax.get_legend_handles_labels() for ax in fig.axes)
    # E.g., a figure with two axes, ax0 with two curves, ax1 with one curve
    # yields:   ([ax0h0, ax0h1], [ax0l0, ax0l1]) and ([ax1h0], [ax1l0])

    # The legend needs a list of handles and a list of labels,
    # so our first step is to transpose our data,
    # generating two tuples of lists of homogeneous stuff(tolohs), i.e.,
    # we yield ([ax0h0, ax0h1], [ax1h0]) and ([ax0l0, ax0l1], [ax1l0])
    tolohs = zip(*tuples_lohand_lolbl)

    # Finally, we need to concatenate the individual lists in the two
    # lists of lists: [ax0h0, ax0h1, ax1h0] and [ax0l0, ax0l1, ax1l0]
    # a possible solution is to sum the sublists - we use unpacking
    handles, labels = (sum(list_of_lists, []) for list_of_lists in tolohs)

    # Call fig.legend with the keyword arguments, return the handles and labels

    return (handles, labels)

def lineplot_sessions(dffTrace_mean,analysis_params, colormap,
                    duration,zscoreRun, savefigname, savefigpath ) :
    default_params = { 'fRate_imaging': 15, # refers to 2p imaging fRate Hz
                        'fRate_beh': 1000, # refers to 1000 ms in 1 s
                        'pre_ms' : 2000.0, # in ms 
                        'post_ms' : 6000.0, # in ms
                        'analysisWindowDur' : 2000.0, # in ms    
                        'stimTypes':dffTrace_mean.keys(),
                        }
    
    if analysis_params is None:
        analysis_params = default_params
    else:
        # Update params with any defaults for missing keys
        original_params = copy.deepcopy(analysis_params)
        for key, value in default_params.items():
            analysis_params.setdefault(key, value)
    ## Parameters
    fRate = analysis_params['fRate_imaging']/analysis_params['fRate_beh']
    fRate_beh = analysis_params['fRate_beh']
    pre_ms    = analysis_params['pre_ms']
    pre_frames    = int(np.ceil(pre_ms*fRate))
    post_ms   = analysis_params['post_ms']
    post_frames   = int(np.ceil(post_ms*fRate))
    analysisWindowDur = analysis_params['analysisWindowDur']
    analysisWindowDur_frames = int(np.ceil(analysisWindowDur*fRate))
    stimTypes = analysis_params['stimTypes']

    color = sns.color_palette(colormap, len(stimTypes))
    sessionsData ={}

    for indx, params in enumerate(stimTypes) :
        array = dffTrace_mean[params]   
        if np.array_equal(array, np.array(None)):
            sessionsData[indx] = None
        else:
            nCell = array.shape[0]
            analysis_window = array.shape[1]    
            array = np.reshape(array, (nCell, analysis_window))
            if zscoreRun:
                sessionsData[indx]= zscore(array, axis = 1)
            else:
                sessionsData[indx]= array
    step = int(analysis_params['fRate_imaging']) # for x ticks, must int
    if int(post_ms) > 6000.1:
        print('Traces are only avaiable for 6 sec after onset defined time')
    else:
        fig, ax = plt.subplots(nrows=1, ncols=1, figsize=((len(stimTypes)+1)*2, 4))
        
        for idx, sessionData in enumerate(sessionsData):
            plot_data = sessionsData[idx]
            if type(plot_data) != type(None):
                
                x_labels = np.linspace(-1*int(pre_ms/fRate_beh),int(post_ms/fRate_beh), (pre_frames+post_frames)+1, dtype = int) 
                xticks = np.arange(0, len(x_labels), step)
                xticklabels = x_labels[::step]
                df = pd.DataFrame(plot_data).melt()
                # Smooth the data using lowess method from statsmodels
                x=df['variable']
                y=df['value']
                #lowess_smoothed = sm.nonparametric.lowess(y, x,frac=0.7)
                ax = sns.lineplot(x=x, y=y, data=df, color=color[idx], 
                                label=stimTypes[idx])
                #ax = sns.lineplot(x=lowess_smoothed[:, 0], y=lowess_smoothed[:, 1], 
                #                 data=df, color=color[idx], linewidth = 3 )

                ax.axvline(x=int(pre_ms*step/fRate_beh)+step, color='black', linewidth = 3) 
                ax.set_xticks (ticks = xticks, labels= xticklabels)
                ax.set_xticklabels(ax.get_xticklabels(), rotation=0)
                ax.set_xlim(step,int((pre_ms+post_ms)/fRate_beh)*step) 
                ax.set_xlabel('Time (sec)')
                if zscoreRun:
                    plt.ylabel('DFF(zscore)')
                else:
                    plt.ylabel('DFF')
                plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
                #plt.title(stimTypes[idx])
        save_figure(savefigname,savefigpath)

def heatmap_sessions(dffTrace_mean,analysis_params, colormap,
                       selectedSession, duration, savefigname, savefigpath ) :
    default_params = { 'fRate_imaging': 15,
                        'fRate_beh': 1000,
                        'pre_ms' : 2000.0, # in ms
                        'post_ms' : 6000.0, # in ms
                        'analysisWindowDur' : 2000.0, # in ms    
                        'stimTypes': dffTrace_mean.keys(), #.keys() requires dffTrace_mean to be a dictionary, not feasible always
                        }
    
    if analysis_params is None:
        analysis_params = default_params
    else:
        # Update params with any defaults for missing keys
        original_params = copy.deepcopy(analysis_params)
        for key, value in default_params.items():
            analysis_params.setdefault(key, value)
    ## Parameters
    fRate = analysis_params['fRate_imaging']/analysis_params['fRate_beh'] #15fps / 1000ms = f ms-1
    fRate_beh = analysis_params['fRate_beh']
    pre_ms    = analysis_params['pre_ms']
    pre_frames    = int(np.ceil(pre_ms*fRate)) #ST changed /fRate to *fRate because ms * f/ms = f
    post_ms   = analysis_params['post_ms']
    post_frames   = int(np.ceil(post_ms*fRate))
    analysisWindowDur = analysis_params['analysisWindowDur']
    analysisWindowDur_frames = int(np.ceil(analysisWindowDur*fRate))
    stimTypes= analysis_params['stimTypes']

    if stimTypes is None:
        print('WARNING: Please enter stimTypes into your params and pass into heatmap_sessions')
    sessionsData ={}

    for indx, params in enumerate(stimTypes) :
        array = dffTrace_mean[params]
        if np.array_equal(array, np.array(None)):
            sessionsData[indx] = None
        else:
            nCell = array.shape[0]
            analysis_window = array.shape[1]
            array = np.reshape(array, (nCell, analysis_window))
            sessionsData[indx]= stats.zscore(array, axis = 1)
        
    ymaxValue = 1
    yminValue = -1
    step = int(analysis_params['fRate_imaging']) # for x ticks, must int
    if int(post_ms) > 6000.1:
        print('Traces are only avaiable for 6 sec after onset defined time')
    else:
        grid_ratio = [1 for _ in range(len(stimTypes))]
        grid_ratio.append(0.05) # for the colorbar
        fig, axes = plt.subplots(nrows=1, ncols=len(stimTypes)+1, figsize=((len(stimTypes)+1)*2, 4), 
                                gridspec_kw={'width_ratios': grid_ratio})

        for idx, sessionData in enumerate(sessionsData):
            plot_data = sessionsData[idx]
            if type(plot_data) != type(None):
                if selectedSession == 'None':
                    # sortedInd = np.array(np.nanmean(plot_data[:, pre_frames:(pre_frames + analysisWindowDur_frames)], axis=1)).argsort()[::-1]
                    sortedInd = np.array(np.nanmean(plot_data[:, pre_frames:(pre_frames + post_frames)], axis=1)).argsort()[::-1]
                else:
                    # sortedInd = np.array(np.nanmean(sessionsData[selectedSession][:, pre_frames:(pre_frames + analysisWindowDur_frames)], axis=1)).argsort()[::-1]
                    sortedInd = np.array(np.nanmean(sessionsData[selectedSession][:, pre_frames:(pre_frames + post_frames)], axis=1)).argsort()[::-1]

                plot_data = plot_data[sortedInd]
                # x_labels = np.linspace(-1*int(pre_ms/fRate_beh),int(post_frames/fRate_beh), plot_data.shape[1]+1, dtype = int) #in seconds, with intervals spaced according to number of frames in plot_data
                x_labels = np.linspace(-1*int(pre_ms/fRate_beh),int(post_ms/fRate_beh), (pre_frames+post_frames)+1, dtype = int)
                # print(x_labels)
                xticks = np.arange(0, len(x_labels), step) #corresponding to every step, for placement of xticklabels in seconds
                # print(xticks)
                xticklabels = x_labels[::step] #basically taking every step-th x_label to correspond for every second between -pre_ms and post_ms
                
                ax = sns.heatmap(plot_data, vmin = yminValue, vmax = ymaxValue, cbar = False, yticklabels = False,cmap = colormap, ax = axes[idx])
                ax.axvline(x=int(pre_ms*step/fRate_beh)+step, color='w', linewidth = 3)
                ax.set_xticks (ticks = xticks, labels= xticklabels)
                ax.set_xticklabels(ax.get_xticklabels(), rotation=0)
                ax.set_xlim(step,int((pre_ms+post_ms)/fRate_beh)*step)
                ax.set_xlabel('Time (sec)')
                ax.set_title(stimTypes[idx])

        # Create a color bar for all heatmaps next to the last subplot
        # Hide the y-axis label for the dummy heatmap
        axes[-1].set_yticks([])
        # Create a dummy heatmap solely for the color bar
        cax = axes[-1].inset_axes([0.4, 0.2, 0.5, 0.6])
        sns.heatmap(np.zeros((1, 1)), ax=cax, cbar=True, cbar_ax=axes[-1], cmap=colormap, cbar_kws={'label': 'DFF','shrink': 0.5})
        axes[0].set_ylabel('Cells')
        save_figure(savefigname,savefigpath) 
        
def histogram_sessions(dffTrace_mean,stimTypes,colormap, zscoreRun, savefigname, savefigpath ) :
    
    ## Parameters
    fRate = 1000/15
    pre_frames    = 2000.0# in ms
    pre_frames    = int(np.ceil(pre_frames/fRate))
    post_frames   = 6000.0 # in ms
    post_frames   = int(np.ceil(post_frames/fRate))
    analysisWindowDur = 500 # in ms
    analysisWindowDur = int(np.ceil(analysisWindowDur/fRate))
    binrange = np.arange(-2.5, 2.6, 0.20)
    color =  sns.color_palette(colormap, len(stimTypes))
    sessionsData = []

    for indx, params in enumerate(stimTypes) :
        array = dffTrace_mean[params]
        if np.array_equal(array, np.array(None)):
            sessionsData.append(None)
        else:
            nCell = array.shape[0]
            analysis_window = array.shape[1]
            array = np.reshape(array, (nCell, analysis_window))
            if zscoreRun:
                array = zscore(array, axis = 1)
            sessionsData.append( np.nanmean(array[:, (pre_frames): (pre_frames + analysisWindowDur)],1) )
    xtickbinrange = np.arange(-2.5, 2.6, 0.5)

    # Set up the subplots with shared x-axis
    fig, axs = plt.subplots((len(sessionsData)+1), 1, figsize=(6, (6*(len(sessionsData)+1))))
    plt.subplots_adjust(hspace=0.2)
    # Calculate the maximum frequency for all histograms
    max_freq = max([np.histogram(data, bins=binrange)[0].max() for data in sessionsData if data is not None])
    mean_all = []
    var_all  =[]
    for indx, data in enumerate(sessionsData):
        if data is not None:
            # Create the histogram using sns.histplot()
            mean_all.append(np.mean(data))
            var_all.append(np.var(data))
            sns.histplot(data, kde=True, bins=binrange, color= color[indx], ax=axs[indx])
            axs[indx].set_ylim(0, np.round(max_freq*1.1))
            if indx >0:
                h, p =  stats.ks_2samp(data, datapre)
                axs[indx].text(0.95, 0.95, f'KS values: {h:.5f}\np: {p:.4f}', transform=axs[indx].transAxes,
                va='top', ha='right', color='black')
            elif indx ==0:
                datapre = data
            # Add a dashed line at the mean position
            axs[indx].axvline(x=np.nanmean(data), color='black', linestyle='--')
        

        # Add labels and title
        axs[indx].set_ylabel(stimTypes[indx] + '\n numCells')
        axs[indx].set_xlim(-2.5, 2.5)

        # Set x-axis label for the bottom subplot
        axs[indx].set_xticks(xtickbinrange)
        axs[indx].set_xticklabels(xtickbinrange)
        axs[indx].set_xlabel('Average dFF') 
       
        # add mean plot
        # Create a new grid for the last row of subplots
        last_row_axes = plt.subplot2grid((len(stimTypes)+1, 5), (len(stimTypes), 0), colspan=2)

        last_row_axes.plot(mean_all, '+', 
                           color='black', markersize = 10)
        last_row_axes.axhline(y=0, color='black', linestyle='--')

        last_row_axes.set_ylim(np.max(mean_all)*-1, np.max(mean_all))
        last_row_axes.set_xticks( np.arange(0, len(stimTypes), 1))
        last_row_axes.set_xticklabels(stimTypes, fontsize ='small')
        last_row_axes.set_ylabel('Mean') 

        # add mean plot
        # Create a new grid for the last row of subplots
        last_row_axes = plt.subplot2grid((len(stimTypes)+1, 5), (len(stimTypes), 3), colspan=2)

        
        last_row_axes.plot(var_all, '+', 
                           color='black', markersize = 10)
        last_row_axes.axhline(y=0, color='black', linestyle='--')
        last_row_axes.set_xticks( np.arange(0, len(stimTypes), 1))
        last_row_axes.set_xticklabels(stimTypes, fontsize ='small')
        last_row_axes.set_ylabel('Variance') 
        
        save_figureAll(savefigname,savefigpath)

def scatter_sessions(dffTrace_mean1, dffTrace_mean2, stimTypes,
                      label, colormap, zscoreRun, savefigname, savefigpath ) :
    
    ## Parameters
    fRate = 1000/15
    pre_frames    = 2000.0# in ms
    pre_frames    = int(np.ceil(pre_frames/fRate))
    post_frames   = 6000.0 # in ms
    post_frames   = int(np.ceil(post_frames/fRate))
    analysisWindowDur = 500 # in ms
    analysisWindowDur = int(np.ceil(analysisWindowDur/fRate))
    color =  sns.color_palette(colormap, len(stimTypes))
    sessionsData1 = []
    sessionsData2 = []

    for indx, params in enumerate(stimTypes) :
        array1 = dffTrace_mean1[params]
        array2 = dffTrace_mean2[params]
        if np.array_equal(array1, np.array(None)):
            sessionsData1.append( None)
            sessionsData2.append( None)
        elif np.array_equal(array2, np.array(None)):
            sessionsData1.append( None)
            sessionsData2.append( None)
        else:
            nCell = array1.shape[0]
            analysis_window = array1.shape[1]
            array1 = np.reshape(array1, (nCell, analysis_window))
            array2 = np.reshape(array2, (nCell, analysis_window))
            if zscoreRun:
                array1 = zscore(array1, axis = 1)
                array2 = zscore(array2, axis = 1)

            sessionsData1.append( np.nanmean(array1[:, (pre_frames): (pre_frames + analysisWindowDur)],1))
            sessionsData2.append( np.nanmean(array2[:, (pre_frames): (pre_frames + analysisWindowDur)],1))
    max_freq1 = max([np.max(np.abs(data)) for data in sessionsData1 if data is not None])
    max_freq2 = max([np.max(np.abs(data)) for data in sessionsData2 if data is not None])
    max_value = max(max_freq1,max_freq2)

    # Create the plot
    fig, axs = plt.subplots(len(sessionsData1), 1, figsize=(6, 6*len(sessionsData1)))
    for indx, data in enumerate(sessionsData1):
        if data is not None:
           if sessionsData2[indx] is not None:
            sns.scatterplot(x = data, y =sessionsData2[indx] , color= color[indx], ax = axs[indx])
    
        axs[indx].plot([max_value*-1, max_value], [max_value*-1, max_value], color='black', linestyle='--')
        axs[indx].set_xlim(max_value*-1, max_value)
        axs[indx].set_ylim(max_value*-1, max_value)
        axs[indx].set_ylabel(stimTypes[indx] + '\n' +label[1])
        axs[indx].set_xlabel(label[0])

    save_figureAll(savefigname,savefigpath)#

def add_scalebar_axs(ax, scale_um, axis_length=1024, um_per_pixel=False, filepath=None, line_kw={}):
    """ST 03/2025: Draw a scalebar in an Axes object
    :param: ax          -   axes object
    :param: scale_um    -   float or int, numerical, length of scale bar in microns
    :param: axis_length -   length of axis in pixels (x for horizontal scalebar)
    :param: um_per_pixel-   pixel resolution (optional with filepath)
    :param: filepath    -   filepath to tiff file/folder OR ops (optional with um_per_pixel)
    :param: line_kw     -   optional params for scale bar ('color')
    """
    
    default_kw = {'color':'white'}
    line_kw = {**default_kw, **line_kw}
    if um_per_pixel or (filepath is not None and len([f for f in glob.glob(filepath+'/*.xml')])>0):
        if not um_per_pixel:
            # Extract um per pixel from tiff folder/file path (leading to backup.xml)
            if isinstance(filepath, str): filepath=filepath
            elif isinstance(filepath, dict) and 'filelist' in filepath.keys(): 
                # ops given instead 
                filepath = filepath['filelist'][0]

            xml_dict = utils.xml_to_dict(filepath)
            um_per_pixel = float(xml_dict['micronsPerPixel']['value'][xml_dict['micronsPerPixel']['index'].index('XAxis')])
        else: um_per_pixel = um_per_pixel
        scalebar_unit = (scale_um/um_per_pixel)/axis_length # AnchoredHorizontalScaleBar size param should be expressed as a fraction
                                                                # of the x-axis length (>0 , <1)
        ob=AnchoredHorizontalScaleBar(size=scalebar_unit, label=(f'{scale_um}'+u' \u03bcm'),
                                loc=4, frameon=False, extent=0, 
                                    linekw=line_kw)
        ax.add_artist(ob)
    else: print("Either um_per_pixel or filepath with an .xml file must be given, scale-bar not drawn")
    return ax

def sk_reg_phasecorr(template, alignin1, alignin2=None, pearson_report=False):
    """ Lifted 03/2025 from https://www.fabriziomusacchio.com/blog/2023-01-02-image_registration/#benchmark-test-setup
    Performs simple translation (in x- y- axes) to align alignin1 with template
    template, alignin1  =   2D np.ndarrays, with same dimensions
    (optional) alignin2 =   2D np.ndarray, on which the same translation for alignin1 can be applied
    pearson_report      =   (boolean) whether or not to print correlation coefficient metrics
    """
    from skimage.registration import phase_cross_correlation
    from skimage.transform import SimilarityTransform, warp #, rotate
    import scipy as sp
    assert template.shape==alignin1.shape and len(template.shape)==2, \
    f'Arrays for template and alignin1 must be 2D and have identical shapes, but are ({template.shape}, {alignin1.shape})'
    
    # A default registration pipeline with phase_cross_corr():
    # registration:
    shift, _, _ = phase_cross_correlation(template, alignin1, upsample_factor=30, 
                                        normalization="phase")
    shifts=[shift[1], shift[0]]
    print(f'Detected translational shift: {shifts}')
    tform = SimilarityTransform(translation=(-shift[1], -shift[0]))
    registered1 = warp(alignin1, tform, preserve_range=True)

    if pearson_report:
        # metrics:
        pearson_corr_R     = sp.stats.pearsonr(template.flatten(), alignin1.flatten())[0]
        pearson_corr_R_reg = sp.stats.pearsonr(template.flatten(), registered1.flatten())[0]
        print(f"Pearson correlation coefficient image vs. moved: {pearson_corr_R}")
        print(f"Pearson correlation coefficient image vs. registration: {pearson_corr_R_reg}")

    if alignin2 is not None:
        registered2 = warp(alignin2, tform, preserve_range=True)
        return registered1, registered2
    else: return registered1

def ax_ROIs_and_FOV(axs, imgFOV, roi_masks,
                    aspect='equal', cmap_fov='binary_r',
                    scale_um=False, um_per_pixel=False, scale_kw={},
                    **opt_fov_params):
    
    axs.imshow(imgFOV, aspect=aspect, cmap=cmap_fov, **opt_fov_params)
    if roi_masks is not None: axs.imshow(roi_masks, interpolation_stage='rgba')
    if scale_um:
        if um_per_pixel:
            axs = add_scalebar_axs(axs, scale_um, axis_length=imgFOV.shape[0], um_per_pixel=um_per_pixel, line_kw=scale_kw)
        else: print(f"To draw a scale, um_per_pixel must be given")
            
    axs.axis('off')
    
    return axs

def s2p_cellsOnFOV(ops, axs=None, image_key = 'meanImg', cmap_fov='binary_r', 
                   drawROIs=True, cells_cmap=None, ROIs_key=None, blockName=None):
    """ ST 02/2025: Overlay a meanImg with the ROIs of cells as detected by suite2p
    :param: ops        - ops as outputted by run_s2p or loaded using np.load( , allow_pickle=True).item()
    :param: axs        - axes object for plotting (by default will generate 5x5 inch figure)
    :param: image_key  - (string) name of image array as saved in ops you wish to use (default='meanImg')
    """

    drawROIs_original = drawROIs

    if isinstance(image_key, list):
        if not isinstance(drawROIs, list):
            drawROIs = [drawROIs]
    if isinstance(ops, str):
        try: ops = np.load(ops, allow_pickle=True).item()
        except: print(f"Tried but failed to load ops from path {ops}, expect error")

    if axs is None:# or len(axs)<len(image_key): 
        fig, axs = plt.subplots(1, len(image_key), figsize=(5*len(image_key),5))
    else: fig = axs.get_figure()
    try: axs = axs.flatten()
    except: axs = [axs]
    cmap_green = plt.get_cmap(name=cmap_fov).set_under('k', alpha=0)

    for ind, ik in enumerate(image_key):
        meanImg = ops[ik]
        axs[ind].imshow(meanImg, aspect='equal', cmap=cmap_fov)#, clim=(0.3,1))

        #include cell ROIs
        if drawROIs_original and ik in drawROIs:
            stat = np.load(os.path.join(ops['save_folder'], 'plane0', 'stat.npy'), allow_pickle=True)
            if ROIs_key is None: ROIs_key = range(len(stat))
            else: 
                try: iter(ROIs_key)
                except: print(f"ROIs_key is not iterable, expect an error. Amend ROIs_key to be an indexable list.")
            if cells_cmap is None: 
                cells_cmap = np.random.choice(range(256), size=(len(stat), 3)) 
            else:
                if isinstance(cells_cmap, tuple) and len(cells_cmap)==3: # RGB tuple
                    cells_cmap = [cells_cmap for _ in range(len(stat))]
            cell_mask = np.ndarray(shape=(meanImg.shape[0], meanImg.shape[1], 4), dtype=int) #np.zeros_like(meanImg)
            for cell_number in ROIs_key:
                stat_cell = stat[cell_number]
                ypix = [stat_cell['ypix'][i] for i in range(len(stat_cell['ypix'])) if not stat_cell['overlap'][i]]
                xpix = [stat_cell['xpix'][i] for i in range(len(stat_cell['xpix'])) if not stat_cell['overlap'][i]]
                cell_mask[ypix,xpix] = np.array([i for i in cells_cmap[cell_number]]+[256*0.4])

            axs[ind].imshow(cell_mask, interpolation_stage='rgba')
        if ind==0:
            axs[ind] = add_scalebar_axs(axs[ind], 100, axis_length=meanImg.shape[0], filepath=ops['filelist'][0])

        axs[ind].axis('off')
    # Format picture nicely
    if blockName is not None: fig.suptitle(f'{blockName}\n({len(stat)} cells)')
    
    if len(axs)==1: return fig, axs[0]
    else: return fig, axs

def tiff_snapshot_interval(tiff_path, framerate=15.081, block_min=10, scale_um=100):
    """ ST 03/2024: Creates a 3-column series of snapshots from raw tiff movies 
    :param: tiff_path = path leading to a .tif file
    :param: framerate = frame rate of movie in frames-per-second (fps)
    :param: block_min = duration of each 'block' in minutes, per snapshot/mean image
    :param: scale_um  = length of scale bar in microns
    """
    import tifffile
    tiff_path = tiff_path.replace('\\', '/')

    assert os.path.isfile(tiff_path) and ('.tif' in tiff_path), f'{tiff_path} does not exist or is not a .tif file'
    xml_dict = utils.xml_to_dict(tiff_path)
    if framerate is None:
        framerate = 1/float(xml_dict['framePeriod']) 
    else: framerate = framerate #fps 
    block_length_s = int(block_min*60)

    with tifffile.TiffFile(tiff_path) as tif:
        # print(tifffile.TiffFile.asarray(tif, key=range(9000)))
        nframes = len(tif.pages)
        block_frames = int(np.ceil(block_length_s*framerate)) # length of each block
        n_blocks = int(np.ceil(nframes/block_frames)) # round up to nearest int
        print(f"Iterating through {nframes}-frames, for {n_blocks} blocks of {block_frames} frames each")

        mean_images = []
        for block_num in range(n_blocks):
            # print(f'Reading block {block_num+1}/{n_blocks}...')
            end = nframes if (block_num+1)*block_frames>nframes else (block_num+1)*block_frames
            tif_block = tifffile.TiffFile.asarray(tif, key=range(block_num*block_frames,end)) #time x 1024 x 1024
            mean_image = np.nanmean(tif_block, axis=0) 
            mean_images.append(mean_image)
            mean_image=None  #'scrubs' mean_image data from memory to conserve RAM?
    set_figure()
    ncol = 3
    nrows = int(np.ceil(len(mean_images)/ncol))
    fig, axs = plt.subplots(nrows, ncol, figsize=(5*ncol, 5*nrows))
    axs = axs.flatten()
    for ind, img in enumerate(mean_images):
        # Draw the mean_image of each 'block' in an axs
        axs[ind].imshow(img, aspect='equal', cmap='gray', extent=(0,img.shape[0], 0,img.shape[1]))
        axs_title = f'{int((ind+1)*block_length_s/60)} min' #if duration_s > block_length_s/2 else f'{int(duration_s/60)} min'
        axs[ind].set_title(axs_title)
        axs[ind].axis('off') # sets axis to be invisible
        
        # Add scale bar to first axs
        if ind==0 and (scale_um or scale_um is not None): 
            um_per_pixel = float(xml_dict['micronsPerPixel']['value'][xml_dict['micronsPerPixel']['index'].index('XAxis')])
            scalebar_unit = (scale_um/um_per_pixel)/img.shape[0] # AnchoredHorizontalScaleBar size param should be expressed as a fraction
                                                                 # of the x-axis length (>0 , <1)
            ob=AnchoredHorizontalScaleBar(size=scalebar_unit, label=(f'{scale_um}'+u' \u03bcm'),
                                    loc=4, frameon=False, extent=0, 
                                      linekw={'color':'white'})
            axs[ind].add_artist(ob)
    # Remove empty subplot
    if len(axs)>len(mean_images):
        for ax in axs[len(mean_images):]: ax.set_visible(False)

    mean_images = None #'scrubs' mean_images data from memory to conserve RAM?
    return fig

def save_multi_channel_image(img_list, save_path=None, save_name='multichannelimage', format='tiff'):
    """ ST 03/2025: Stacks np.arrays in img_list in RGB lut, and saves to save_path in desired format
    """
    from imageio import imwrite
    img_stack = np.dstack(img_list) #saves automatically in red/green/blue
    imwrite(os.path.join(save_path, f"{save_name}.{format}"), img_stack.astype(np.uint16))
    print(f"Saved {save_name} in {save_path}")

def lineplot_withSEM (data, colorInd, label, params = None, axis=None):
    #lineplot_matrix(data=pupil_arr[session.outcome=='hit'], x_axis=x_axis, color=COLORS[0], label='hit')
    if params is None:
        params = {
        'fRate': 20000,
        'fRate_beh': 1000,
        'fRate_imaging': 15,
        'preStimSec': 3,
        'postStimSec':6,
        'visualStimSec': 2, 
        'plotColor': sns.color_palette('mako', 3),
        }  

    x_axis = np.linspace(-1*params['preStimSec'], params['postStimSec'], data.shape[0])
    color = params['plotColor'] # sns.color_palette('cividis', 3) 

    df = pd.DataFrame(data).melt()
    df['Time (seconds)'] = np.tile(x_axis, data.shape[1])

    #Normalise the data to the first 2 seconds
    basePreStim = np.nanmean(data[:(params['preStimSec']*params['fRate_imaging']),:], axis=0, keepdims=True)
    data = data - basePreStim

    if axis == None:
        axis = sns.lineplot(x='Time (seconds)', y='value', data=df, color=color[colorInd],
                    label=label)
    else: 
        sns.lineplot(x='Time (seconds)', y='value', data=df, color=color[colorInd],
                    label=label, ax = axis )
    ylim_min = np.floor(np.nanmin(np.nanmean(data,1)))*1.5
    ylim_max = np.ceil (np.nanmax(np.nanmax(data,1)))*1.5

    ylength = np.absolute(ylim_max - ylim_min)
    xlength = 0.25
    # add a  vertical line at zero label as stimulus onset
    axis.axvline(x=0, color='black', linestyle='--')
    # add a grey rectangular transparent box to indicate the stimulus duration
    axis.axvspan(0, params['visualStimSec'], color='grey', alpha=0.1)
   # axis.set_ylim(ylim_min, ylim_max)
    axis.set_xlim(-1*params['preStimSec'], params['postStimSec'])
    axis.set_xlabel('Time (seconds)')
    axis.set_ylabel('DFF')


def plot_lickRrastersAcrossStimType (session_lick, beh_df, params, plotType = 'All', 
                                     axs = None,savefigpath = None, savefigname= None):
    totalLength = params['totalLength']
    fRate = params['fRate']
    preRewardTime = params['preRewardTime']
    bin_width =params['bin_width']
    visualStimDur =params['visualStimDur']
    stimTypes = params['stimTypes']
    color = params['plotColor']

    if stimTypes == None:
        stimTypes = np.unique(beh_df[params['plotChannelType']])
        stimTypes = list(set(stimTypes))
        print(stimTypes)
    if axs is None:
        fig, axs = plt.subplots(len(stimTypes)+2,1, figsize=(6, (len(stimTypes)+2)*2.5))
    
    if plotType == 'All':
        plotID = 0
        for i, array in enumerate(session_lick):
            axs[plotID].plot(array, np.ones_like(array)+i, 'k.',markersize = 1)

        ymax = len(session_lick)
        tickRange = max(round(ymax / 4 / 10) * 10, 10)
        axs[plotID].set_xlim(0, totalLength*fRate)
        axs[plotID].set_ylim(0, ymax)
        axs[plotID].set_yticks(range(0,ymax, tickRange), range(0,ymax,tickRange))
        axs[plotID].set_xticks (range(0,(totalLength*fRate)+1,fRate), range((preRewardTime*-1),(totalLength-preRewardTime+1),1))
        axs[plotID].tick_params(axis='x', which='major', length=5, width=1, direction='out', color='black', labelsize='large', labelcolor='black', bottom=True)  # Adjust 'length' and 'width' as needed
        axs[plotID].set_xticklabels([])
        axs[plotID].set_ylabel('Trials')
        axs[plotID].set_title('Raster licking plot for all trials in order of occurance')

        ax2 = axs[plotID].twinx()

        # Lick density plot
        num_bins = range(0, int(np.ceil(totalLength*fRate)), int(fRate/bin_width))
        animal_hist = np.zeros(len(num_bins)-1)
        for i, array in enumerate(session_lick):
            hist, bins = np.histogram(array, bins=num_bins, range=(0, totalLength*fRate))
            animal_hist = animal_hist + hist
        animal_hist = animal_hist / (i+1) / bin_width
        ax2.plot(bins[1:], animal_hist, 'k', linewidth=2, alpha=0.5)

        # Set y-label for the secondary y-axis
        ax2.set_ylabel('Lick density (Hz)', color='k')  
        ax2.tick_params(axis='y', labelcolor='k')  # Set tick color to match the plot
        ax2.set_ylim(0,params['ymaxLikDensity'])
        ax2.axvline(x=((preRewardTime+visualStimDur)*fRate)+300, color='grey', linestyle='-', alpha=1, linewidth=10)
        ax2.axvline(x=(preRewardTime*fRate), color='k', linestyle='--', alpha=1, linewidth=1)

    ##### Plot trials in different stimTypes
    
    if plotType == 'All':
        plotID = 1 if plotType == 'All' else 0

        for stimType in stimTypes:
            selectedTrials = np.where(beh_df[params['plotChannelType']] == stimType)[0]
            session_lickSelected = [session_lick[i] for i in selectedTrials]
            for i, array in enumerate(session_lickSelected):
                axs[plotID].plot(array, np.ones_like(array)+i, 'k.',markersize = 1)
            
            ymax = len(session_lickSelected)
            tickRange = max(round(ymax / 4 / 10) * 10, 10)
            axs[plotID].set_xlim(0, totalLength*fRate)
            axs[plotID].set_ylim(0, ymax)
            axs[plotID].set_yticks(range(0,ymax, tickRange), range(0,ymax, tickRange))
            axs[plotID].set_xticks (range(0,(totalLength*fRate)+1,fRate), range(((preRewardTime)*-1),(totalLength-preRewardTime+1),1))
            axs[plotID].tick_params(axis='x', which='major', length=5, width=1, direction='out', color='black', labelsize='large', labelcolor='black', bottom=True)  # Adjust 'length' and 'width' as needed
            axs[plotID].set_xticklabels([])
            axs[plotID].set_ylabel('Trials')

            ax2 = axs[plotID].twinx()

            # Lick density plot
            num_bins = range(0, totalLength*fRate, int(fRate/bin_width))
            animal_hist = np.zeros(len(num_bins)-1)
            for i, array in enumerate(session_lickSelected):
                hist, bins = np.histogram(array, bins=num_bins, range=(0, totalLength*fRate))
                animal_hist = animal_hist + hist

            animal_hist = animal_hist / (i+1) / bin_width
            ax2.plot(bins[1:], animal_hist,  color = color[plotID], linewidth=2, alpha=0.5)

            # Set y-label for the secondary y-axis
            ax2.set_ylabel('Lick density (Hz)', color=color[plotID])  
            ax2.tick_params(axis='y', labelcolor=color[plotID])
            ax2.set_ylim(0,params['ymaxLikDensity'])
            ax2.axvline(x=((preRewardTime+visualStimDur)*fRate)+300, color='grey', linestyle='-', alpha=1, linewidth=10)
            ax2.axvline(x=(preRewardTime*fRate), color='k', linestyle='--', alpha=1, linewidth=1)
            ax2.set_title(f'{stimType}')
            plotID = plotID + 1

    if plotType == 'All' or plotType =='Truncated':
        plotID = len(stimTypes)+1 if plotType == 'All' else 0
        colorInd,legendHandle = 0,[]

        for ind, stimType in enumerate(stimTypes):
            selectedTrials = np.where(beh_df[params['plotChannelType']] == stimType)[0]
            if len(selectedTrials)>0:
                animal_lickSelected = [session_lick[i] for i in selectedTrials]
                num_bins = range(0, totalLength*fRate, int(fRate/bin_width))
                animal_hist = [] # np.zeros(len(num_bins)-1)
                for i, array in enumerate(animal_lickSelected):
                    hist, bins = np.histogram(array, bins=num_bins, range=(0, totalLength*fRate))
                    animal_hist.append( hist) # Lets take mean here, not sum! animal_hist = animal_hist + hist
            
                animal_hist = np.nanmean(np.array(animal_hist), axis=0) #/ len(animal_lickSelected) / bin_width
                sem_hist = np.nanstd(np.array(animal_hist), axis=0) / np.sqrt(len(animal_lickSelected))
                upper_bound = animal_hist + sem_hist
                lower_bound = animal_hist - sem_hist
                if len(color)<ind+1:
                    KeyError('Color is not enough for the number of plots - Increase the number of colors in the params')
                axs[plotID].plot(bins[1:], animal_hist, linewidth=2, alpha=0.5, color = color[colorInd], label=stimType)
                axs[plotID].fill_between(bins[1:], lower_bound, upper_bound, color=color[colorInd], alpha=0.2)
                colorInd = colorInd + 1
                #axs[plotID].errorbar(bins[1:], animal_hist, yerr=std_dev_hist, fmt='-o', linewidth=2, alpha=0.5, color=color[ind+1], capsize=5)
        
        axs[plotID].axvline(x=((preRewardTime+visualStimDur)*fRate), color='grey', linestyle='-', alpha=1, linewidth=10)
        axs[plotID].axvline(x=(preRewardTime*fRate), color='k', linestyle='--', alpha=1, linewidth=1)
        axs[plotID].set_xlim(0, totalLength*fRate)
        axs[plotID].set_xticks (range(0,(totalLength*fRate)+1,fRate), range(((preRewardTime)*-1),(totalLength-preRewardTime+1),1))
        axs[plotID].tick_params(axis='x', which='major', length=5, width=1, direction='out', color='black', labelsize='large', labelcolor='black', bottom=True)  # Adjust 'length' and 'width' as needed
        axs[plotID].set_ylabel('Lick Density (Hz)')
        axs[plotID].set_ylim(0, params['ymaxLikDensity'])
        axs[plotID].set_xlabel('Time (sec)') 
        axs[plotID].legend(loc='upper left', bbox_to_anchor=(1, 1))
        
    if savefigpath is not None: 
        plt.savefig(os.path.join(savefigpath, savefigname + '_LickRasterStimTypes.png'))

def generate_lickDensity(recordingList, params, plotType = 'Truncated', 
                         axis = None, saveFigNname = None, saveFigPath=  None):

    default_params = {
        'bin_width': 2,
        'fRate': 20000,
        'fRate_beh': 1000,
        'stChanName_lick': 'lick',
        'stChanName_reward': 'reward_echo',
        'funType': 'AcrossStimType', # or 'AcrossSessions',#
        'plotChannelType': 'stimulusType',
        'alignmentType': 'StimulusAligned', # 'RewardAligned' or 'LickAligned'
        'stimTypes':None, #['Rectangle'], #None will take the first one,  It will plot only the first one for across Session
        'ymaxLikDensity': 12,
        'preRewardTime': 3,
        'visualStimDur': 2,
        'sessionProfile': 'Pavlov1',
        'color': sns.color_palette('tab10', 4), #NEEDS WORK! 4 should be more than len(stimTypes)+1
    }
    original_params = copy.deepcopy(params)
    if params is None:
        params = default_params
    else:
        # Update params with any defaults for missing keys
        for key, value in default_params.items():
            params.setdefault(key, value)
    
    # Calculate 'totalLength' based on 'preRewardTime' and 'visualStimDur', add 5
    params['totalLength'] = params['preRewardTime'] + params['visualStimDur'] + 5
    fRate = params['fRate']

    # CreateFolder for saving the figures
    figSavePath = os.path.join( saveFigPath, 'sessionBeh')
    if not os.path.exists(figSavePath):
        os.makedirs(figSavePath)

    # Get the data
    sessionLicks, sessionBehData, sessionNames = [], [],[]
    for ind in range(len(recordingList)):
        if (recordingList.behExtracted[ind] == 1) & (recordingList.paqExtracted[ind] == 1):
            paq_filename = recordingList.paqFileName[ind]
            print (' Plotting behaviour session: ' + recordingList.blockName[ind])
            paqData = pd.read_pickle (paq_filename)
            beh_df = pd.read_csv(recordingList.behFileName[ind])
            beh_df['sessionName'] = recordingList.recordingDate[ind] # create a column in beh_df for the session name
            # Get the stim start times 
            if params['alignmentType'] == 'StimulusAligned':
                trialStartTimes = (beh_df['stimulusOnsetTime'] - params['preRewardTime']) * fRate 
            elif params['alignmentType'] == 'RewardAligned':
                trialStartTimes = (beh_df['rewardTime'] - params['preRewardTime']) * fRate
            elif params['alignmentType'] == 'LickAligned':
                beh_df['firstLickTime'] = utils.get_first_lick(beh_df, params['stChanName_lick'], params['fRate_beh'])
                trialStartTimes = (beh_df['firstLickTime'] - params['preRewardTime']) * fRate

            _, session_lick = utils.lick_binner(paqData, trialStartTimes,params['stChanName_lick'], stimulation = False)
            sessionBehData.append(beh_df)
            sessionLicks.append(session_lick)
            sessionNames.append(recordingList.blockName[ind])
        else:
            print('Beh and/or PAQ file is not created correctly: ' + recordingList.blockName[ind])
    # Plot the lick density for all trials
    if plotType == 'All':
        for ind, sessionName in enumerate(sessionNames):
            print('Raster plots for all stim Types is saved in the folder: ' + sessionName)
            session_lick = sessionLicks[ind]
            beh_df = sessionBehData[ind]
            if ind>0:
                axis = None
            plot_lickRrastersAcrossStimType(session_lick, beh_df, params, plotType = plotType, axs = axis,
                savefigpath = figSavePath, savefigname = sessionName)

    elif plotType =='Truncated':
        # truncated all trials in the recordinglist
        for ind, sessionName in enumerate(sessionNames):
            if ind==1:
                session_lick = sessionLicks[ind]
                beh_df = sessionBehData[ind]
            else:
                beh_df = pd.concat([beh_df, sessionBehData[ind]], ignore_index=True) 
                session_lick = session_lick + sessionLicks[ind]
                    
        if params['funType'] == 'AcrossSessions':
            stimType = params['stimTypes'][0]
            if stimType is None:
                stimType = np.unique(beh_df[params['plotChannelType']])[0]
            selectedTrials = np.where(beh_df[params['plotChannelType']] == stimType)[0]
            beh_df = beh_df.iloc[selectedTrials]
            params['plotChannelType'] = 'sessionName'
            params['stimTypes'] = None

        plot_lickRrastersAcrossStimType(session_lick, beh_df, params, plotType = plotType, axs = axis,
                savefigpath = figSavePath, savefigname = recordingList.animalID[0])
    params.clear()
    params.update(original_params)

def generate_imagingTraces(recordingList, params, plotType = 'Truncated', 
                         axis = None, saveFigNname = None, saveFigPath=  None):

    default_params = {
        'bin_width': 2,
        'fRate': 20000,
        'fRate_beh': 1000,
        'fRate_imaging': 15,
        'stChanName_lick': 'lick',
        'stChanName_reward': 'reward_echo',
        'funType': 'AcrossStimType', 
        'plotChannelType': 'stimulusType',
        'alignmentType': 'StimulusAligned', # 'RewardAligned' or 'LickAligned'
        'stimTypes':['Rectangle'], #None will take the first one,  It will plot only the first one for across Session
        'ymaxLikDensity': 12,
        'preRewardTime': 3,
        'visualStimDur': 2,
        'postRewardTime':6,
        'sessionProfile': 'Pavlov1',
        'color': sns.color_palette('tab10', 4), #NEEDS WORK! 4 should be more than len(stimTypes)+1
    }
    original_params = copy.deepcopy(params)
    if params is None:
        params = default_params
    else:
        # Update params with any defaults for missing keys
        for key, value in default_params.items():
            params.setdefault(key, value)
    
    # Calculate 'totalLength' based on 'preRewardTime' and 'visualStimDur', add 5
    params['totalLength'] = params['preRewardTime'] + params['visualStimDur'] + 5
    fRate = params['fRate']
    fRate_imaging = params['fRate_imaging']

    # CreateFolder for saving the figures
    figSavePath = os.path.join(saveFigPath, 'sessionBeh')
    if not os.path.exists(figSavePath):
        os.makedirs(figSavePath)

    # Get the data
    sessionFlus, sessionBehData, sessionNames = [], [],[]
    for ind in range(len(recordingList)):
        if (recordingList.behExtracted[ind] == 1) & (recordingList.paqExtracted[ind] == 1):
            paq_filename = recordingList.paqFileName[ind]
            print ('Plotting behaviour session: ' + recordingList.blockName[ind])
            # paqData = pd.read_pickle (paq_filename)
            beh_df = pd.read_csv(recordingList.behFileName[ind])
            print('Read beh_df from '+recordingList.behFileName[ind])
            beh_df['sessionName'] = recordingList.recordingDate[ind] # create a column in beh_df for the session name
            image_df = pd.read_pickle (recordingList['imagingFileName'][ind])
            # Get the stim start times 
            if params['alignmentType'] == 'StimulusAligned':
                trialStartTimes = (beh_df['stimulusOnsetTime'] - params['preRewardTime']) * fRate 
            elif params['alignmentType'] == 'RewardAligned':
                trialStartTimes = (beh_df['rewardTime'] - params['preRewardTime']) * fRate
            elif params['alignmentType'] == 'LickAligned':
                beh_df['firstLickTime'] = utils.get_first_lick(beh_df, params['stChanName_lick'], params['fRate_beh'])
                trialStartTimes = (beh_df['firstLickTime'] - params['preRewardTime']) * fRate
            # Calculate the mean traces for each trials x cells
            preFrames = int(params['preRewardTime']*fRate)
            postFrames = int(params['postRewardTime']*fRate)
            imaging_frames = image_df['frame-clock']
            session_flu = utils.flu_splitter(image_df, trialStartTimes, preFrames,postFrames )
            sessionBehData.append(beh_df)
            sessionFlus.append(session_flu)
            sessionNames.append(recordingList.blockName[ind])
        else:
            print('Beh and/or PAQ file is not created correctly: ' + recordingList.blockName[ind])
    # Plot the lick density for all trials
    if plotType == 'All': # Create the heatmap for all stimTypes for all cells in the recording
        for ind, sessionName in enumerate(sessionNames):
            print('Raster plots for all stim Types is saved in the folder: ' + sessionName)
            session_flu = sessionFlus[ind]
            beh_df = sessionBehData[ind]
            if ind>0:
                axis = None
            heatmap_sessions(session_flu, params['stimTypes'], params['colormap'],
                            params['selectedSession'], params['duration'], ax = axis,
                            savefigname = sessionName, savefigpath = figSavePath)
            histogram_sessions(session_flu, params['stimTypes'], params['colormap'],
                            params['zscoreRun'], savefigname = sessionName, savefigpath = figSavePath)

    elif plotType =='Truncated':
        # truncated all trials in the recordinglist
        for ind, sessionName in enumerate(sessionNames):
            if ind==1:
                session_flu = sessionFlus[ind]
                beh_df = sessionBehData[ind]
            else:
                beh_df = pd.concat([beh_df, sessionBehData[ind]], ignore_index=True) 
                session_flu = pd.concat([session_flu, sessionFlus[ind]], ignore_index=True) 

                    
        if params['funType'] == 'AcrossSessions':
            stimType = params['stimTypes'][0]
            if stimType is None:
                stimType = np.unique(beh_df[params['plotChannelType']])[0]
            selectedTrials = np.where(beh_df[params['plotChannelType']] == stimType)[0]
            beh_df = beh_df.iloc[selectedTrials]
            params['plotChannelType'] = 'sessionName'
            params['stimTypes'] = None

            heatmap_sessions(session_flu, params['stimTypes'], params['colormap'],
                            params['selectedSession'], params['duration'], ax = axis,
                            savefigname = sessionName, savefigpath = figSavePath)
            histogram_sessions(session_flu, params['stimTypes'], params['colormap'],
                            params['zscoreRun'], savefigname = sessionName, savefigpath = figSavePath)

    params.clear()
    params.update(original_params)

def plotSessionLickRaster_vlines_stimOnOff(axname, x, color='k', linestyle='--', alpha=0.5, linewidth=1):
    axname.axvline(x=x, color=color, linestyle=linestyle, alpha=alpha, linewidth=linewidth)

def plotSessionLickRaster_vlines(axname, params):
    fRate = params['fRate']
    preRewardTime = params['preRewardTime'] * fRate
    visualStimDur = params['visualStimDur'] * fRate
    jitterKeys = ['stimulusDelay', 'feedbackDelay']
    linestyles= ['-', ':']
    colors     = ['k', '#0573f9'] ###4d87cf
    # dashed black line for stimulus onset
    plotSessionLickRaster_vlines_stimOnOff(axname, x=(preRewardTime), linestyle=linestyles[0], color='k', linewidth=3, alpha=1)
    
    for jK, ls,c in zip(jitterKeys, linestyles, colors):
        if jK=='stimulusDelay':# and jK in list(params.keys()):
            jitter = params[jK]
            if isinstance(jitter, np.ndarray):
                if not (jitter[0]==0 and jitter[1]==0):
                    # plot jitter as a translucent box spanning the jitter time
                    axname.axvspan((preRewardTime + visualStimDur + (jitter[0]* fRate)), 
                                (preRewardTime + visualStimDur +( jitter[1]* fRate)), alpha=0.1, color=c)
                    # if jK=='stimulusDelay':
                    #     # also plot a 'mean' line for reward onset
                    #     plotSessionLickRaster_vlines_stimOnOff(axname, x=preRewardTime+visualStimDur+(jitter[0]+jitter[1])/2* fRate,
                    #                                            linestyle=linestyles[1], color=colors[1])
                else:# line for fixed offset
                    plotSessionLickRaster_vlines_stimOnOff(axname, x=(preRewardTime+visualStimDur), linestyle=':', color='k', alpha=1)
            else:
                plotSessionLickRaster_vlines_stimOnOff(axname, x=(preRewardTime+visualStimDur), linestyle=':', color='k', alpha=1)
        elif jK=='feedbackDelay':
            jitter = params[jK]
            if isinstance(jitter, np.ndarray):
                if not (jitter[0]==0 and jitter[1]==0):
                    # plot jitter as a translucent box spanning the jitter time
                    axname.axvspan((preRewardTime + visualStimDur + (jitter[0]* fRate)), 
                                (preRewardTime + visualStimDur +( jitter[1]* fRate)), alpha=0.1, color=c)
            
        # else:# line for fixed offset
        #     plotSessionLickRaster_vlines_stimOnOff(axname, x=(preRewardTime+visualStimDur), linestyle=ls, color=c)

def plotSessionLickRaster_histLine(ax_stimType, ax_combined, color_chosen, params, licks, ls='-', alpha=0.5):
    """Sandra Tan 2024: sub-function for plotting histogram lines in plotSessionLickRaster
    Update 26/07/24: removed the division of animal_hist by bin_width (which calculates probability but changes the unit from Hz)
                        and multiply each hist with bin_width to get to Hz, as each bin represents 1/bin_width seconds. 
                        Adjust your ymaxLikDensity to accommodate this"""
    fRate = params['fRate']
    bin_width = params['bin_width']
    totalLength = params['totalLength']

    num_bins = range(0, totalLength * fRate, int(fRate / bin_width))
    animal_hist = np.zeros(len(num_bins) - 1)
    
    for i, array in enumerate(licks): #rewarded = dark purple
        hist, bins = np.histogram(array, bins=num_bins, range=(0, totalLength * fRate))
        animal_hist = animal_hist + (hist   * bin_width) #animal_hist = animal_hist + hist
    animal_hist = animal_hist / (i + 1) #/ bin_width
    # print(animal_hist)
    if ax_stimType is not None:
        ax_stimType.plot(bins[1:], animal_hist, color=color_chosen, linestyle=ls, linewidth=2, alpha=alpha)
    if ax_combined is not None:
        ax_combined.plot(bins[1:], animal_hist, linewidth=2, alpha=alpha, color=color_chosen, linestyle=ls) #all types line plot
    return ax_stimType, ax_combined

def plotSessionLickRaster_rasterdots(ax, licks, color='k', marker='.', markersize=1, alpha=.8):
    for i, licks_in_trial in enumerate(licks):
        ax.plot(licks_in_trial, np.ones_like(licks_in_trial) + i, color=color, marker=marker, linestyle='none',
                markersize=markersize, alpha=alpha)
    # print(len(licks_plot))
    ymax = len(licks) + 1
    ax.set_ylim(0, ymax)
    ax.set_yticks(range(0, ymax, 25))
    ax.set_ylabel('Trials')
    return ax

def plotSessionLickRaster_subplots(animalSessions, ind, params, subplotTypes=[], axs=[], **kwargs):

    subplotTypes_list = ['line', 'raster', 'all']
    default_params = {
                    'plotChanelType': 'rewardProb',
                    'plotChanel_splitStr': '% ',
                    'infoColumnForLicks': 'lickFileName',
                    'stChanName_lick': 'lick',
                    'fRate': 2000, 
                    'threshold_lick': 4.9, #voltage threshold; on daq/Timeline 4.6 is a good threshold
                    'lickInterval_s': 160/2000, #realistic interval between licks; specify to better filter threshold_detect which might count multiple thresholds in a single square wave
                    'trialBlock': False, #Must be list!! for drawing a y intersection; number of trials per stimulus in first block
                    'stimsWithBlock': False, #Must be list!! list of stimuli in first block
                    'indTrunc': None,
                    'trialsSkip': None, #if both are None, only plot 1 column of axes
                    'preRewardTime': 2,
                    'visualStimDur': 2,
                    'stimulusDelay': np.nan,
                    'feedbackDelay': np.nan,
                    'bin_width': 5,
                    'ymaxLikDensity': 10,
                    'plotColor': ['k', '#2e66aa', '#0060d3', '#99b8dd', '#900C3F'],
                    'stimType_forColor': ['0%', '50%', '-', '-', '100%'],
                    'xlabel': 'Time from stimulus (s)',
                    'colorbystimtype': True,
                    }
    
    params = {**default_params, **params, **kwargs}

    fRate = params['fRate']
    plotChanelType = params['plotChanelType']
    stChanName_lick = params['stChanName_lick']
    preRewardTime = params['preRewardTime']
    visualStimDur =params['visualStimDur']
    bin_width = params['bin_width']
    ymaxLikDensity = params['ymaxLikDensity']
    color = params['plotColor']
    totalLength = int(np.ceil(preRewardTime + visualStimDur + 5)) #add to params dictionary
    params['totalLength']  = totalLength
    if params['lickInterval_s']:
        lickInterval = params['lickInterval_s'] * fRate

    blockName = animalSessions['blockName'][ind]
    date = animalSessions['recordingDate'][ind]
    beh_filename = animalSessions['behFileName'][ind]
    figname = f'{date}_{blockName}.png'

    # Get the lick times for this behaviour session 
    beh_df = pd.read_csv(beh_filename)
    paq_filename = animalSessions[params['infoColumnForLicks']][ind] #though called paq_filename, this should really just be a file path leading to a .pkl dictionary where lick signals are stored under a key named as assigned by stChanName_lick
    paqData = pd.read_pickle(paq_filename)
    
    # Cross-check fRate from paqData
    if 'sample_rate' in list(paqData.keys()):
        sample_rate = paqData['sample_rate']
        if int(sample_rate) != int(fRate):
            print(f'WARNING: CHECK FRAME RATES - {int(sample_rate)} in lick file, but {int(fRate)} in params. Changing fRate to {int(sample_rate)}')
    
    _, animal_lick = utils.preprocessLicks(paqData, beh_df, 'stimulusOnsetTime', stChanName='lick', lickInterval=lickInterval,
                                           preStimTime=preRewardTime, fRate=fRate, rig=animalSessions['rig'][ind])

    ############# Set up the figure: set up smaller subplots within the axs object given
    num_rows = len(subplotTypes)

    # print(inner)
    for i, subplotType in enumerate(subplotTypes):
        ax = axs[i]
        ## Plot subplot depending on subplotType
        stimType = subplotType.split('_')[0]
        color_stimType = params['plotColor'][np.where([stimType.startswith(i) for i in params['stimType_forColor']])[0][0]] if stimType!='all' else 'k'
        stimType_indices = [int(i) for i, trial in enumerate(beh_df[plotChanelType]) if trial==stimType] if stimType!='all' else np.arange(len(beh_df[plotChanelType]))
        licks_plot = [animal_lick[i] for i in stimType_indices] if stimType!='all' else animal_lick
        
        if 'raster' in subplotType:
            color=color_stimType  if params['colorbystimtype'] else 'k'
            ax = plotSessionLickRaster_rasterdots(ax, licks_plot, alpha=.8, color=color)
            
        if 'line' in subplotType:
            if stimType =='all':
                # Plot a histline for licks for every trial type    
                tempStimTypes_all = list(set(beh_df[plotChanelType]))
                for tempStimType in tempStimTypes_all:
                    tempColor = params['plotColor'][np.where([tempStimType.startswith(i) for i in params['stimType_forColor']])[0][0]] 
                    temp_indices = [i for i, trial in enumerate(beh_df[plotChanelType]) if trial==tempStimType]
                    temp_licks = [animal_lick[i] for i in temp_indices]
                    ax, _ = plotSessionLickRaster_histLine(ax, None, tempColor, params, temp_licks, ls='-', alpha=0.5)
            else: ax, _ = plotSessionLickRaster_histLine(ax, None, color_stimType, params, licks_plot, ls='-', alpha=0.5)
            ax.set_ylabel('Mean lick rate (Hz)')
            ax.set_ylim(0, ymaxLikDensity)
            

        ## Affix axes
        ax.set_xlim(0, totalLength * fRate)
        ax.set_xticks(range(0, int(np.ceil((totalLength * fRate) + 1)), fRate),
                        range((preRewardTime * -1), (totalLength - preRewardTime + 1), 1))
        if params['xlabel'] is not None: ax.set_xlabel(params['xlabel'])
        plotSessionLickRaster_vlines(ax, params)
    return ax #chose to return the ax not axs given

def plotSessionLickRaster(animalSessions, ind, params, savePath = None, showPlot = False):
    default_params = {
                    'plotChanelType': 'rewardProb',
                    'plotChanel_splitStr': '%',
                    'infoColumnForLicks': 'paqFileName',
                    'stChanName_lick': 'lick',
                    'fRate': 20000, 
                    'threshold_lick': 1, #voltage threshold; on daq/Timeline 4.6 is a good threshold
                    'lickInterval_s': False, #realistic interval between licks; specify to better filter threshold_detect which might count multiple thresholds in a single square wave
                    'trialBlock': False, #Must be list!! for drawing a y intersection; number of trials per stimulus in first block
                    'stimsWithBlock': False, #Must be list!! list of stimuli in first block
                    'indTrunc': None,
                    'trialsSkip': None, #if both are None, only plot 1 column of axes
                    'preRewardTime': 3,
                    'visualStimDur': 2,
                    'stimulusDelay': np.nan,
                    'feedbackDelay': np.nan,
                    'bin_width': 2,
                    'ymaxLikDensity': 7,
                    'plotColor': ['k', '#2e66aa', '#0060d3', '#99b8dd', '#900C3F'],
                    'stimType_forColor': ['0%', '50%', '-', '-', '100%'],
                    }
    
    original_params = copy.deepcopy(params)
    if params is None:
        params = default_params
    else:
        # Update params with any defaults for missing keys
        for key, value in default_params.items():
            params.setdefault(key, value)

    fRate = params['fRate']
    # print(fRate)

    plotChanelType = params['plotChanelType']
    stChanName_lick = params['stChanName_lick']
    preRewardTime = params['preRewardTime']
    visualStimDur =params['visualStimDur']
    bin_width = params['bin_width']
    ymaxLikDensity = params['ymaxLikDensity']
    color = params['plotColor']
    totalLength = int(np.ceil(preRewardTime + visualStimDur + 5)) #add to params dictionary
    params['totalLength']  = totalLength
    if params['lickInterval_s']:
        lickInterval = params['lickInterval_s'] * fRate

    blockName = animalSessions['blockName'][ind]
    date = animalSessions['recordingDate'][ind]
    beh_filename = animalSessions['behFileName'][ind]
    figname = f'{date}_{blockName}.png'

    # Get the lick times for this behaviour session 
    print('Reading '+beh_filename)
    beh_df = pd.read_csv(beh_filename)
    trialStartTimes = (beh_df['stimulusOnsetTime']-preRewardTime) * fRate 
    paq_filename = animalSessions[params['infoColumnForLicks']][ind] #though called paq_filename, this should really just be a file path leading to a .pkl dictionary where lick signals are stored under a key named as assigned by stChanName_lick
    print('Reading '+ paq_filename)
    paqData = pd.read_pickle(paq_filename)
    
    # Cross-check fRate from paqData
    if 'sample_rate' in list(paqData.keys()):
        sample_rate = paqData['sample_rate']
        if int(sample_rate) != int(fRate):
            print(f'WARNING: CHECK FRAME RATES - {int(sample_rate)} in lick file, but {int(fRate)} in params.')
    
    _, animal_lick = utils.preprocessLicks(paqData, beh_df, 'stimulusOnsetTime', stChanName='lick', lickInterval=lickInterval,
                                           preStimTime=preRewardTime, fRate=fRate, rig=animalSessions['rig'][ind])
    # _, animal_lick = utils.lick_binner(paqData, trialStartTimes, stChanName_lick, 
    #                                    threshold=params['threshold_lick'], distance=lickInterval)
    if 'rig' in animalSessions.columns:
        rig = animalSessions.loc[ind, 'rig']
    else:
        rig = 'rig_unknown'
    
    # Calibrate for indTrunc and trialsSkip if defined
    indTrunc = params['indTrunc']
    trialsSkip = params['trialsSkip']

    # Find reversal points if applicable
    if params['reversal']==1: #reversal session
        output_stims, changeTrialbyStim = mfun.findFirstChange_trialInd(beh_df, 'rewardProbRev', 'rewardProb', argout='firstChangeTrial_perStimType')
        firstChangeTrial = mfun.findFirstChange_trialInd(beh_df, 'rewardProbRev', 'rewardProb', argout='session')
        wasThereBlock = True
    elif params['reversal']==0: #mid intro session
        output_stims, changeTrialbyStim = mfun.findFirstNewStim_trialInd(beh_df, '50% Rewarded', 'rewardProb', argout='perStimType')
        firstChangeTrial = mfun.findFirstNewStim_trialInd(beh_df, '50% Rewarded', 'rewardProb', argout='session')
        wasThereBlock = True
    else:
        wasThereBlock = False

    # Get different stim Types for the session
    stimTypes = beh_df[plotChanelType]
    stimTypes = list(set(stimTypes))
    # stimTypes.sort()  # to sort the list alphabetically, so no matter what order the '% Rewarded' categories appeared in, all graphs across animals will be in the same order
    stimTypes = utils.customSort(stimTypes, '0591', alphabet=True)

    ############ Plot the figure
    print(f'Plotting for {blockName}')
    # Plot 1 or 2 columns
    if params['indTrunc'] is not None or params['trialsSkip'] is not None: #==> plot 2 columns
        ncol=2
    else:
        ncol = 1
    
    pfun.set_figure()
    nrows_argin = len(stimTypes)+2
    height_ratios_argin = list(np.ones(nrows_argin, dtype=int))
    height_ratios_argin[0] = 2*height_ratios_argin[0]
    width_ratios_argin = list(np.ones(ncol, dtype=int))

    fig, axs = plt.subplots(nrows_argin, ncol, figsize=(6*ncol, nrows_argin*2), sharex=True, sharey=False, 
                            gridspec_kw={'width_ratios': width_ratios_argin, #'wspace':0.3, 'hspace': 0.3, 
                            'height_ratios':height_ratios_argin,})
    axs = axs.flatten() #to enable plotting in both cases where ncol=2 or ncol=1
    fig.suptitle(f'{blockName} ({rig})')
    # plt.subplots_adjust(hspace=0.3, wspace=1) #commented to suppress UserWarning when using layout engines with constrained_layout
    for ax in axs: #axs must be axs.flatten() in order to enumerate
        plotSessionLickRaster_vlines(ax, params) #plot vertical lines for all subplots
        # ax2.set_ylim(None, ymaxLickDensity)
    ############ Subplot 1: Plot the all trials
    colIdx = 0
    if params['indTrunc'] is not None and isinstance(indTrunc, int):
        axs[0].axhline(y=indTrunc, color='red', linestyle='--', alpha=0.5)

    ymax = len(animal_lick)
    if params['indTrunc'] is None:
        indTrunc=len(beh_df)+1 #no trials will be found to be <indTrunc
    else:
        print('Trial index for truncation set to', indTrunc)
    for i, array in enumerate(animal_lick):
        for idx, stimType in enumerate(stimTypes):
            if beh_df[plotChanelType][i] == stimTypes[idx]:
                try: 
                    color_ind = np.where([stimType.startswith(i) for i in params['stimType_forColor']])[0][0]
                    color_plot = color[color_ind]
                except:
                    color_plot = 'grey'
                # Original all trials
                axs[0].plot(array, np.ones_like(array) + i, color=color_plot, marker='.', linestyle='none',
                            markersize=1)
                #Truncated (indTrunc) and cleaned of aberrant trials (trialsSkip)
                if ncol==2:
                    if (i not in trialsSkip and i<indTrunc):
                        axs[1].plot(array, np.ones_like(array) + i, color=color_plot, marker='.', linestyle='none',
                                    markersize=1)
                    
                    cleaned_trialsN = len([i for i in range(len(animal_lick)) if (i not in trialsSkip and i<indTrunc)])
                    axs[0].set_title(f'Original, {ymax} trials')
                    axs[1].set_title(f'{cleaned_trialsN} trials after processing')
                else:
                    axs[0].set_title('Raster licking plot for all trials in order of occurrence')

    # ymax = len(animal_lick)
    for i in range(ncol):
        axs[i].set_xlim(0, totalLength * fRate)
        axs[i].set_ylim(0, ymax)
        axs[i].set_yticks(range(0, ymax+1, 25))
        axs[i].set_xticks(range(0, int(np.ceil((totalLength * fRate) + 1)), fRate),
                        range((preRewardTime * -1), (totalLength - preRewardTime + 1), 1))
    axs[0].set_ylabel('Trials')
    # axs[0].set_xlabel('Time (sec)')
    # If a reversal/new stim introduction occurred, draw the horizontal line to indicate the trial on which this occurred
    if wasThereBlock:
        for colIdx in range(ncol):
            axs[colIdx].axhline(y=firstChangeTrial+0.5, alpha=0.5, color='green', linewidth=1, linestyle=':')

    ############ Subplots 2-N: Plot trials in different stimTypes
    # plotID = 1
    ymaxes = []
    for idx, stimType in enumerate(stimTypes):
        rowNum = idx+1
        try: 
            color_ind = np.where([stimType.startswith(i) for i in params['stimType_forColor']])[0][0]
            color_plot = color[color_ind]
        except: color_plot = 'grey'
        prob, _ = stimType.split(params['plotChanel_splitStr'])  # will return number in string format (e.g. '0', '100') and 'Rewarded'
        prob = int(prob)  # convert string number to integer

        selectedTrials = np.where(beh_df[plotChanelType] == stimType)[0]
        for colIdx in range(ncol):
            if colIdx==0:
                animal_lickSelected = [animal_lick[i] for i in selectedTrials]
                reward_volSelected = [beh_df['rewardVolume'][i] for i in selectedTrials]
                plotID = rowNum * ncol
                last_plotID = (nrows_argin-1) * ncol
            elif colIdx==1: #colIdx can only be 1 if trialsSkip or indTrunc are not None
                animal_lickSelected = [animal_lick[i] for i in selectedTrials if (i not in trialsSkip and i<indTrunc)]
                reward_volSelected = [beh_df['rewardVolume'][i] for i in selectedTrials if (i not in trialsSkip and i<indTrunc)]
                plotID = rowNum * ncol + 1
                last_plotID = (nrows_argin-1) * ncol + 1
            reward_volSelected = np.array(reward_volSelected)

            # Plot lick raster dots
            for i, array in enumerate(animal_lickSelected):
                if reward_volSelected[i] == 0:  #plot as grey dots for unrewarded
                    axs[plotID].plot(array, np.ones_like(array) + i, marker = '.', markersize=1, color = 'grey', linestyle = 'none')
                elif reward_volSelected[i] > 0: #plot as baby pink dots for rewarded #or blue?
                    axs[plotID].plot(array, np.ones_like(array) + i, marker = '.', markersize=1, color = '#f4c2c2', linestyle = 'none') 
                
            ymax = len(animal_lickSelected) #number of trials
            if colIdx==0:
                print(ymax, 'trials in', stimType)
            axs[plotID].set_xlim(0, totalLength * fRate)
            axs[plotID].set_ylim(0, ymax)
            axs[plotID].set_yticks(range(0, ymax+1, 25))
            axs[plotID].set_xticks(range(0, (totalLength * fRate) + 1, fRate),
                                range(((preRewardTime) * -1), (totalLength - preRewardTime + 1), 1))
            axs[plotID].set_ylabel('Trials')

            #Trial block demarcation
            if wasThereBlock:
                trial_num = changeTrialbyStim[output_stims.index(stimType)]
                # trial_num = params['trialBlock'][(params['stimsWithBlock']).index(stimType)]
                axs[plotID].axhline(y=trial_num+0.5, alpha=0.5, color='green', linewidth=1, linestyle=':')

            # Add secondary y axis
            ax2 = axs[plotID].twinx()
            ax2.spines["right"].set_visible(True)  

            # Lick density line-plot
            # if prob == 0 or prob == 100:
            plotSessionLickRaster_histLine(ax2, axs[last_plotID], color[color_ind], params, animal_lickSelected)
            # else:
            #     plotSessionLickRaster_histLine(ax2, axs[last_plotID], color[color_ind], params, animal_lickSelected, ls=':')
            
            # if prob == 50:  # in trials with partial probability of reward delivery
            #     rewarded_trials = np.where(reward_volSelected > 0)
            #     rewarded_trials = (np.array(rewarded_trials)).reshape((-1,))
            #     rewarded_lickSelected = [animal_lickSelected[t] for t in rewarded_trials]
            #     unrewarded_trials = np.where(reward_volSelected == 0)
            #     unrewarded_trials = (np.array(unrewarded_trials)).reshape((-1,))
            #     unrewarded_lickSelected = [animal_lickSelected[t] for t in unrewarded_trials]

            #     plotSessionLickRaster_histLine(ax2, axs[last_plotID], color[color_ind-1], params, rewarded_lickSelected)
            #     plotSessionLickRaster_histLine(ax2, axs[last_plotID], color[color_ind+1], params, unrewarded_lickSelected)
                
            # Set y-label for the secondary y-axis
            ax2.set_ylabel('Lick density (Hz)', color=color[color_ind])
            ax2.tick_params(axis='y', labelcolor=color[color_ind])
            ax2.set_ylim(0, ymaxLikDensity)
            # plotSessionLickRaster_vlines(axs[0], params) #plot vertical lines

            axs[plotID].set_title(f'{stimType} trials')
        # _, ymaxi = ax2.get_ylim()
        # ymaxes.append(ymaxi) #store ymax of second axis to define common ymax


        ############ Subplots N+1: Fix axes for subplot
        axs[last_plotID].set_xlim(0, totalLength * fRate)
        axs[last_plotID].set_xticks(range(0, int(np.ceil((totalLength * fRate) + 1)), fRate),
                                        range(((preRewardTime) * -1), (totalLength - preRewardTime + 1), 1))
        axs[last_plotID].set_ylabel('Lick Density (Hz)')
        axs[last_plotID].set_ylim(0, ymaxLikDensity)
        axs[last_plotID].set_xlabel('Time (sec)')

    # ymaxLickDensity = max(ymaxes) #not currently working

    if savePath is not None:
        if ncol==1:
            figname = f'{blockName}_sessionLickRaster.png'
        elif ncol==2:
            figname = f'lickPlot_processed_{blockName}'
        save_figure(figname, savePath)
        # figPath = os.path.join(savePath, figname).replace('\\', '/')
        # fig.savefig(figPath)
        # print(f'Figure saved in {figPath}')
    # if showPlot == False:
    #     matplotlib.use('AGG')
    if showPlot==True:
        plt.show()
    plt.close()
    # return fig



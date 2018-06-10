# Fly_Tracking
Author: Yunus Kinkhabwala, 2018

# Overview
Please find here code to both record and track the positions of fruit flies as used in the publication "The Density-Functional Fluctuation Theory of Crowds". Several novel approaches to tracking the individual positions of large dense crowds of walking fruit flies are developed here, largely to deal with finding individuals and tracking their identities when they touch and form connected clusters. For the analysis to work, the subfunctions folder must be added to the Matlab path.
Note that for the most current versions of fly-tracking algorithms, please check the GitHub repository https://github.com/yunuskink/Fly-Tracking. The code here is sufficient to place positions for flies in large groups within the fly itself thus allowing accurate counts of local density as used in the paper.
Error from this analysis are likely systematic. Flies that are in a large cluster or more likely to be missed. To verify that this does not drastically affect the results of the DFFT analysis, an orthogonal apporoach was developed which used the number of silhouetted pixels in a bin to approximate the discrete number of flies in the bin and the DFFT analysis of videos using these two approaches produced Vexations, v_b, and frustrations, f_N, that were in agreement with each other.

This code according to my analysis outperformed other fly-tracking algorithms for accurately separating flies in a cluster, which is its intended goal, but is far too noisy to track the identity of flies. To do so, I have developed another approach which uses frame-by-frame image correlation to keep track of the identity of flies even as they mate and form clusters over many minutes. This more accurate but much slower and beta code will be soon published to the GitHub link https://github.com/yunuskink/Fly-Tracking.

# System Requirements

## Hardware Requirements

This software requires only a standard computer. This software was tested on a computer with the following specifications:

RAM: 8+ GB  
CPU: 2+ cores, 2.7 GHz/core

For the 'Realtime analysis' process, we used a GenTL compliant camera.

## Software Requirements

All code is written in Matlab and tested on MatLab version R2017b. Code used for recording from cameras requires the add-on of the Image Acquisition toolbox. 

## OS Requirements
The package has been tested on the following systems:

Linux: 
Mac OSX:  

Windows: Windows 10 Pro

# Instructions and Demo:
First, be sure to add the 'subfunctions' folder to your Matlab path.

###EXTRACTING PARAMS:
In order to track the flies from a video, a number of parameters must be set for thresholding the fly silhouettes.
Follow the steps below to extract your own set of parameters for the sample video.
1) Run the script 'get_video_params'. You can do so simply by opening the script and clicking the green arrow for the "run" button.
2) User is prompted to choose the video file. For the example provided, open the 'test_mv.avi' file.
3) User is now promted whether a params structure has already been created before. If so, click yes to open the params matlab .m file. For this set of instructions, click 'No'.
4) User is prompted for whether a new mask is needed. Click 'Yes'.
5) Draw a boundary polygon around the part of the chamber the flies are allowed to be in. Be certain NOT to exclude any parts of the chamber. Double click the polygon once finished.
6) User is prompted whether the mask is good enough. Click 'No, you try it'. Code will now take a minute to collect images from the movie to create a background.
7) User is now prompted with a vertical slider to control the boundary of the mask. Move the slider until the boundary is completely selected without any black spots inside of the arena. Then click 'Done'.
8) User now has the option to modify several different parameters to control the threshholding of the video. Adjust these parameters and click 'Update Images' to see a red binary image overlaid on the flies which indicates which pixels of the images satisfy these parameters.
####PARAMETERS:
######Threshold slider:
Slide the slider to adjust the threshold needed to label a fly. Ideally, only fly bodies without legs or wings should be selected, but try to make sure fly heads are not separated from their bodies.
######Filter size:
To accomodate uneven background lighting, an adaptive threshold is used where local average intensity is used to define the threshhold. Values around 5 times the length of a fly in pixels is usually enough.
######Background:
For the adaptive threshold, an average background value must be assigned to the image around the perimeter of the chamber. The recommended value is sufficient, but if flies on the edge are labelled differently than in the center, then this value can be adjusted.
######:Min Area
The smallest area allowed for a fly. Clusters smaller than this value will be discared. In units of pixels. Generally, this value is not so important but useful for removing contaminants.
######:Max Area
The largest area allowed for a fly. Clusters larger than this value will attempt to be separated. In units of pixels. This value is more important than the previous one. Use the 'fly sizes' button to see a histogram of the sizes of the flies which are found according to the current parameters. Adjust this parameter until there are no clusters of flies labelled.
######:Max Displacement
Not used for this analysis.
####GUI BUTTONS:
######DONE:
Click when all parameters are set and the flies are counted.
######COUNT FLIES:
Brings up a sample image of the experiment. User can click on the flies to count them. Once a click has been recorded for each fly, user should right click to end the counting and the total number of flies will be shown in the GUI
######UPDATE IMAGES:
Click to update the labelling of the four sample images according to the current parameters.
######FLY SIZES:
Click to create a figure showing the histogram of the sizes of the flies. 

9) User will now be prompted to find new fitflies. Click 'yes'. The fitflies, an average of what a fly looks like, will be generated, this may take 1-2 minutes.
10) User will now be prompted where to save the 'params' structure which contains the parameters defined above and which can now be used to track flies in the code 'fitfly_video_tracking'.

###TRACKING FLIES:
In order to track the flies from a video...

1) run the script 'fitfly_video_tracking'.
2) The first prompt requests a video file. Select 'test_mv.avi'. In general this can be in any format that Matlab VideoReader accepts.
3) The second prompt requests a params file. Select 'params.mat'.
4) Analysis will now commence and, every 10 frames, the current image will be shown overlaid with the labelled positions as determined from the code. This takes about one frame per second, but with video with fewer clusters or at lower resolution, this can perform much faster. Flies labelled in blue are found with traditional thresholding and morphological operations. Flies labelled in red and green are obtained through the fitfly method.
5) Once analysis is finished, user will be prompted for a place to save the results.

##OUT PUT RESULTS:
The 'ResMat' variable output from the analysis contains the position determined for every fly. Each row corresponds to a new observations. The data is organized as follows.
####ResMat Dimensions:
Column 1: Time
Column 2: x-position
Column 3: y-position
Column 4+: Reserved for further information and analysis such as identity labels.

#Realtime Analysis:
To increase the workflow of the experiment, the 'Track_flies_realtime' function is designed to collect an image and perform the above analysis on the image before proceeding to collect a subsequent image. When tracked this way, only one image every 20 seconds is saved to monitor the quality of the tracking algorithm and only the positions are returned. Due to varying image analysis times, the subsequent results must be downsampled, e.g. choosing the observations nearest regular time intervals, to avoid systematic bias.

##Getting params in realtime:
Set up your experimental apparatus and a sample population of flies, then run 'get_params_realtime'. Wait for the camera to collect several test images, then proceed larely as described above to determine the best parameters for the experiment.

##Tracking flies in realtime:
Once you have your params function, run 'Track_flies_realtime'. You will be given a chance to align your experimental chamber with the mask you determined in the params. Then press 'Done' and every 20 seconds and updated file containt the 'ResMat' structure as described above will be save for the entire experiment until you stop MatLab with the Crtl-C command for example.



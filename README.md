# Fly_Tracking
Author: Yunus Kinkhabwala, 2018

# Overview
Please find here code to both record and track the positions of fruit flies. Several novel approaches to tracking the individual positions of large dense crowds of walking fruit flies are developed here, largely to deal with finding individuals and tracking their identities when they touch and form connected clusters. Each folder contains different functions and scripts, but for those to work, the subfunctions folder must be added to the Matlab path.

# System Requirements



## Hardware Requirements


This software requires only a standard computer. This software was tested on a computer with the following specifications:


RAM: 8+ GB  

CPU: 2+ cores, 2.7 GHz/core




## Software Requirements

#

All code is written in Matlab and tested on MatLab version R2017b. Code used for recording from cameras requires the add-on of the Image Acquisition toolbox. 

## OS Requirements



The package has been tested on the following systems:


Linux: 
Mac OSX:  

Windows: Windows 10 Pro

# Analyze video fitfly
	Code within this folder uses a method I call "fitfly" to separate the individuals within a group using an input of a video of flies. A maximum fly size is established, and then the individuals are found by convolving a fitfly, which is just an average of what all the individual flies look like, across the groups. 

# Realtime analysis
	In order to quickly collect data from fly experiments, I implemented the "fitfly" tracking algorithm to work in realtime. The cost of using this analysis is that the images are not saved and the acquisition of each image must wait for the analysis of the previous image to complete. This then may bias oversampling of images that are easier to analyze, typically ones with fewer clusters, so that later downsampling is required. 

#Recording Parameters
	Run this code first in order to tune correctly the parameters to extract the fly silhouettes.

#sample_video_analysis
	In this folder is a sample video and the analysis results on that clip.

#subfunctions
	Add this folder in order to run rest of code.

##Instructions for Use and Demo

First, add all the folders to your path in Matlab by right-clicking on the folder and clicking "Add to Path" and choosing the option to include all the subfolders.

#Extracting thresholding and size parameters




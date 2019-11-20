# bci

## Installation
To download or clone the git repository follow use this [link](https://github.com/gangulylab/bci.git).

There are a few dependencies that you must have installed to run bci:

* [Matlab](https://www.mathworks.com/)
* [Psychtoolbox](http://psychtoolbox.org/)

## BCI coding environment
General Principles:

1. Blackrock neural acquisition system and API (cbmex) reads in neural data.
2. Psychtoolbox controls the drawing / timing through cbmex files
3. Matlab code is used to control the task flow, signal processing, data saving, etc...

## Matlab Modules
1. task_modules - control task flow in different environments
	* CenterOut
	* CenterOut1D
	* GridTask
	* RadialTask
	* RadialTyping
	* RadialTypingMultiClick
2. task_helpers - general tools to help with task flow across task modules
3. neuro - controls neural processing
4. arduino - controls arduino for time-sync and exo system
5. kalman_filter - continuous decoder, used to control cursor pos/vel 
6. clicker - discrete decoder, used to discretely control task flow
7. typing_env - controls typing parameters: keyboard layout, character/word selection, etc...
8. exo_control - controls exo system

Each module will be explained in more detail below.

### task_modules
Each task module contains at least four files:

* GetParams.m
* RunTask.m
* RunLoop.m
* RunTrial.m

*GetParams.m* is used to set the parameters for a given task / experimental session. It is meant to be updated before each experimental run depending on what the experimenter wants to test. Parameters fall into rough sections. These sections are heavily commented. I will expand on a few important ones here:

* Control - this section contains a few highly relevant parameters that change often. Some parameters pertain to cursor control (e.g., degree of assistance, type of cursor control adaptation, whether the cursor is "reset" after each trial) while others pertain to collection of neural features (e.g., spatial filtering, baseline time, feature mask)

* Data saving and persistence directories are defined for each task. The persistence directory is particularly important. This directory contains running estimates of the statistics of the signal on each channel, statistics of each neural feature, and the kalman filter parameters (both full and reduced dimensionality, and 2D and 1D).

* Details of neural filter bank. This section defines how the neural features are computed. It contains flags (whether to save raw, processed, reduced, etc... data) and defines the edges of filters, which filtered signals will get averaged together, which are computed through a hilbert vs. traditional power estimate, etc...

*RunTask.m*, *RunLoop.m*, and *RunTrial.m* control the task flow for each task.

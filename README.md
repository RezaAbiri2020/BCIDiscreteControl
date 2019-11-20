# bci

## Installation
To download or clone the full repository follow use this [link](https://github.com/gangulylab/bci.git).

There are a few dependencies that you must have installed to run bci:

* [Matlab](https://www.mathworks.com/)
* [Matlab Arduino Support](https://www.mathworks.com/hardware-support/arduino-matlab.html)
* [Psychtoolbox](http://psychtoolbox.org/)

## BCI coding environment
General Principles:

1. Blackrock neural acquisition system and API (cbmex) reads in neural data.
2. Psychtoolbox controls the drawing / timing through cbmex files
3. Matlab code is used to control the task flow, signal processing, data saving, etc...

To run an experiment, type 

'''
ExperimentStart(*task_name*, *subject*, *control_mode*, *blackrock*,  *debug*),
'''

where

* *task_name* is a string containing the name of a valid task,
* *subject* is a string containing the id of a subject (use 'test' or 'Test' to avoid saving a ton of useless data), 
* *control_mode* is an integer {1 - mouse position control, 2 - mouse joystick control, 3 - full kalman filter, 4 - velocity kalman filter}, 
* *blackrock* is a flag, if true it attempts to use the Blackrock API to acquire neural data.
* *debug* is a flag, when true it invokes a debugging environment in which the screen is a bit smaller, etc...

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

*GetParams.m* is used to set the parameters for a given task / experimental session. It is meant to be updated before each experimental run depending on what the experimenter wants to test. It returns a struct, *Params* that is meant to be passed to a large range of functions so that those functions are modular, but can remain static (no task coding) once a task is set up. Parameters fall into rough sections. These sections are heavily commented. I will expand on a few important ones here:

* Control - this section contains a few highly relevant parameters that change often. Some parameters pertain to cursor control (e.g., degree of assistance, type of cursor control adaptation, whether the cursor is "reset" after each trial) while others pertain to collection of neural features (e.g., spatial filtering, baseline time, feature mask)

* Data saving and persistence directories are defined for each task. The persistence directory is particularly important. This directory contains running estimates of the statistics of the signal on each channel, statistics of each neural feature, and the kalman filter parameters (both full and reduced dimensionality, and 2D and 1D).

* Details of neural filter bank. This section defines how the neural features are computed. It contains flags (whether to save raw, processed, reduced, etc... data) and defines the edges of filters, which filtered signals will get averaged together, which are computed through a hilbert vs. traditional power estimate, etc...

*RunTask.m*, *RunLoop.m*, and *RunTrial.m* control the task flow for each task. Importantly, *RunTrial.m* contains a main for loop that occasionally (at Params.UpdateRate Hz) calls the NeuroPipeline (see neuro module).

### task_helpers
This module contains helper functions to control task flow (e.g., *ExperimentPause.m*) and to control data structures (e.g., *UpdateCursor.m*) across many tasks.

### neuro
This module acts on the *Neuro* struct. It contains a neural processing pipeline that can be modified by changing parameters in the *GetParams.m* file. The main function here is *NeuroPipeline.m*, which collects neural data (through the Blackrock API), performs signal preprocessing, computes neural features, etc...

### arduino
This module contains a few helper functions for interacting through Matlab with an Arduino device. This is useful for time synchronization (sending arduino pulses), and for control of the planar exo system.

### kalman_filter
This module contains code for loading, fitting, and updating parameters of a Kalman Filter. It contains separate functions for 1D and 2D Kalman Filters. It acts on the *KF* struct.

### clicker
This module contains classification models and functions that apply classification to neural data and return discrete states. These functions act on the *Clicker* struct. Currently, *click_classifier.m* returns

### typing_env
This module contains functions to control the flow of a typing environment that is overlaid on the traditional tasks. For example, character selections, word selections, keyboard displays, undo functionality, etc... These functions primarily act on the *Keyboard* struct in the *Params* struct.

### exo_control
This module contains functions that support interfacing with and controling a custom planar exoskeleton device. These functions primarily act on the *Arduino* struct in the *Params* struct.
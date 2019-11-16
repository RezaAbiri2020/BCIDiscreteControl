# bci

## Installation
- link to github install
- instructions for cloning or pulling repo
- link to matlab
- link to psychtoolbox3

## BCI coding environment
General Principles:

1. Blackrock neural acquisition system and API (cbmex) reads in neural data.
2. Psychtoolbox controls the drawing / timing through cbmex files
3. Matlab code is used to control the task flow, signal processing, data saving, etc...

## Matlab Modules
1. Tasks - control task flow in different environments
	a. Center-Out
	b. GridTask
2. taskhelpers - general tools to help with taskflow across task modules
3. neuro - controls neural processing
4. arduino - controls arduino for time-sync or exo system
5. kalman_filter - continuous decoder, used to control cursor pos/vel 
6. clicker - discrete decoder, used to discretely control task flow

Each module will be explained in more detail below.

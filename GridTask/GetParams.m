function Params = GetParams(Params)
% Experimental Parameters
% These parameters are meant to be changed as necessary (day-to-day,
% subject-to-subject, experiment-to-experiment)
% The parameters are all saved in 'Params.mat' for each experiment

%% Verbosity
Params.Verbose = true;

%% Experiment
Params.Task = 'GridTask';
switch Params.ControlMode,
    case 1, Params.ControlModeStr = 'MousePosition';
    case 2, Params.ControlModeStr = 'MouseVelocity';
    case 3, Params.ControlModeStr = 'KalmanPosVel';
    case 4, Params.ControlModeStr = 'KalmanVelocity';
end

%% Control
Params.CenterReset      = true;
Params.Assistance       = 0; %0.05; % value btw 0 and 1, 1 full assist
Params.DaggerAssist 	= true;

Params.CLDA.Type        = 3; % 0-none, 1-refit, 2-smooth batch, 3-RML
Params.CLDA.AdaptType   = 'linear'; % {'none','linear'}, affects assistance & lambda for rml

Params.InitializationMode   = 4; % 1-imagined mvmts, 2-shuffled imagined mvmts, 3-choose dir, 4-most recent KF
Params.BaselineTime         = 0; % secs
Params.BadChannels          = [];
Params.SpatialFiltering     = false;
Params.UseFeatureMask       = true;

%% Cursor Velocity
Params.Gain                     = 2;
Params.OptimalVeloctityMode     = 1; % 1-vector to target, 2-LQR
Params.VelocityTransformFlag    = false;
Params.MaxVelocityFlag          = false;
Params.MaxVelocity              = 200;

%% Cursor Click
Params.ClickerBins = 1; % set to -1 to use target hold time instead of click
Params.DecisionBoundary= -0.5;

%% Current Date and Time
% get today's date
now = datetime;
Params.YYYYMMDD = sprintf('%i',yyyymmdd(now));
Params.HHMMSS = sprintf('%02i%02i%02i',now.Hour,now.Minute,round(now.Second));

%% Data Saving

% if Subject is 'Test' or 'test' then can write over previous test
if strcmpi(Params.Subject,'Test'),
    Params.YYYYMMDD = 'YYYYMMDD';
    Params.HHMMSS = 'HHMMSS';
end

% create folders for saving
Params.Datadir = fullfile('~/Data',Params.Task,...
    Params.Subject,Params.YYYYMMDD,Params.HHMMSS);
mkdir(Params.Datadir);

%% Sync to Blackrock
Params.ArduinoSync = false;

%% Timing
Params.ScreenRefreshRate = 10; % Hz
Params.UpdateRate = 10; % Hz

%% Targets
Params.ShowNextTarget   = true; % displays next target as a frame
Params.FrameSize        = 5;
Params.TargetSize       = 40;
Params.TargetSpacing    = Params.TargetSize*2+10;

Params.GridColor        = [100,100,100];
Params.OutTargetColor   = [55,255,0];

Params.GridLayout = [4,4 ]; % [rows x cols]
top_left = -(Params.GridLayout-1)/2;
sp = Params.TargetSpacing;
sz = Params.TargetSize;

ct = 0;
for i=1:Params.GridLayout(1),
    for ii=1:Params.GridLayout(2),
        ct = ct + 1;
        x = sp*(top_left(2) + (ii-1));
        y = sp*(top_left(1) + (i-1));
        Params.ReachTargetPositions(ct,:) = [x,y];
        Params.ReachTargetWindows(ct,:) = [x-sz y-sz x+sz y+sz];
    end
end
Params.NumReachTargets = ct;

%% Cursor
Params.CursorColor = [0,102,255];
Params.InTargetColor    = [255,55,0];
Params.CursorSize = 10;
Params.CursorRect = [-Params.CursorSize -Params.CursorSize ...
    +Params.CursorSize +Params.CursorSize];

%% Kalman Filter Properties
Params.SaveKalmanFlag = false; % if true, saves kf at each time bin, if false, saves kf 1x per trial
G = Params.Gain;
t = 1/Params.UpdateRate;
a = 0.85;%.825;
w = 150;
if Params.ControlMode>=3,
    Params.KF.A = [...
        1	0	G*t	0	0;
        0	1	0	G*t	0;
        0	0	a	0	0;
        0	0	0	a	0;
        0	0	0	0	1];
    Params.KF.W = [...
        0	0	0	0	0;
        0	0	0	0	0;
        0	0	w	0	0;
        0	0	0	w	0;
        0	0	0	0	0];
    Params.KF.P = eye(5);
    Params.KF.InitializationMode = Params.InitializationMode; % 1-imagined mvmts, 2-shuffled
    if Params.ControlMode==4, % set velocity kalman filter flag
        Params.KF.VelKF = true;
    else,
        Params.KF.VelKF = false;
    end
end

%% LQR Optimal Velocity Controller
if Params.OptimalVeloctityMode==2,
    Params.CursorController.A = [...
        1	0	t	0;
        0	1	0	t;
        0	0	a	0;
        0	0	0	a];
    Params.CursorController.B = [...
        0   0   0   0
        0   0   0   0
        0   0   1   0
        0   0   0   1];
    qp = 2.5e0;
    qv = 0;
    Params.CursorController.Q = [...
        qp  0   0   0
        0   qp  0   0
        0   0   qv  0
        0   0   0   qv];
    rp = 1e0;
    rv = 3e0;
    Params.CursorController.R = [...
        rp  0   0   0
        0   rp  0   0
        0   0   rv  0
        0   0   0   rv];
    Params.CursorController.K = dlqr(...
        Params.CursorController.A,Params.CursorController.B,...
        Params.CursorController.Q,Params.CursorController.R);
end

%% Velocity Command Online Feedback
Params.DrawVelCommand.Flag = true;
Params.DrawVelCommand.Rect = [-425,-425,-350,-350];

%% Trial and Block Types
Params.NumImaginedBlocks    = 0;
Params.NumAdaptBlocks       = 0;
Params.NumFixedBlocks       = 1;
Params.NumTrialsPerBlock    = 10;

%% CLDA Parameters
TypeStrs                = {'none','refit','smooth_batch','rml'};
Params.CLDA.TypeStr     = TypeStrs{Params.CLDA.Type+1};

Params.CLDA.UpdateTime = 80; % secs, for smooth batch
Params.CLDA.Alpha = exp(log(.5) / (120/Params.CLDA.UpdateTime)); % for smooth batch

% Lambda
Params.CLDA.Lambda = 5000; % for RML
FinalLambda = 5000; % for RML
DeltaLambda = (FinalLambda - Params.CLDA.Lambda) ...
    / ((Params.NumAdaptBlocks-3)...
    *Params.NumTrialsPerBlock...
    *Params.UpdateRate * 3); % bins/trial;

Params.CLDA.DeltaLambda = DeltaLambda; % for RML
Params.CLDA.FinalLambda = FinalLambda; % for RML

Params.CLDA.FixedRmlFlag = false; % for RML during fixed
Params.CLDA.FixedLambda = FinalLambda; % for RML during fixed

switch Params.CLDA.AdaptType,
    case 'none',
        Params.CLDA.DeltaLambda = 0;
        Params.CLDA.DeltaAssistance = 0;
    case 'linear',
        switch Params.CLDA.Type,
            case 2, % smooth batch
                Params.CLDA.DeltaAssistance = ... % linearly decrease assistance
                    Params.Assistance...
                    /(Params.NumAdaptBlocks*Params.NumTrialsPerBlock*5/Params.CLDA.UpdateTime);
            case 3, % RML
                Params.CLDA.DeltaAssistance = ... % linearly decrease assistance
                    Params.Assistance...
                    /((Params.NumAdaptBlocks-1)*Params.NumTrialsPerBlock);
            otherwise, % none or refit
                Params.CLDA.DeltaAssistance = 0;
        end
end

%% Hold Times
Params.TargetHoldTime = .6;
Params.InterTrialInterval = 1;
Params.InstructedDelayTime = 0;
Params.MaxStartTime = 25;
Params.MaxReachTime = 12;
Params.InterBlockInterval = 10; % 0-10s, if set to 10 use instruction screen
Params.ImaginedMvmtTime = 3;

%% Persistence
Params.Persistencedir = '~/persistence';

%% Feedback
Params.FeedbackSound = false;
Params.ErrorWaitTime = 0;
Params.ErrorSound = 1000*audioread('buzz.wav');
Params.ErrorSoundFs = 8192;
[Params.RewardSound,Params.RewardSoundFs] = audioread('reward1.wav');
% play sounds silently once so Matlab gets used to it
sound(0*Params.ErrorSound,Params.ErrorSoundFs)

%% BlackRock Params
Params.ZBufSize = 120; % secs
Params.GenNeuralFeaturesFlag = true;
Params.ZscoreRawFlag = true;
Params.UpdateChStatsFlag = false;
Params.ZscoreFeaturesFlag = true;
Params.UpdateFeatureStatsFlag = false;
Params.SaveRaw = true;
Params.SaveProcessed = false;

Params.DimRed.Flag = false;
Params.DimRed.InitMode = 2; % 1-use imagined mvmts, 2-choose dir
Params.DimRed.InitAdapt = true;
Params.DimRed.InitFixed = ~Params.DimRed.InitAdapt;
Params.DimRed.Method = 1; % 1-pca, 2-fa
Params.DimRed.AvgTrialsFlag = false; % 0-cat imagined mvmts, 1-avg imagined mvmts
Params.DimRed.NumDims = 500;

Params.Fs = 1000;
Params.NumChannels = 128;
Params.NumFeatureBins = 1;
Params.BufferTime = 2; % secs longer for better phase estimation of low frqs
Params.BufferSamps = Params.BufferTime * Params.Fs;
RefModeStr = {'none','common_mean','common_median'};
Params.ReferenceMode = 2; % 0-no ref, 1-common mean, 2-common median
Params.ReferenceModeStr = RefModeStr{Params.ReferenceMode+1};

Params.ChMapFile = 'ECOG_Grid_8596-002135';

% filter bank - each element is a filter bank
% fpass - bandpass cutoff freqs
% feature - # of feature (can have multiple filters for a single feature
% eg., high gamma is composed of multiple freqs)
Params.FilterBank = [];
Params.FilterBank(end+1).fpass = [.5,4];    % delta
Params.FilterBank(end).buffer_flag = true;
Params.FilterBank(end).hilbert_flag = true;
Params.FilterBank(end).phase_flag = true;
Params.FilterBank(end).feature = 2;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [4,8];     % theta
Params.FilterBank(end).buffer_flag = true;
Params.FilterBank(end).hilbert_flag = true;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 3;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [8,13];    % alpha
Params.FilterBank(end).buffer_flag = true;
Params.FilterBank(end).hilbert_flag = true;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 4;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [13,19];   % beta1
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 5;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [19,30];   % beta2
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 5;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [30,36];   % low gamma1
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 6;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [36,42];   % low gamma2
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 6;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [42,50];   % low gamma3
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 6;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [70,77];   % high gamma1
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 7;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [77,85];   % high gamma2
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 7;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [85,93];   % high gamma3
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 7;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [93,102];  % high gamma4
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 7;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [102,113]; % high gamma5
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 7;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [113,124]; % high gamma6
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 7;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [124,136]; % high gamma7
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 7;
Params.FilterBank(end).spatial_filt_sz = 3;

Params.FilterBank(end+1).fpass = [136,150]; % high gamma8
Params.FilterBank(end).buffer_flag = false;
Params.FilterBank(end).hilbert_flag = false;
Params.FilterBank(end).phase_flag = false;
Params.FilterBank(end).feature = 7;
Params.FilterBank(end).spatial_filt_sz = 3;

% compute filter coefficients
for i=1:length(Params.FilterBank),
    [b,a] = butter(3,Params.FilterBank(i).fpass/(Params.Fs/2));
    Params.FilterBank(i).b = b;
    Params.FilterBank(i).a = a;
end

% unique pwr feature + all phase features
Params.NumBuffer = sum([Params.FilterBank.buffer_flag]);
Params.NumHilbert = sum([Params.FilterBank.hilbert_flag]);
Params.NumPhase = sum([Params.FilterBank.phase_flag]);
Params.NumPower = length(unique([Params.FilterBank.feature]));
Params.NumFeatures = Params.NumPower + Params.NumPhase;

% make sure spatial filter sizes are consistent within features
features = [Params.FilterBank.feature];
for feature=Params.NumPhase+1:Params.NumFeatures,
    idx = features == feature;
    spatial_filt_szs = [Params.FilterBank(idx).spatial_filt_sz];
    if length(spatial_filt_szs)>1,
        assert(all(spatial_filt_szs==spatial_filt_szs(1)),...
            'Spatial Filter Sizes are Inconsistent')
    end
end

%% Feature Mask

if Params.UseFeatureMask,
    % loads feature mask
    [filename,pathname] = uigetfile('*.mat', 'Choose Feature Mask (Press Cancel for None)');
    
    % pressed cancel
    if isequal(filename,0) || isequal(pathname,0),
        % sets all bad channels to 0, o.w. 1
        Mask = ones(Params.NumChannels*Params.NumFeatures,1);
        for i=1:length(Params.BadChannels),
            bad_ch = Params.BadChannels(i);
            Mask(bad_ch+(0:Params.NumChannels:Params.NumChannels*(Params.NumFeatures-1)),1) = 0;
        end
        Params.FeatureMask = Mask==1;
    else, % user file
        f = load(fullfile(pathname,filename));
        Params.FeatureMask = f.mask==1;
    end
else,
    % sets all bad channels to 0, o.w. 1
    Mask = ones(Params.NumChannels*Params.NumFeatures,1);
    for i=1:length(Params.BadChannels),
        bad_ch = Params.BadChannels(i);
        Mask(bad_ch+(0:Params.NumChannels:Params.NumChannels*(Params.NumFeatures-1)),1) = 0;
    end
    Params.FeatureMask = Mask==1;

end

end % GetParams

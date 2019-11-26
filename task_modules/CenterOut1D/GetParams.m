function Params = GetParams(Params)
% Experimental Parameters
% These parameters are meant to be changed as necessary (day-to-day,
% subject-to-subject, experiment-to-experiment)
% The parameters are all saved in 'Params.mat' for each experiment

%% Experiment
Params.Task = 'CenterOut1D';
switch Params.ControlMode,
    case 1, Params.ControlModeStr = 'MousePosition';
    case 2, Params.ControlModeStr = 'MouseVelocity';
    case 3, Params.ControlModeStr = 'KalmanPosVel';
    case 4, Params.ControlModeStr = 'KalmanVelocity';
end

%% Control
Params.CenterReset      = false; % if true, cursor automatically is at center at trial start
Params.Assistance       = 0; %0.05; % value btw 0 and 1, 1 full assist
Params.DaggerAssist 	= false;

Params.CLDA.Type        = 3; % 0-none, 1-refit, 2-smooth batch, 3-RML
Params.CLDA.AdaptType   = 'linear'; % {'none','linear'}, affects assistance & lambda for rml

Params.InitializationMode   = 4; % 1-imagined mvmts, 2-shuffled imagined mvmts, 3-choose dir, 4-most recent KF
Params.BaselineTime         = 0; % secs
Params.BadChannels          = [];
Params.SpatialFiltering     = false;
Params.UseFeatureMask       = true;
Params.GenNeuralFeaturesFlag= false; % if blackrock is off, automatically sets to true

Params.MvmtAxisAngle    = 45;

%% Cursor Velocity
Params.Gain                     = 1;
Params.OptimalVeloctityMode     = 1; % 1-vector to target
Params.VelocityTransformFlag    = false;
Params.MaxVelocityFlag          = false;
Params.MaxVelocity              = 200;

%% Sync to Blackrock
Params.ArduinoSync = false;

%% Timing
Params.ScreenRefreshRate = 10; % Hz
Params.UpdateRate = 10; % Hz

%% Targets
Params.TargetSize = 50;
Params.OutTargetColor = [55,255,0];
Params.InTargetColor = [255,55,0];

Params.StartTargetPosition  = 0;
Params.TargetRect = ...
    [-Params.TargetSize -Params.TargetSize +Params.TargetSize +Params.TargetSize];

Params.ReachTargetRadius = 250;
Params.ReachTargetPositions = Params.StartTargetPosition + ...
    [-Params.ReachTargetRadius; +Params.ReachTargetRadius];
Params.NumReachTargets = 2;

%% Cursor
Params.CursorColor = [0,102,255];
Params.CursorSize = 15;
Params.CursorRect = [-Params.CursorSize -Params.CursorSize ...
    +Params.CursorSize +Params.CursorSize];

%% Kalman Filter Properties
Params.SaveKalmanFlag = false;
G = Params.Gain;
dt = 1/Params.UpdateRate;
a = 0.825;
w = 150;
if Params.ControlMode>=3,
    Params = LoadKF1dDynamics(Params, G, dt, a, w);
end

%% Velocity Command Online Feedback
Params.DrawVelCommand.Flag = true;
Params.DrawVelCommand.Rect = [-425,-425,-350,-350];

%% Trial and Block Types
Params.NumImaginedBlocks    = 0;
Params.NumAdaptBlocks       = 4;
Params.NumFixedBlocks       = 2;
Params.NumTrialsPerBlock    = 8;
Params.TargetSelectionFlag  = 1; % 1-pseudorandom, 2-random
switch Params.TargetSelectionFlag,
    case 1, Params.TargetFunc = @(n) mod(randperm(n),Params.NumReachTargets)+1;
    case 2, Params.TargetFunc = @(n) mod(randi(n,1,n),Params.NumReachTargets)+1;
end

%% CLDA Parameters
TypeStrs                = {'none','refit','smooth_batch','rml'};
Params.CLDA.TypeStr     = TypeStrs{Params.CLDA.Type+1};

Params.CLDA.UpdateTime = 80; % secs, for smooth batch
Params.CLDA.Alpha = exp(log(.5) / (120/Params.CLDA.UpdateTime)); % for smooth batch

Params.CLDA.Lambda = 5000; %exp(log(.5) / (30*Params.UpdateRate)); % for RML
Params.CLDA.FinalLambda = 5000; %exp(log(.5) / (500*Params.UpdateRate));
DeltaLambda = (Params.CLDA.FinalLambda - Params.CLDA.Lambda) ...
    / ((Params.NumAdaptBlocks-1)...
    *Params.NumTrialsPerBlock...
    *Params.UpdateRate * 4); % bins/trial;
Params.CLDA.DeltaLambda = DeltaLambda; % for RML

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
Params.TargetHoldTime = .2;
Params.InterTrialInterval = 0;
if Params.CenterReset,
    Params.InstructedDelayTime = .6;
else,
    Params.InstructedDelayTime = 0;
end
Params.MaxStartTime = 25;
Params.MaxReachTime = 25;
Params.InterBlockInterval = 10; % 0-10s, if set to 10 use instruction screen
Params.ImaginedMvmtTime = 3;

%% Feedback
Params.FeedbackSound = false;
Params.ErrorWaitTime = 0;
Params.ErrorSound = 1000*audioread('buzz.wav');
Params.ErrorSoundFs = 8192;
[Params.RewardSound,Params.RewardSoundFs] = audioread('reward1.wav');
% play sounds silently once so Matlab gets used to it
sound(0*Params.ErrorSound,Params.ErrorSoundFs)

end % GetParams


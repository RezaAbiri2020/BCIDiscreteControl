function Params = GetParams(Params)
% Experimental Parameters
% These parameters are meant to be changed as necessary (day-to-day,
% subject-to-subject, experiment-to-experiment)
% The parameters are all saved in 'Params.mat' for each experiment

%% Experiment
Params.Task = 'ExoControl1D';
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

Params.MvmtAxisAngle        = 0;

%% Cursor Velocity
Params.Gain                     = 1;
Params.OptimalVeloctityMode     = 1; % 1-vector to target
Params.VelocityTransformFlag    = false;
Params.MaxVelocityFlag          = false;
Params.MaxVelocity              = 200;

%% Sync to Blackrock
Params.ArduinoSync = false;

%% Exo Control
if Params.ArduinoSync,
    Params.ArduinoPtr = arduino('COM41','Due','Libraries','I2C');   % Planar Laptop
    %     Params.ArduinoPtr = arduino('COM9','Due','Libraries','I2C');  % Rob's Laptop
    %     Params.ArduinoPtr = arduino('/dev/ttyACM0','Due','Libraries','I2C');
    Params.ArduinoPin = 'D13';
    writeDigitalPin(Params.ArduinoPtr, Params.ArduinoPin, 0); % make sure the pin is at 0
    PulseArduino(Params.ArduinoPtr,Params.ArduinoPin,20);
    
    Params.Arduino.devBBS   = i2cdev(Params.ArduinoPtr,'0x01','bus',0); % BBS is on Brain Box bus I2C0, device 1
    Params.Arduino.planar.velParams.minSpeed     = -100; % mm/s
    Params.Arduino.planar.velParams.maxSpeed     =  100; % mm/s
    Params.Arduino.planar.velParams.bits         =  12; % bits
    Params.Arduino.planar.velParams.f_speed2bits      = @(speed) round(((speed-Params.Arduino.planar.velParams.minSpeed)...
        ./(Params.Arduino.planar.velParams.maxSpeed-Params.Arduino.planar.velParams.minSpeed))...
        .*(2^Params.Arduino.planar.velParams.bits-1));
    
    % 	Params.Arduino.planar.posParams.screenResolution  = [1920,1080];  % Fancy B1 Monitor
    Params.Arduino.planar.posParams.screenResolution  = [1680,1050];  % Monitor in 133SDH
    % 	Params.Arduino.planar.posParams.screenResolution  = [1920,1200];  % Star Monitor in 133SDH
    % 	Params.Arduino.planar.posParams.screenResolution  = [1600,900];   % Labtop
    Params.Arduino.planar.posParams.planarBounds      = [-300,300,-10,300];   % mm
    Params.Arduino.planar.posParams.planarPlotLoc     = [Params.Arduino.planar.posParams.screenResolution(1)/2,...
        Params.Arduino.planar.posParams.screenResolution(2)/2+...
        -(Params.Arduino.planar.posParams.planarBounds(4)-Params.Arduino.planar.posParams.planarBounds(3))/2];           % mm
    Params.Arduino.planar.pos   = [0;0];            % mm
    
    Params.Arduino.planar.usePlanarAsCursor     = 1;
    
    Params.Arduino.planar.posParams.minPos            = -300; % mm
    Params.Arduino.planar.posParams.maxPos            =  300; % mm
    Params.Arduino.planar.posParams.bits              =  12; % bits
    Params.Arduino.planar.posParams.f_bits2pos        = @(bits) ((double(bits)./(2^Params.Arduino.planar.posParams.bits-1))...
        .*(Params.Arduino.planar.posParams.maxPos-Params.Arduino.planar.posParams.minPos)...
        +Params.Arduino.planar.posParams.minPos);
    
    Params.Arduino.planar.enable                = 0;    % 1-bit     Turn planar off and on
    Params.Arduino.planar.velocityMode          = 0;    % 1-bit     Move to target, or accept sent velocities
    Params.Arduino.planar.target                = 0;    % 4-bits    For 16 preset targets
    Params.Arduino.planar.vel   = [0;0];
    
    Params.Arduino.glove.enable                = 0;    % 1-bit     Turn planar off and on
    Params.Arduino.glove.admittanceMode        = 0;    % 1-bit     Move to target, or accept sent velocities
    Params.Arduino.glove.target                = 0;    % 4-bits    For 16 preset targets
    
    Params.Arduino  = UpdateArduino(Params.Arduino);
end

%% Timing
Params.ScreenRefreshRate = 10; % Hz
Params.UpdateRate = 10; %10 = Imagined; 5 = control % Hz

%% Targets
Params.TargetSize = 70;
Params.OutTargetColor = [55,255,0];
Params.InTargetColor = [255,55,0];

Params.StartTargetPosition  = 0;
Params.TargetRect = ...
    [-Params.TargetSize -Params.TargetSize +Params.TargetSize +Params.TargetSize];

Params.ReachTargetRadius = 100;
Params.ReachTargetPositions = Params.StartTargetPosition + ...
    [-Params.ReachTargetRadius; +Params.ReachTargetRadius];
Params.NumReachTargets = 1;

%% Cursor
Params.CursorColor = [95, 6, 150];
Params.CursorSize = 15;
Params.CursorRect = [-Params.CursorSize -Params.CursorSize ...
    +Params.CursorSize +Params.CursorSize];

%% Kalman Filter Properties
a = 0.825;
w = 150;
G = Params.Gain;
t = 1/Params.UpdateRate;
if Params.ControlMode>=3,
    Params = LoadKF1dDynamics(Params, G, t, a, w);
end

%% Velocity Command Online Feedback
Params.DrawVelCommand.Flag = true;
Params.DrawVelCommand.Rect = [-425,-425,-350,-350];

%% Trial and Block Types
Params.NumImaginedBlocks    = 0;
Params.NumAdaptBlocks       = 1;
Params.NumFixedBlocks       = 0;
Params.NumTrialsPerBlock    = 2;
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
    / ((Params.NumAdaptBlocks-2)...
    *Params.NumTrialsPerBlock...
    *Params.UpdateRate * 3); % bins/trial;
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
Params.TargetHoldTime = 4;
Params.InterTrialInterval = 1;
Params.InstructedGraspTime = 8;
Params.InstructedDelayTime = 0.1;
Params.MaxStartTime = 20;
Params.MaxReachTime = 20;
Params.InterBlockInterval = 10; % 0-10s, if set to 10 use instruction screen
Params.ImaginedMvmtTime = 6;
 
%% Feedback
Params.FeedbackSound = false;
Params.ErrorWaitTime = .5;
Params.ErrorSound = 1000*audioread('buzz.wav');
Params.ErrorSoundFs = 8192;
[Params.RewardSound,Params.RewardSoundFs] = audioread('reward1.wav');
% play sounds silently once so Matlab gets used to it
sound(0*Params.ErrorSound,Params.ErrorSoundFs)

end % GetParams


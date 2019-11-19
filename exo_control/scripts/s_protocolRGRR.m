

% Move Planar system to the home position then disable it.
Params.Arduino.planar.target        = 0;    % 1-bit     Move to Home
Params.Arduino.glove.enable         = 1;    % 1-bit     Enable Glove
Params.Arduino.glove.admittanceMode = 1;    % 1-bit     Set glove to admittance mode to reduce strain in hand
s_planarForceState;

% Offer tempoary respite between trials
s_interTrialInterval;

% Instruct to go to reach target
idx = Data.TargetID;
switch idx
    case 0
        Params.Arduino.planar.target           = 0;
    case 1 % Left Target
        Params.Arduino.planar.target           = 5; % Go West
    case 2 % Right Target
        Params.Arduino.planar.target           = 1; % Go East
    otherwise
        Params.Arduino.planar.target           = 0;
end
s_planarInstructTarget;



% Allow volitional movements
s_planarVolitional;

% Force to target
s_planarForceState

% Force to hand to open
Params.Arduino.glove.target = 2;
s_gloveForceState

% Force to hand to close
Params.Arduino.glove.target = 0;
s_gloveForceState

% Offer tempoary respite between trials
s_interTrialInterval;

% Instruct to go Home
Params.Arduino.planar.target = 0;
s_planarInstructTarget;

% Allow volitional movements
s_planarVolitional;

% Force to open
Params.Arduino.glove.target = 2; % Set to open
s_gloveForceState




% On completion of attempted return motion, disable planar and switch to position mode
Params.Arduino.planar.enable        = 0;    % 1-bit     Disable planar
Params.Arduino.planar.velocityMode  = 0;    % 1-bit     Set planar to position mode
Params.Arduino.glove.enable         = 1;    % 1-bit     Enable Glove
Params.Arduino.glove.admittanceMode = 1;    % 1-bit     Set glove to admittance mode to reduce strain in hand
Params.Arduino = UpdateArduino(Params.Arduino);
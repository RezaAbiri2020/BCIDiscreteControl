% s_protocol1DClose

% Move Planar system to the home position then disable it.
Params.Arduino.planar.target        = 0;    % 1-bit     Move to Home
Params.Arduino.glove.enable         = 1;    % 1-bit     Enable Glove
Params.Arduino.glove.admittanceMode = 1;    % 1-bit     Set glove to admittance mode to reduce strain in hand
s_planarForceState;

% Offer tempoary respite between trials
s_interTrialInterval;

% Force to open
Params.Arduino.glove.target = 2; % Set to open
s_gloveForceState

% Offer tempoary respite between trials
s_interTrialInterval;

% Instruct to top target
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

% Allow volitional hand close
Params.Arduino.glove.target = 0; % Set to close
s_gloveVolitional;

% On completion of attempted return motion, disable planar and switch to position mode
Params.Arduino.planar.enable        = 0;    % 1-bit     Disable planar
Params.Arduino.planar.velocityMode  = 0;    % 1-bit     Set planar to position mode
Params.Arduino.glove.enable         = 1;    % 1-bit     Enable Glove
Params.Arduino.glove.admittanceMode = 1;    % 1-bit     Set glove to admittance mode to reduce strain in hand
Params.Arduino = UpdateArduino(Params.Arduino);
% s_planarForceState
Params.Arduino.planar.enable            = 1;    % 1-bit     Enable Planar
Params.Arduino.planar.velocityMode      = 0;    % 1-bit     Position Mode
Params.Arduino = UpdateArduino(Params.Arduino);

% pause(1)
Params.Arduino.planar.ready = 0;
while Params.Arduino.planar.ready == 0
    Params.Arduino  = UpdateArduino(Params.Arduino);
    switch Params.Arduino.planar.target
        
        case 0
            [newX, newY, textHeight]=Screen('DrawText', Params.WPTR, ...
                'Auto-correcting system to home position...',...
                50, 50, [255,0,0], [0,0,0]);
        case 1
            [newX, newY, textHeight]=Screen('DrawText', Params.WPTR, ...
                'Auto-correcting system to right target...',...
                50, 50, [255,0,0], [0,0,0]);
        case 5
            [newX, newY, textHeight]=Screen('DrawText', Params.WPTR, ...
                'Auto-correcting system to left target...',...
                50, 50, [255,0,0], [0,0,0]);
    end
    Screen('Flip', Params.WPTR);
    if CheckPause, [Neuro,Data,Params] = ExperimentPause(Params,Neuro,Data); end
    pause(0.1);
end
Cursor.State = [0,0,1]';
Params.Arduino.planar.enable    = 0;    % 1-bit     Disable Planar
Params.Arduino = UpdateArduino(Params.Arduino);
% s_gloveForceState
Params.Arduino.glove.enable         = 1;    % 1-bit     Move to target, or accept sent velocities
Params.Arduino.glove.admittanceMode = 0;    % 1-bit     Set planar to position control mode
Params.Arduino = UpdateArduino(Params.Arduino);

Data.ErrorID = 0;
Cursor.LastPredictTime = GetSecs;

if ~Data.ErrorID && Params.InstructedGraspTime>0,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Instructed Grasp';
    if Params.ArduinoSync, PulseArduino(Params.ArduinoPtr,Params.ArduinoPin,length(Data.Events)); end


    done = 0;
    TotalTime = 0;
    InTargetTotalTime = 0;
% 	fprintf('\t\tGrasp Time: %03.03f.\n',InTargetTotalTime)
    while ~done,
        switch Params.Arduino.glove.target
            case 0
                Screen('DrawText', Params.WPTR, 'Grasp...',50, 50, [255,0,0], [0,0,0]);
            case 2
                Screen('DrawText', Params.WPTR, 'Release...',50, 50, [255,0,0], [0,0,0]);
        end
%         fprintf('\tGrasp...\n')
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, [Neuro,Data,Params] = ExperimentPause(Params,Neuro,Data); end

        % Update Screen
        if (tim-Cursor.LastPredictTime) > 1/Params.ScreenRefreshRate,
            % time
            dt = tim - Cursor.LastPredictTime;
            TotalTime = TotalTime + dt;
            dt_vec(end+1) = dt;
            Cursor.LastPredictTime = tim;
            Data.Time(1,end+1) = tim;

            % grab and process neural data
            if ((tim-Cursor.LastUpdateTime)>1/Params.UpdateRate),
                dT = tim-Cursor.LastUpdateTime;
                dT_vec(end+1) = dT;
                Cursor.LastUpdateTime = tim;
                
                Data.NeuralTime(1,end+1) = tim;
                [Neuro,Data] = NeuroPipeline(Neuro,Data,Params);
                %KF = UpdateCursorExo1D(Params,Neuro,TaskFlag,StartTargetPos,KF);
                % save kalman filter
                %if Params.ControlMode>=3 && TaskFlag>1 && Params.SaveKalmanFlag,
                %    Data.KalmanGain{end+1} = [];
                %    Data.KalmanGain{end}.K = KF.K;
                %    Data.KalmanFilter{end+1} = [];
                %    Data.KalmanFilter{end}.C = KF.C;
                %    Data.KalmanFilter{end}.Q = KF.Q;
                %    Data.KalmanFilter{end}.Lambda = KF.Lambda;
                %end
                %Params = PositionArduino(Params);
                %Cursor.State(1) = Params.Arduino.pos.planarPos;
            end

            % cursor

            CursorRect = Params.CursorRect;
            x = Cursor.State(1)*cosd(Params.MvmtAxisAngle);
            y = Cursor.State(1)*sind(Params.MvmtAxisAngle);
            CursorRect([1,3]) = CursorRect([1,3]) + x + Params.Center(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + y + Params.Center(2); % add y-pos
            Data.CursorState(:,end+1) = Cursor.State;
            Data.PlanarState(:,end+1) = Params.Arduino.planar.pos(1);
            Data.IntendedCursorState(:,end+1) = Cursor.IntendedState;
            Data.CursorAssist(1,end+1) = Cursor.Assistance;

            % start target
            if Params.DrawVelCommand.Flag && TaskFlag>1,
                VelRect = Params.DrawVelCommand.Rect;
                VelRect([1,3]) = VelRect([1,3]) + Params.Center(1);
                VelRect([2,4]) = VelRect([2,4]) + Params.Center(2);
                x0 = mean(VelRect([1,3]));
                y0 = mean(VelRect([2,4]));
                xf = x0 + 0.1*Cursor.Vcommand*cosd(Params.MvmtAxisAngle);
                yf = y0 + 0.1*Cursor.Vcommand*sind(Params.MvmtAxisAngle);
                Screen('FrameOval', Params.WPTR, [100,100,100], VelRect);
                Screen('DrawLine', Params.WPTR, [100,100,100], x0, y0, xf, yf, 3);
            end

            % Exo Position
            %             fprintf('Pos X: %04.02f,\tPos Y: %04.02f mm\n',...
            %                             Params.Arduino.pos.planarPos(1),...
            %                             Params.Arduino.pos.planarPos(2));
            planarRectangle = reshape(Params.Arduino.planar.posParams.planarBounds,2,2)...
                +kron(Params.Arduino.planar.posParams.planarPlotLoc,ones(2,1));
            planarCirc      = reshape([-10,10,-10,10],2,2)...
                +[[0;0],Params.Arduino.planar.posParams.planarBounds(4).*[1;1]]...
                +kron([1,-1].*Params.Arduino.planar.pos',[1;1])...
                +kron(Params.Arduino.planar.posParams.planarPlotLoc,ones(2,1));
            Screen('FrameRect', Params.WPTR, [100,0,0], planarRectangle([1,3,2,4]), [3]);
            Screen('FillOval', Params.WPTR, [100,0,0], planarCirc([1,3,2,4]), [3]);

            Screen('DrawingFinished', Params.WPTR);
            Screen('Flip', Params.WPTR);

            % Force in target
            inFlag = 1;
            if inFlag,
                InTargetTotalTime = InTargetTotalTime + dt;
            else, % error if they left too early
                done = 1;
                Data.ErrorID = 2;
                Data.ErrorStr = 'InstructedGrasp';
                fprintf('ERROR: %s\n',Data.ErrorStr)
            end
        end

        % end if in start target for hold time
%         fprintf('\t\tGrasp Time: %03.03f.\n',InTargetTotalTime)
        if InTargetTotalTime > Params.InstructedGraspTime,
            done = 1;
        end
    end % Instructed Delay Loop
end % only complete if no errors

% s_gloveVolitional
%% Go to reach target
% Enable planar into velocity control mode for reach from home to target
Params.Arduino.planar.enable            = 1;    % 1-bit     Lock glove position
Params.Arduino.planar.velocityMode      = 1;    % 1-bit     Set to target mode

Params.Arduino.glove.enable             = 0;    % 1-bit     Lock glove position
Params.Arduino.glove.admittanceMode     = 0;    % 1-bit     Set to target mode
Params.Arduino  = UpdateArduino(Params.Arduino);

Data.ErrorID = 0;
Cursor.LastPredictTime = GetSecs;
if ~Data.ErrorID,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Reach Target';
    if Params.ArduinoSync, PulseArduino(Params.ArduinoPtr,Params.ArduinoPin,length(Data.Events)); end
    
    %     disp(Params.Arduino.planar.pos)
    %     disp(StartTargetPos)
    %     disp(ReachTargetPos)
    
    if TaskFlag==1, % If imagined movements
        switch Params.Arduino.planar.target
            case 0
                OptimalCursorTraj = [...
                    GenerateCursorTraj1D(Params.Arduino.planar.pos(1),StartTargetPos,Params.ImaginedMvmtTime,Params);
                    GenerateCursorTraj1D(StartTargetPos,StartTargetPos,Params.TargetHoldTime,Params)];
                ct = 1;
            otherwise
                OptimalCursorTraj = [...
                    GenerateCursorTraj1D(Params.Arduino.planar.pos(1),ReachTargetPos,Params.ImaginedMvmtTime,Params);
                    GenerateCursorTraj1D(ReachTargetPos,ReachTargetPos,Params.TargetHoldTime,Params)];
                ct = 1;
        end
    end
    
    done = 0;
    TotalTime = 0;
    InTargetTotalTime = 0;
    while ~done,
        Screen('DrawText', Params.WPTR, 'Attempt to go to target...',50, 50, [255,0,0], [0,0,0]);
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
                
                switch Params.Arduino.planar.target
                    case 0
                        [KF,Params] = UpdateCursorExo1D(Params,Neuro,TaskFlag,StartTargetPos,KF);
                    otherwise
                        [KF,Params] = UpdateCursorExo1D(Params,Neuro,TaskFlag,ReachTargetPos,KF);
                end
                % save kalman filter
                if Params.ControlMode>=3 && TaskFlag>1 && Params.SaveKalmanFlag,
                    Data.KalmanGain{end+1} = [];
                    Data.KalmanGain{end}.K = KF.K;
                    Data.KalmanFilter{end+1} = [];
                    Data.KalmanFilter{end}.C = KF.C;
                    Data.KalmanFilter{end}.Q = KF.Q;
                    Data.KalmanFilter{end}.Lambda = KF.Lambda;
                end
                
                %                 Params = PositionArduino(Params);
                %Cursor.State(1) = Params.Arduino.pos.planarPos;
            end
            
            % cursor
            if TaskFlag==1, % imagined movements
                %                 disp(ct);
                %                 disp(OptimalCursorTraj)
                Cursor.State(2) = (OptimalCursorTraj(ct)'-Cursor.State(1))/dt;
                Cursor.State(1) = OptimalCursorTraj(ct);
                Cursor.Vcommand = Cursor.State(2);
                ct = ct + 1;
            end
            CursorRect = Params.CursorRect;
            
            x = Cursor.State(1)*cosd(Params.MvmtAxisAngle);
            y = Cursor.State(1)*sind(Params.MvmtAxisAngle);
            CursorRect([1,3]) = CursorRect([1,3]) + x + Params.Center(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + y + Params.Center(2); % add y-pos
            Data.CursorState(:,end+1) = Cursor.State;
            Data.PlanarState(:,end+1) = Params.Arduino.planar.pos(1);
            Data.IntendedCursorState(:,end+1) = Cursor.IntendedState;
            Data.CursorAssist(1,end+1) = Cursor.Assistance;
            
            % reach target
            ReachRect = Params.TargetRect; % centered at (0,0)
            x = ReachTargetPos*cosd(Params.MvmtAxisAngle);
            y = ReachTargetPos*sind(Params.MvmtAxisAngle);
            ReachRect([1,3]) = ReachRect([1,3]) + x + Params.Center(1); % add x-pos
            ReachRect([2,4]) = ReachRect([2,4]) + y + Params.Center(2); % add y-pos
            
            %             switch Params.Arduino.planar.usePlanarAsCursor
            %                 case 0
            %                     inFlag = InTarget(Cursor,ReachTargetPos,Params.TargetSize);
            %                 case 1
            %                     foo.State(1) = Params.Arduino.planar.pos(1);
            %                     inFlag = InTarget(foo,ReachTargetPos,Params.TargetSize);
            %             end
            %             fprintf('Flag: %02.02f,\tCursor X: %03.0 p3f,\tPlanar X: %03.03f\n',inFlag,x,foo.State(1));
            
            % draw
            
            switch Params.Arduino.planar.target
                case 0
                    inFlag = InTarget(Cursor,StartTargetPos,Params.TargetSize);
                    if inFlag, StartCol = Params.InTargetColor;
                    else, StartCol = Params.OutTargetColor;
                    end
                    Screen('FillOval', Params.WPTR, ...
                        cat(1,StartCol,Params.CursorColor)', ...
                        cat(1,StartRect,CursorRect)')
                otherwise
                    inFlag = InTarget(Cursor,ReachTargetPos,Params.TargetSize);
                    if inFlag, ReachCol = Params.InTargetColor;
                    else, ReachCol = Params.OutTargetColor;
                    end
                    Screen('FillOval', Params.WPTR, ...
                        cat(1,ReachCol,Params.CursorColor)', ...
                        cat(1,ReachRect,CursorRect)')
            end
            
            
            
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
            %             Screen('FrameRect', Params.WPTR, [100,0,0], planarRectangle([1,3,2,4]), [3]);
            %             Screen('FillOval', Params.WPTR, [100,0,0], planarCirc([1,3,2,4]), [3]);
            
            Screen('DrawingFinished', Params.WPTR);
            Screen('Flip', Params.WPTR);
            
            % start counting time if cursor is in target
            if inFlag,
                InTargetTotalTime = InTargetTotalTime + dt;
            else
                InTargetTotalTime = 0;
            end
        end
        
        % end if takes too long
        if TotalTime > Params.MaxReachTime,
            done = 1;
            Data.ErrorID = 3;
            Data.ErrorStr = 'ReachTarget';
            fprintf('ERROR: %s\n',Data.ErrorStr)
        end
        
        % end if in start target for hold time
        if InTargetTotalTime > Params.TargetHoldTime,
            done = 1;
            
            if Params.ArduinoSync,
                PulseArduino(Params.ArduinoPtr,...
                    Params.ArduinoPin,...
                    6);
            end
            if idx == 1
                Params.Arduino.glove.enable = 1; % Enable glove to move to preset target
                Params.Arduino.planar.enable            = 0;    % 1-bit     Lock glove position
                Params.Arduino.planar.velocityMode      = 0;    % 1-bit     Set to target mode
                s_gloveForceState
            end
        end
    end % Reach Target Loop
end % only complete if no errors




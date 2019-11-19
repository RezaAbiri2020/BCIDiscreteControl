% s_planarInstructTarget

% Send updataed target params to system (should be in offline, postion ctrl mode)

Params.Arduino.planar.enable            = 0;    % 1-bit     Move to target, or accept sent velocities
Params.Arduino  = UpdateArduino(Params.Arduino);

Cursor.LastPredictTime = GetSecs;
if ~Data.ErrorID && Params.InstructedDelayTime>0,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Instructed Delay';
    if Params.SerialSync, fprintf(Params.SerialPtr, '%s\n', 'ID'); end
    if Params.ArduinoSync, PulseArduino(Params.ArduinoPtr,Params.ArduinoPin,length(Data.Events)); end

    if TaskFlag==1,
        switch Params.Arduino.planar.target
            case 0
                OptimalCursorTraj = ...
                    GenerateCursorTraj1D(StartTargetPos,StartTargetPos,Params.InstructedDelayTime,Params);
                ct = 1;
            otherwise
                OptimalCursorTraj = ...
                    GenerateCursorTraj1D(ReachTargetPos,ReachTargetPos,Params.InstructedDelayTime,Params);
                ct = 1;
        end
    end

    done = 0;
    TotalTime = 0;
    InTargetTotalTime = 0;
    while ~done,
        Screen('DrawText', Params.WPTR, 'Instruct to go target...',50, 50, [255,0,0], [0,0,0]);
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
                
            end

            % cursor
            if TaskFlag==1, % imagined movements
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

            % start target
            StartRect = Params.TargetRect; % centered at (0,0)
            x = StartTargetPos*cosd(Params.MvmtAxisAngle);
            y = StartTargetPos*sind(Params.MvmtAxisAngle);
            StartRect([1,3]) = StartRect([1,3]) + x + Params.Center(1); % add x-pos
            StartRect([2,4]) = StartRect([2,4]) + y + Params.Center(2); % add y-pos

%             switch Params.Arduino.planar.usePlanarAsCursor
%                 case 0
%                     inFlag = InTarget(Cursor,ReachTargetPos,Params.TargetSize);
%                 case 1
%                     foo.State(1) = Params.Arduino.planar.pos(1);
%                     inFlag = InTarget(foo,ReachTargetPos,Params.TargetSize);
% %                     fprintf('Flag: %02.02f,\tCursor X: %03.03f,\tPlanar X: %03.03f\n',inFlag,x,foo.State(1));
%             end

            % reach target
            ReachRect = Params.TargetRect; % centered at (0,0)
            x = ReachTargetPos*cosd(Params.MvmtAxisAngle);
            y = ReachTargetPos*sind(Params.MvmtAxisAngle);
            ReachRect([1,3]) = ReachRect([1,3]) + x + Params.Center(1); % add x-pos
            ReachRect([2,4]) = ReachRect([2,4]) + y + Params.Center(2); % add y-pos
            ReachCol = Params.OutTargetColor;

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
            Screen('FrameRect', Params.WPTR, [100,0,0], planarRectangle([1,3,2,4]), [3]);
            Screen('FillOval', Params.WPTR, [100,0,0], planarCirc([1,3,2,4]), [3]);

            Screen('DrawingFinished', Params.WPTR);
            Screen('Flip', Params.WPTR);

            % start counting time if cursor is in target
            if inFlag,
                InTargetTotalTime = InTargetTotalTime + dt;
            else, % error if they left too early
                done = 1;
                Data.ErrorID = 2;
                Data.ErrorStr = 'InstructedDelayHold';
                fprintf('ERROR: %s\n',Data.ErrorStr)
            end
        end

        % end if in start target for hold time
        if InTargetTotalTime > Params.InstructedDelayTime,
            done = 1;
        end
    end % Instructed Delay Loop
end % only complete if no errors
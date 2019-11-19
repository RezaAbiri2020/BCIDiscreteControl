% s_interTrialInterval
%% Inter Trial Interval
Data.ErrorID = 0;
Cursor.LastPredictTime = GetSecs;
if ~Data.ErrorID && Params.InterTrialInterval>0,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Inter Trial Interval';
    if Params.SerialSync, fprintf(Params.SerialPtr, '%s\n', 'ITI'); end
    if Params.ArduinoSync, PulseArduino(Params.ArduinoPtr,Params.ArduinoPin,length(Data.Events)); end

    if TaskFlag==1,
        OptimalCursorTraj = ...
            GenerateCursorTraj1D(Cursor.State(1),Cursor.State(1),Params.InterTrialInterval,Params);
        ct = 1;
    end

    done = 0;
    TotalTime = 0;
    while ~done,
        Screen('DrawText', Params.WPTR, 'Inter-trial Interval',50, 50, [255,0,0], [0,0,0]);
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, [Neuro,Data,Params] = ExperimentPause(Params,Neuro,Data); end

        % Update Screen Every Xsec
        if (tim-Cursor.LastPredictTime) > 1/Params.ScreenRefreshRate,
            % time
            dt = tim - Cursor.LastPredictTime;
            TotalTime = TotalTime + dt;
            dt_vec(end+1) = dt; %#ok<*AGROW>
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
%                 disp(Cursor.State')
                ct = ct + 1;
            end
            Data.CursorState(:,end+1) = Cursor.State;
            Data.IntendedCursorState(:,end+1) = Cursor.IntendedState;
            Data.CursorAssist(1,end+1) = Cursor.Assistance;

            CursorRect = Params.CursorRect;
            x = Cursor.State(1)*cosd(Params.MvmtAxisAngle);
            y = Cursor.State(1)*sind(Params.MvmtAxisAngle);
            CursorRect([1,3]) = CursorRect([1,3]) + x + Params.Center(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + y + Params.Center(2); % add y-pos
            Screen('FillOval', Params.WPTR, ...
                cat(1,Params.CursorColor)', ...
                cat(1,CursorRect)')

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

            Screen('Flip', Params.WPTR);
        end

        % end if takes too long
        if TotalTime > Params.InterTrialInterval,
            done = 1;
        end

    end % Inter Trial Interval
end % only complete if no errors
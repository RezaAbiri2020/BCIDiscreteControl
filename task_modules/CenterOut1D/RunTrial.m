function [Data, Neuro, KF, Params] = RunTrial(Data,Params,Neuro,TaskFlag,KF)
% Runs a trial, saves useful data along the way
% Each trial contains the following pieces
% 1) Inter-trial interval
% 2) Get the cursor to the start target (center)
% 3) Hold position during an instructed delay period
% 4) Get the cursor to the reach target (different on each trial)
% 5) Feedback

global Cursor

%% Set up trial
StartTargetPos = Params.StartTargetPosition;
ReachTargetPos = Data.TargetPosition;

% Output to Command Line
fprintf('\nTrial: %i\n',Data.Trial)
fprintf('  Target: %i\n',Data.TargetPosition)
if Params.Verbose,
    if TaskFlag==2,
        fprintf('    Cursor Assistance: %i%%\n',round(100*Cursor.Assistance))
        if Params.CLDA.Type==3,
            %fprintf('    Lambda 1/2 life: %.2fsecs\n',log(.5)/log(KF.Lambda)/Params.UpdateRate)
            fprintf('    Lambda 1/2 life: %.2fsecs\n',KF.Lambda)
        end
    end
end

% keep track of update times
dt_vec = [];
dT_vec = [];

% grab blackrock data and run through processing pipeline
if Params.BLACKROCK,
    Cursor.LastPredictTime = GetSecs;
    Cursor.LastUpdateTime = Cursor.LastPredictTime;
    Neuro = NeuroPipeline(Neuro,[],Params);
end

%% Inter Trial Interval
if ~Data.ErrorID && Params.InterTrialInterval>0,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Inter Trial Interval';
    if Params.ArduinoSync, PulseArduino(Params.ArduinoPtr,Params.ArduinoPin,length(Data.Events)); end
    
    if TaskFlag==1,
        OptimalCursorTraj = ...
            GenerateCursorTraj1D(Cursor.State,Cursor.State,Params.InterTrialInterval,Params);
        ct = 1;
    end
    
    done = 0;
    TotalTime = 0;
    while ~done,
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
                ct = ct + 1;
            end
            Data.CursorState(:,end+1) = Cursor.State;
            Data.IntendedCursorState(:,end+1) = Cursor.IntendedState;
            Data.CursorAssist(1,end+1) = Cursor.Assistance;

            Screen('Flip', Params.WPTR);
        end

        % end if takes too long
        if TotalTime > Params.InterTrialInterval,
            done = 1;
        end

    end % Inter Trial Interval
end % only complete if no errors

%% Go to Start Target
if ~Data.ErrorID && ~Params.CenterReset && TaskFlag>1,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Start Target';
    if Params.ArduinoSync, PulseArduino(Params.ArduinoPtr,Params.ArduinoPin,length(Data.Events)); end
    
    if TaskFlag==1,
        OptimalCursorTraj = [...
            GenerateCursorTraj1D(Cursor.State,StartTargetPos,Params.ImaginedMvmtTime,Params);
            GenerateCursorTraj1D(StartTargetPos,StartTargetPos,Params.TargetHoldTime,Params)];
        ct = 1;
    end
    
    done = 0;
    TotalTime = 0;
    InTargetTotalTime = 0;
    while ~done,
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, [Neuro,Data,Params] = ExperimentPause(Params,Neuro,Data); end

        % Update Screen Every Xsec
        if (tim-Cursor.LastPredictTime) > 1/Params.ScreenRefreshRate,
            tic;
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
                
                KF = UpdateCursor1D(Params,Neuro,TaskFlag,StartTargetPos,KF);
                % save kalman filter
                if Params.ControlMode>=3 && TaskFlag>1 && Params.SaveKalmanFlag,
                    Data.KalmanGain{end+1} = [];
                    Data.KalmanGain{end}.K = KF.K;
                    Data.KalmanFilter{end+1} = [];
                    Data.KalmanFilter{end}.C = KF.C;
                    Data.KalmanFilter{end}.Q = KF.Q;
                    Data.KalmanFilter{end}.Lambda = KF.Lambda;
                end
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
            Data.IntendedCursorState(:,end+1) = Cursor.IntendedState;
            Data.CursorAssist(1,end+1) = Cursor.Assistance;

            % start target
            StartRect = Params.TargetRect; % centered at (0,0)
            x = StartTargetPos*cosd(Params.MvmtAxisAngle);
            y = StartTargetPos*sind(Params.MvmtAxisAngle);
            StartRect([1,3]) = StartRect([1,3]) + x + Params.Center(1); % add x-pos
            StartRect([2,4]) = StartRect([2,4]) + y + Params.Center(2); % add y-pos
            inFlag = InTargetCenterOut1D(Cursor,StartTargetPos,Params.TargetSize);
            if inFlag, StartCol = Params.InTargetColor;
            else, StartCol = Params.OutTargetColor;
            end
            
            % draw
            Screen('FillOval', Params.WPTR, ...
                cat(1,StartCol,Params.CursorColor)', ...
                cat(1,StartRect,CursorRect)')
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
        if TotalTime > Params.MaxStartTime,
            done = 1;
            Data.ErrorID = 1;
            Data.ErrorStr = 'StartTarget';
            fprintf('ERROR: %s\n',Data.ErrorStr)
        end

        % end if in start target for hold time
        if InTargetTotalTime > Params.TargetHoldTime,
            done = 1;
        end
    end % Start Target Loop
else % only complete if no errors and no automatic reset to center
    Cursor.State = [0,0,1]';
end

%% Instructed Delay
if ~Data.ErrorID && Params.InstructedDelayTime>0,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Instructed Delay';
    if Params.ArduinoSync, PulseArduino(Params.ArduinoPtr,Params.ArduinoPin,length(Data.Events)); end
    
    if TaskFlag==1,
        OptimalCursorTraj = ...
            GenerateCursorTraj1D(StartTargetPos,StartTargetPos,Params.InstructedDelayTime,Params);
        ct = 1;
    end
    
    done = 0;
    TotalTime = 0;
    InTargetTotalTime = 0;
    while ~done,
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
            Data.IntendedCursorState(:,end+1) = Cursor.IntendedState;
            Data.CursorAssist(1,end+1) = Cursor.Assistance;

            % start target
            StartRect = Params.TargetRect; % centered at (0,0)
            x = StartTargetPos*cosd(Params.MvmtAxisAngle);
            y = StartTargetPos*sind(Params.MvmtAxisAngle);
            StartRect([1,3]) = StartRect([1,3]) + x + Params.Center(1); % add x-pos
            StartRect([2,4]) = StartRect([2,4]) + y + Params.Center(2); % add y-pos
            inFlag = InTargetCenterOut1D(Cursor,StartTargetPos,Params.TargetSize);
            if inFlag, StartCol = Params.InTargetColor;
            else, StartCol = Params.OutTargetColor;
            end
            
            % reach target
            ReachRect = Params.TargetRect; % centered at (0,0)
            x = ReachTargetPos*cosd(Params.MvmtAxisAngle);
            y = ReachTargetPos*sind(Params.MvmtAxisAngle);
            ReachRect([1,3]) = ReachRect([1,3]) + x + Params.Center(1); % add x-pos
            ReachRect([2,4]) = ReachRect([2,4]) + y + Params.Center(2); % add y-pos
            ReachCol = Params.OutTargetColor;
                        
            % draw
            Screen('FillOval', Params.WPTR, ...
                cat(1,ReachCol,Params.CursorColor)', ...
                cat(1,ReachRect,CursorRect)')
            %Screen('FillOval', Params.WPTR, ...
            %    cat(1,StartCol,ReachCol,Params.CursorColor)', ...
            %    cat(1,StartRect,ReachRect,CursorRect)')
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

%% Go to reach target
if ~Data.ErrorID,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Reach Target';
    if Params.ArduinoSync, PulseArduino(Params.ArduinoPtr,Params.ArduinoPin,length(Data.Events)); end
    
    if TaskFlag==1,
        OptimalCursorTraj = [...
            GenerateCursorTraj1D(StartTargetPos,ReachTargetPos,Params.ImaginedMvmtTime,Params);
            GenerateCursorTraj1D(ReachTargetPos,ReachTargetPos,Params.TargetHoldTime,Params)];
        ct = 1;
    end
    
    done = 0;
    TotalTime = 0;
    InTargetTotalTime = 0;
    while ~done,
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
                
                KF = UpdateCursor1D(Params,Neuro,TaskFlag,ReachTargetPos,KF);
                % save kalman filter
                if Params.ControlMode>=3 && TaskFlag>1 && Params.SaveKalmanFlag,
                    Data.KalmanGain{end+1} = [];
                    Data.KalmanGain{end}.K = KF.K;
                    Data.KalmanFilter{end+1} = [];
                    Data.KalmanFilter{end}.C = KF.C;
                    Data.KalmanFilter{end}.Q = KF.Q;
                    Data.KalmanFilter{end}.Lambda = KF.Lambda;
                end
            end
            
            % cursor
            if TaskFlag==1, % imagined movements
                Cursor.State(2) = (OptimalCursorTraj(ct)'-Cursor.State(1))/dt;
                Cursor.State(1) = OptimalCursorTraj(ct);
                Cursor.Vcommand = Cursor.State(2);
                ct = ct + 1;
                if ct > length(OptimalCursorTraj)
                end

            end
            CursorRect = Params.CursorRect;
            x = Cursor.State(1)*cosd(Params.MvmtAxisAngle);
            y = Cursor.State(1)*sind(Params.MvmtAxisAngle);
            CursorRect([1,3]) = CursorRect([1,3]) + x + Params.Center(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + y + Params.Center(2); % add y-pos
            Data.CursorState(:,end+1) = Cursor.State;
            Data.IntendedCursorState(:,end+1) = Cursor.IntendedState;
            Data.CursorAssist(1,end+1) = Cursor.Assistance;

            % reach target
            ReachRect = Params.TargetRect; % centered at (0,0)
            x = ReachTargetPos*cosd(Params.MvmtAxisAngle);
            y = ReachTargetPos*sind(Params.MvmtAxisAngle);
            ReachRect([1,3]) = ReachRect([1,3]) + x + Params.Center(1); % add x-pos
            ReachRect([2,4]) = ReachRect([2,4]) + y + Params.Center(2); % add y-pos

            % draw
            inFlag = InTargetCenterOut1D(Cursor,ReachTargetPos,Params.TargetSize);            
            if inFlag, 
                ReachCol = Params.InTargetColor;
            else, ReachCol = Params.OutTargetColor;
            end
            Screen('FillOval', Params.WPTR, ...
                cat(1,ReachCol,Params.CursorColor)', ...
                cat(1,ReachRect,CursorRect)')
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
        end
    end % Reach Target Loop
end % only complete if no errors


%% Completed Trial - Give Feedback
Screen('Flip', Params.WPTR);

% output update times
if Params.Verbose,
    fprintf('      Screen Update: Goal=%iHz, Actual=%.2fHz (+/-%.2fHz)\n',...
        Params.ScreenRefreshRate,mean(1./dt_vec),std(1./dt_vec))
    fprintf('      System Update: Goal=%iHz, Actual=%.2fHz (+/-%.2fHz)\n',...
        Params.UpdateRate,mean(1./dT_vec),std(1./dT_vec))
end

% output feedback
if Data.ErrorID==0,
    fprintf('SUCCESS\n')
    if Params.FeedbackSound,
        sound(Params.RewardSound,Params.RewardSoundFs)
    end
else
    % reset cursor
    Cursor.State = [0,0,1]';
    Cursor.IntendedState = [0,0,1]';
    
    if Params.FeedbackSound,
        sound(Params.ErrorSound,Params.ErrorSoundFs)
    end
    WaitSecs(Params.ErrorWaitTime);
end

end % RunTrial




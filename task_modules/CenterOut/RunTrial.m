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
fprintf('  Target: %i\n',Data.TargetAngle)
if Params.Verbose,
    if TaskFlag==2,
        fprintf('    Cursor Assistance: %.2f%%\n',100*Cursor.Assistance)
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
if Params.InterTrialInterval>0,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Inter Trial Interval';
    if Params.ArduinoSync, PulseArduino(Params.ArduinoPtr,Params.ArduinoPin,length(Data.Events)); end
    
    if TaskFlag==1,
        OptimalCursorTraj = ...
            GenerateCursorTraj(Cursor.State,Cursor.State,Params.InterTrialInterval,Params);
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
            
            Data.CursorState(:,end+1) = Cursor.State;
            Data.ClassifierState(:,end+1) = Cursor.ClassifierState;
            
            Screen('Flip', Params.WPTR);
        end
        
        % end if takes too long
        if TotalTime > Params.InterTrialInterval,
            done = 1;
        end
        
    end % Inter Trial Interval
end % only complete if no errors

%% Instructed Delay
if Params.InstructedDelayTime>0,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Instructed Delay';
    if Params.ArduinoSync, PulseArduino(Params.ArduinoPtr,Params.ArduinoPin,length(Data.Events)); end
    
    TotalTime = 0;
    InTargetTotalTime = 0;
    while TotalTime<Params.InstructedDelayTime,
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
            
            
            CursorRect = Params.CursorRect;
            CursorRect([1,3]) = CursorRect([1,3]) + Cursor.State(1) + Params.Center(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + Cursor.State(2) + Params.Center(2); % add y-pos
            Data.CursorState(:,end+1) = Cursor.State;
            Data.ClassifierState(:,end+1) = Cursor.ClassifierState;
            
            
            % show all possible reach targets in grey
            for i=1:length(Params.ReachTargetAngles)
                % reach targets % draw
                ReachRect = Params.TargetRect; % centered at (0,0)
                ReachRect([1,3]) = ReachRect([1,3]) + Params.ReachTargetPositions(i,1) + Params.Center(1); % add x-pos
                ReachRect([2,4]) = ReachRect([2,4]) + Params.ReachTargetPositions(i,2) + Params.Center(2); % add y-pos
                
                Screen('FillOval', Params.WPTR, ...
                    cat(1,Params.AllPossibleTargetColor,Params.CursorColor)', ...
                    cat(1,ReachRect,CursorRect)')
                
            end
            
            % instructed reach real target % draw
            ReachRect = Params.TargetRect; % centered at (0,0)
            ReachRect([1,3]) = ReachRect([1,3]) + ReachTargetPos(1) + Params.Center(1); % add x-pos
            ReachRect([2,4]) = ReachRect([2,4]) + ReachTargetPos(2) + Params.Center(2); % add y-pos
            
            Screen('FillOval', Params.WPTR, ...
                cat(1,Params.OutTargetColor,Params.CursorColor)', ...
                cat(1,ReachRect,CursorRect)')
            
            Screen('DrawingFinished', Params.WPTR);
            Screen('Flip', Params.WPTR);
            
        end
        
    end % Instructed Delay Loop
end % only complete if no errors

%% Go to reach target
tstart  = GetSecs;
Data.Events(end+1).Time = tstart;
Data.Events(end).Str  = 'Reach Target';
if Params.ArduinoSync, PulseArduino(Params.ArduinoPtr,Params.ArduinoPin,length(Data.Events)); end

TotalTime = 0;
InTargetTotalTime = 0;
while TotalTime < Params.DecisionTime
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
            
            KF = UpdateCursor(Params,Neuro,TaskFlag,ReachTargetPos,KF);
            
        end
        
        CursorRect = Params.CursorRect;
        CursorRect([1,3]) = CursorRect([1,3]) + Cursor.State(1) + Params.Center(1); % add x-pos
        CursorRect([2,4]) = CursorRect([2,4]) + Cursor.State(2) + Params.Center(2); % add y-pos
        Data.CursorState(:,end+1) = Cursor.State;
        Data.ClassifierState(:,end+1) = Cursor.ClassifierState;
        
        % show all possible reach targets in grey
        for i=1:length(Params.ReachTargetAngles)
            % reach targets % draw
            ReachRect = Params.TargetRect; % centered at (0,0)
            ReachRect([1,3]) = ReachRect([1,3]) + Params.ReachTargetPositions(i,1) + Params.Center(1); % add x-pos
            ReachRect([2,4]) = ReachRect([2,4]) + Params.ReachTargetPositions(i,2) + Params.Center(2); % add y-pos
            
            Screen('FillOval', Params.WPTR, ...
                cat(1,Params.AllPossibleTargetColor,Params.CursorColor)', ...
                cat(1,ReachRect,CursorRect)')
            
        end
        
        % instructed reach real target % draw
        ReachRect = Params.TargetRect; % centered at (0,0)
        ReachRect([1,3]) = ReachRect([1,3]) + ReachTargetPos(1) + Params.Center(1); % add x-pos
        ReachRect([2,4]) = ReachRect([2,4]) + ReachTargetPos(2) + Params.Center(2); % add y-pos
        
        Screen('FillOval', Params.WPTR, ...
            cat(1,Params.OutTargetColor,Params.CursorColor)', ...
            cat(1,ReachRect,CursorRect)')
        
        if Params.DrawVelCommand.Flag && TaskFlag>1,
            VelRect = Params.DrawVelCommand.Rect;
            VelRect([1,3]) =Params.Center(1); %VelRect([1,3]) + Params.Center(1);
            VelRect([2,4]) =Params.Center(2); %VelRect([2,4]) + Params.Center(2);
            x0 = mean(VelRect([1,3]));
            y0 = mean(VelRect([2,4]));
            xf = x0 + 1*Cursor.Vcommand(1);
            yf = y0 + 1*Cursor.Vcommand(2);
            Screen('FrameOval', Params.WPTR, [100,100,100], VelRect);
            Screen('DrawLine', Params.WPTR, [100,100,100], x0, y0, xf, yf, 3);
            xf = x0 + 1*Cursor.State(3);
            yf = y0 + 1*Cursor.State(4);
            Screen('FrameOval', Params.WPTR, [100,100,100], VelRect);
            Screen('DrawLine', Params.WPTR, [200,50,50], x0, y0, xf, yf, 3);
        end
        Screen('DrawingFinished', Params.WPTR);
        Screen('Flip', Params.WPTR);
        
        
    end
    class_angle=atan2d(Cursor.ClassifierState(3),Cursor.ClassifierState(2));
    if class_angle<0
        class_angle=360+class_angle;
    end
    Index=find(min(abs(Params.ReachTargetAngles-class_angle))==abs(Params.ReachTargetAngles-class_angle));
    FixedArrowx=Cursor.State(3);
    FixedArrowy=Cursor.State(4);
      
end % Reach Target Loop


%% Give neurofeedback for selected target
tstart  = GetSecs;
Data.Events(end+1).Time = tstart;
Data.Events(end).Str  = 'Neurofeedback';

while TotalTime < Params.DecisionTime+Params.NeurofeedbackTime
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
            
            CursorRect = Params.CursorRect;
            CursorRect([1,3]) = CursorRect([1,3]) + Cursor.State(1) + Params.Center(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + Cursor.State(2) + Params.Center(2); % add y-pos
            Data.CursorState(:,end+1) = Cursor.State;
            Data.ClassifierState(:,end+1) = Cursor.ClassifierState;
            
            % show all possible reach targets in grey
            for i=1:length(Params.ReachTargetAngles)
                % reach targets % draw
                ReachRect = Params.TargetRect; % centered at (0,0)
                ReachRect([1,3]) = ReachRect([1,3]) + Params.ReachTargetPositions(i,1) + Params.Center(1); % add x-pos
                ReachRect([2,4]) = ReachRect([2,4]) + Params.ReachTargetPositions(i,2) + Params.Center(2); % add y-pos
                
                Screen('FillOval', Params.WPTR, ...
                    cat(1,Params.AllPossibleTargetColor,Params.CursorColor)', ...
                    cat(1,ReachRect,CursorRect)')
                
            end
            
            % instructed reach real target % draw
            ReachRect = Params.TargetRect; % centered at (0,0)
            ReachRect([1,3]) = ReachRect([1,3]) + ReachTargetPos(1) + Params.Center(1); % add x-pos
            ReachRect([2,4]) = ReachRect([2,4]) + ReachTargetPos(2) + Params.Center(2); % add y-pos
            
            Screen('FillOval', Params.WPTR, ...
                cat(1,Params.OutTargetColor,Params.CursorColor)', ...
                cat(1,ReachRect,CursorRect)')
            
            % Real Selected reach target % draw
            SeletcedTargetPos= Params.ReachTargetPositions(Index,:);
            ReachRect = Params.TargetRect; % centered at (0,0)
            ReachRect([1,3]) = ReachRect([1,3]) + SeletcedTargetPos(1) + Params.Center(1); % add x-pos
            ReachRect([2,4]) = ReachRect([2,4]) + SeletcedTargetPos(2) + Params.Center(2); % add y-pos
            Screen('FillOval', Params.WPTR, ...
                cat(1,Params.InTargetColor,Params.CursorColor)', ...
                cat(1,ReachRect,CursorRect)')
            
            if Params.DrawVelCommand.Flag && TaskFlag>1,
                VelRect = Params.DrawVelCommand.Rect;
                VelRect([1,3]) =Params.Center(1); %VelRect([1,3]) + Params.Center(1);
                VelRect([2,4]) =Params.Center(2); %VelRect([2,4]) + Params.Center(2);
                x0 = mean(VelRect([1,3]));
                y0 = mean(VelRect([2,4]));
                xf = x0 + 1*FixedArrowx;
                yf = y0 + 1*FixedArrowy;
                Screen('FrameOval', Params.WPTR, [100,100,100], VelRect);
                Screen('DrawLine', Params.WPTR, [100,100,100], x0, y0, xf, yf, 3);
                xf = x0 + 1*FixedArrowx;
                yf = y0 + 1*FixedArrowy;
                Screen('FrameOval', Params.WPTR, [100,100,100], VelRect);
                Screen('DrawLine', Params.WPTR, [200,50,50], x0, y0, xf, yf, 3);
            end
            Screen('DrawingFinished', Params.WPTR);
            Screen('Flip', Params.WPTR);
          
        end

    end
    
end % Instructed Neurofeedback Loop

%% Completed Trial - Give Feedback

% output update times
if Params.Verbose,
    fprintf('      Screen Update: Goal=%iHz, Actual=%.2fHz (+/-%.2fHz)\n',...
        Params.ScreenRefreshRate,mean(1./dt_vec),std(1./dt_vec))
    fprintf('      System Update: Goal=%iHz, Actual=%.2fHz (+/-%.2fHz)\n',...
        Params.UpdateRate,mean(1./dT_vec),std(1./dT_vec))
end

% output feedback
if (ReachTargetPos(1)==SeletcedTargetPos(1))&&(ReachTargetPos(2)==SeletcedTargetPos(2))
    fprintf('SUCCESS\n')
    % reset cursor and classifier
    Cursor.State = [0,0,0,0,1]';
    Cursor.ClassifierState = [0,0,0]';
    
    if Params.FeedbackSound,
        sound(Params.RewardSound,Params.RewardSoundFs)
    end
else,
    fprintf('NO SUCCESS\n')
    % reset cursor and classifier
    Cursor.State = [0,0,0,0,1]';
    Cursor.ClassifierState = [0,0,0]';
    
    if Params.FeedbackSound,
        sound(Params.ErrorSound,Params.ErrorSoundFs)
    end
    WaitSecs(Params.ErrorWaitTime);
end

end % RunTrial




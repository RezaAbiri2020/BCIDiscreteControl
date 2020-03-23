function KF = UpdateCursor(Params,Neuro,TaskFlag,TargetPos,KF)
% KF = UpdateCursor(Params,Neuro)
% Updates the state of the cursor using the method in Params.ControlMode
%   1 - position control
%   2 - velocity control
%   3 - kalman filter position & velocity
% 	4 - kalman filter velocity
%
% Cursor - global structure with state of cursor [px,py,vx,vy,1]
% TaskFlag - 0-imagined mvmts, 1-clda, 2-fixed decoder
% TargetPos - x- and y- coordinates of target position. used to assist
%   cursor to target
% KF - kalman filter struct containing matrices A,W,P,C,Q

global Cursor

% query optimal control policy
%Vopt = OptimalCursorUpdate(Params,TargetPos);

if TaskFlag==1, % do nothing during imagined movements
    return;
end

% find vx and vy using control scheme
switch Cursor.ControlMode,
    case 1, % Move to Mouse
        X0 = Cursor.State;
        [x,y] = GetMouse();
        vx = ((x-Params.Center(1)) - Cursor.State(1))*Params.UpdateRate;
        vy = ((y-Params.Center(2)) - Cursor.State(2))*Params.UpdateRate;
        
        % update cursor
        Cursor.State(1) = x - Params.Center(1);
        Cursor.State(2) = y - Params.Center(2);
        Cursor.State(3) = vx;
        Cursor.State(4) = vy;
        
        % Update Intended Cursor State
        X = Cursor.State;
        Vcom = (X(1:2) - X0(1:2))*Params.UpdateRate; % effective velocity command
        Cursor.IntendedState = Cursor.State; % current true position
        Cursor.IntendedState(3:4) = Vopt; % update vel w/ optimal vel
        
    case 2, % Use Mouse Position as a Velocity Input (Center-Joystick)
        X0_Cursor = Cursor.State; % initial state, useful for assistance
        X0_Class = Cursor.ClassifierState;
        [x,y] = GetMouse();
        vx = Params.Gain * (x - Params.Center(1));
        vy = Params.Gain * (y - Params.Center(2));
        
        % the coordination is y positive to the bottom
        % So, the angles are in clockwise mode
        class_angle=atan2d(vy,vx);
        if class_angle<0
            class_angle=360+class_angle;
        end 
        
        Index=find(min(abs(Params.ReachTargetAngles-class_angle))==abs(Params.ReachTargetAngles-class_angle));
        % since the angles are in clockwise mode
        % no minus sign we need for y direction
        Magnifier=50;
        vx=Magnifier*cosd(Params.ReachTargetAngles(Index(1)));
        vy=Magnifier*sind(Params.ReachTargetAngles(Index(1)));
           
        % update cursor state
        Cursor.State(1) = X0_Cursor(1) + vx/Params.UpdateRate;
        Cursor.State(2) = X0_Cursor(2) + vy/Params.UpdateRate;
        Cursor.State(3) = vx;
        Cursor.State(4) = vy;
        
        % Update the classifier states
        % the chosen class
        Cursor.ClassifierState(1)=Params.ReachTargetAngles(Index(1));
        % the cumsum of previous results to current time
        Cursor.ClassifierState(2)=X0_Class(2)+vx;
        Cursor.ClassifierState(3)=X0_Class(3)+vy;
        
    case {3,4}, % Kalman Filter Input
        X0_Cursor = Cursor.State; % initial state, useful for assistance
        X0_Class = Cursor.ClassifierState;
        
        Features = Neuro.MaskedFeatures;
        Target_angle=Target_Classifier(Features,Params);
        % if the angles are in counterclockwise
        Magnifier=10;
        vx=Magnifier*cosd(Target_angle);
        vy=-Magnifier*sind(Target_angle);
           
        % update cursor state
        Cursor.State(1) = X0_Cursor(1) + vx/Params.UpdateRate;
        Cursor.State(2) = X0_Cursor(2) + vy/Params.UpdateRate;
        Cursor.State(3) = vx;
        Cursor.State(4) = vy;
        
        % Update the classifier states
        % the chosen class
        Cursor.ClassifierState(1)=Params.ReachTargetAngles(Index(1));
        % the cumsum of previous results to current time
        Cursor.ClassifierState(2)=X0_Class(2)+vx;
        Cursor.ClassifierState(3)=X0_Class(3)+vy;
        
        
end

% update effective velocity command for screen output
try,
    Vcom=[vx;vy];
    Cursor.Vcommand = Vcom;
catch,
    Cursor.Vcommand = [0,0];
end

% bound cursor position to size of screen
pos = Cursor.State(1:2)' + Params.Center;
pos(1) = max([pos(1),Params.ScreenRectangle(1)+10]); % x-left
pos(1) = min([pos(1),Params.ScreenRectangle(3)-10]); % x-right
pos(2) = max([pos(2),Params.ScreenRectangle(2)+10]); % y-left
pos(2) = min([pos(2),Params.ScreenRectangle(4)-10]); % y-right
Cursor.State(1) = pos(1) - Params.Center(1);
Cursor.State(2) = pos(2) - Params.Center(2);

end % UpdateCursor
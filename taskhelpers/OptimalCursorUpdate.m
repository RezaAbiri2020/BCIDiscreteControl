function Vopt = OptimalCursorUpdate(Params,TargetPos)
% Vopt = OptimalCursorUpdate(Params,TargetPos)
% computes optimal velocity update
% used to assist cursor to target and for building intended kinematics for
% decoder calibration
% 
% Cursor - global structure with state of cursor [px,py,vx,vy,1]
% TargetPos - x- and y- coordinates of target position. used to assist
%   cursor to target


global Cursor

% optimal velocity calc
switch Params.OptimalVeloctityMode,
    case 1, % refit (vector to target)
        if ~exist('TargetPos','var'), % optimal is to not move
            err_vec = [0;0];
            norm_evec = 0;
        else,
            err_vec = TargetPos(:) - Cursor.State(1:2); % pos error vector
            norm_evec = norm(err_vec);
        end
        
        if norm_evec==0, % set opt vel to [0,0]
            Vopt = [0;0];
        elseif norm_evec<=Params.TargetSize*.75, % in target
            Vopt = 20 * err_vec(:) / norm_evec; % slow
        else,
            Vopt = 250 * err_vec(:) / norm_evec; % medium
        end
    case 2, % LQR
        if ~exist('TargetPos','var'),
            goal_state = Cursor.State(1:4);
        else,
            goal_state = cat(1,TargetPos(:),zeros(2,1));
        end
        u = -Params.CursorController.K*(Cursor.State(1:4) - goal_state);
        Vopt = u(3:4);
end

end % OptimalCursorUpdate
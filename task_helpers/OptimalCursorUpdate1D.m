function Vopt = OptimalCursorUpdate1D(Params,TargetPos)
% Vopt = OptimalCursorUpdate1D(Params,TargetPos)
% computes optimal velocity update
% used to assist cursor to target and for building intended kinematics for
% decoder calibration
% 
% Cursor - global structure with state of cursor [p,v,1]
% TargetPos - 1d- coordinates of target position. used to assist
%   cursor to target


global Cursor

% optimal velocity calc
if ~exist('TargetPos','var'), % optimal is to not move
    err_vec = 0;
    norm_evec = 0;
else,
    err_vec = TargetPos - Cursor.State(1); % pos error vector
    norm_evec = abs(err_vec);
end

if norm_evec==0, % set opt vel to [0,0]
    Vopt = 0;
elseif norm_evec<=Params.TargetSize*.75, % in target
    Vopt = 20 * err_vec / norm_evec; % slow
else,
    Vopt = 250 * err_vec / norm_evec; % medium
end

end % OptimalCursorUpdate
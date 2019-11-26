function Params = LoadKF2dDynamics(Params, G, t, a, w)
% Params = LoadKF2dDynamics(Params, G, t, a, w)
% sets up kalman filter matrices
% G - cursor gain
% t - time bin size (btw cursor updates)
% a - velocity_t ~ a * velocity_t-1
% w - noise on x and y velocity

Params.KF.A = [...
    1	0	G*t	0	0;
    0	1	0	G*t	0;
    0	0	a	0	0;
    0	0	0	a	0;
    0	0	0	0	1];
Params.KF.W = [...
    0	0	0	0	0;
    0	0	0	0	0;
    0	0	w	0	0;
    0	0	0	w	0;
    0	0	0	0	0];
Params.KF.P = eye(5);
Params.KF.InitializationMode = Params.InitializationMode; % 1-imagined mvmts, 2-shuffled
if Params.ControlMode==4, % set velocity kalman filter flag
    Params.KF.VelKF = true;
else,
    Params.KF.VelKF = false;
end
    
end % LoadKF2dDynamics
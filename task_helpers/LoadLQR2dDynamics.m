function Params = LoadLQR2dDynamics(Params, G, t, a)
% Params = LoadLQR2dDynamics(Params, G, t, a)
% sets matrices for lqr controller to determine optimal cursor velocities
% G - cursor gain
% t - time bin size (btw cursor updates)
% a - velocity_t ~ a * velocity_t-1

Params.CursorController.A = [...
    1	0	G*t	0;
    0	1	0	G*t;
    0	0	a	0;
    0	0	0	a];
Params.CursorController.B = [...
    0   0   0   0
    0   0   0   0
    0   0   1   0
    0   0   0   1];
qp = 2.5e0;
qv = 0;
Params.CursorController.Q = [...
    qp  0   0   0
    0   qp  0   0
    0   0   qv  0
    0   0   0   qv];
rp = 1e0;
rv = 3e0;
Params.CursorController.R = [...
    rp  0   0   0
    0   rp  0   0
    0   0   rv  0
    0   0   0   rv];
Params.CursorController.K = dlqr(...
    Params.CursorController.A,Params.CursorController.B,...
    Params.CursorController.Q,Params.CursorController.R);

end % LoadLQR2dDynamics
function traj = GenerateCursorTraj1D(startpos,endpos,time,Params)
% function GenerateCursorTraj(startpos,endpos,time,Params)
% generates trajectory with gaussian velocity profile
% 
% startpos - starting position
% endpos - ending position
% time - total time to get from startpos to endpos

% generic 1D trajectory
x1d = linspace(-.5,.5,time*Params.ScreenRefreshRate);
pos1d = normcdf(x1d,0,.2);

% stretch and project trajectory to match distance and direction
traj = startpos + (endpos-startpos) * pos1d;
traj = traj(:);

end % GenerateCursorTraj1D
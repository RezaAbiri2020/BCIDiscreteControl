function traj = GenerateCursorTraj(startpos,endpos,time,Params)
% function GenerateCursorTraj(startpos,endpos,time,Params)
% generates trajectory with gaussian velocity profile
% 
% startpos - starting position
% endpos - ending position
% time - total time to get from startpos to endpos

% important params
dist = sqrt(sum(endpos-startpos).^2);
uvec = [endpos(1)-startpos(1),endpos(2)-startpos(2)] / dist;

% generic 1D trajectory
x1d = linspace(-.5,.5,time*Params.UpdateRate);
pos1d = normcdf(x1d,0,.2);

% stretch and project trajectory to match distance and direction
xpos = startpos(1) + (endpos(1)-startpos(1)) * pos1d;
ypos = startpos(2) + (endpos(2)-startpos(2)) * pos1d;

% % append start and end positions for smoothness
% xpos = [startpos(1) xpos endpos(1)];
% ypos = [startpos(2) ypos endpos(2)];

% final output
traj = [xpos' ypos'];

end % GenerateCursorTraj
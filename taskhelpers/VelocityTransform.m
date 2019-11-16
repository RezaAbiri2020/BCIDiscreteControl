function [Vx,Vy] = VelocityTransform(Vx,Vy,Gain)
% [Vx,Vy] = VelocityTransform(Vx,Vy,Gain)
% Applies a sigmoid function to decoded velocity
% new_speed = Gain * (50 / (1 + exp( -(old_speed-20)/6) ) );
% 
% Inputs:
% 	Vx - x velocity (px / bin)
% 	Vy - y velocity (px / bin)
% 	Gain - scalar multiplier
% 
% Outputs:
% 	Vx - transformed x velocity (px / bin)
% 	Vy - transformed y velocity (px / bin)

% deal with inputs
if ~exist('Gain','var'),
	Gain = 1;
end

% compute new velocities
old_speed = norm([Vx,Vy]);
new_speed = Gain * (50 / (1 + exp( -(old_speed-20)/6) ) );
Vx = Vx * new_speed / old_speed;
Vy = Vy * new_speed / old_speed;

end % VelocityTransform
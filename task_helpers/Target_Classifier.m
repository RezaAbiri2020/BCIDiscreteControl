
function Target_angle=Target_Classifier(Features,Params)

% the output should be an angle in degree
% Example: Target_angles: (0:45:315); 
% the number of target is even number
% % by assuming angles are in counterclockwise
Target_angle=45*(randi(length(Params.ReachTargetAngles))-1);


end 
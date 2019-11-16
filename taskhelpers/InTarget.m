function TargetID = InTarget(Cursor,Targets,TargetSize)
% function inFlag = InTarget(Cursor,Targets,TargetSize)
% function to tell if cursor is inside any of the targets
% 
% Inputs:
%   Cursor - includes .State (posx and posy)
%   Targets - Matrix of target positions (NumTargets x 2]
%   TargetSize - length of target
% 
% Outputs:
%   TargetID - index of target that cursor is in, (0 if not in any)

TargetID = find(...
    Cursor.State(1)>Targets(:,1)-TargetSize & ...
    Cursor.State(1)<Targets(:,1)+TargetSize & ...
    Cursor.State(2)>Targets(:,2)-TargetSize & ...
    Cursor.State(2)<Targets(:,2)+TargetSize , 1);
if isempty(TargetID), TargetID = 0; end

end % InTarget


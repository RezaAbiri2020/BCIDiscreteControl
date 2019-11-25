function TargetID = InTargetKeyboard(Cursor,Targets)
% function inFlag = InTargetKeyboard(Cursor,Targets)
% function to tell if cursor is inside any of the targets
% 
% Inputs:
%   Cursor - includes .State (posx and posy)
%   Targets - Matrix of target windows [NumTargets x 4]
% 
% Outputs:
%   TargetID - index of target that cursor is in, (0 if not in any)

TargetID = find(...
    Cursor.State(1)>Targets(:,1) & ...
    Cursor.State(1)<Targets(:,3) & ...
    Cursor.State(2)>Targets(:,2) & ...
    Cursor.State(2)<Targets(:,4), 1);
if isempty(TargetID), TargetID = 0; end

end % InTarget


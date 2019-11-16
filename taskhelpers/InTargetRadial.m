function TargetID = InTargetRadial(Cursor,TargetsVerts,InnerCircleRadius)
% function inFlag = InTargetRadial(Cursor,TargetsVerts,InnerCircleRadius)
% function to tell if cursor is inside any of the targets
% 
% Inputs:
%   Cursor - includes .State (posx and posy)
%   TargetsVerts - Cell array of vertices defining each target
%     cell is length: # of targets
%     each cell is a matrix: rows are vertices, w/ x and y as cols
%   InnerCircleRadius - excludes selections within radius
% 
% Outputs:
%   TargetID - index of target that cursor is in, (0 if not in any)

TargetID = 0;
for i=1:length(TargetsVerts),
    in1 = inpolygon(Cursor.State(1),Cursor.State(2),...
        TargetsVerts{i}(:,1),TargetsVerts{i}(:,2));
    in2 = norm(Cursor.State(1:2))<InnerCircleRadius;
    in = in1 & ~in2;
    if in, TargetID = i; end
end

end % InTarget


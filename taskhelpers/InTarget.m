function inFlag = InTarget(Cursor,Target,TargetSize)
% function inFlag = InTarget(Cursor,Target,TargetSize)
% function to tell if cursor is inside of target
cursor_ctr = real(Cursor.State(1:2));
target_ctr = Target;
dist = norm(cursor_ctr(:)-target_ctr(:));
inFlag = dist<TargetSize;
end % InTarget


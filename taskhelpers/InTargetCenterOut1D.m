function inFlag = InTargetCenterOut1D(Cursor,Target,TargetSize)
% function inFlag = InTargetCenterOut1D(Cursor,Target,TargetSize)
% function to tell if cursor is inside of target
cursor_ctr = Cursor.State(1);
target_ctr = Target;
dist = abs(cursor_ctr-target_ctr);
inFlag = dist<TargetSize;
end % InTargetCenterOut1D


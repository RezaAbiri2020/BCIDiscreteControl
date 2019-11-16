function out = CheckPause
% function to check if the key 'p' was pressed,
% if so, pause the experiment
[~, ~, keyCode, ~] = KbCheck;
if keyCode(KbName('p'))==1,
    out = true;
else,
    out = false;
end

end % CheckPause
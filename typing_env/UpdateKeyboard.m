function [Params] = UpdateKeyboard(Params)
% function: Short description
%
% Extended description

p = inputParser;
p.addRequired('Params', @(x) isstruct(x) && isfield(x, 'Keyboard'))
p.CaseSensitive = false;
parse(p, Params)

Pos = Params.Keyboard.Pos;
switch Params.Keyboard.State.Mode
    case 'End'
        DrawText(Params, Params.Keyboard.State.SelectableText, Params.Keyboard.State.CurrentTargets)
    otherwise
        DrawText(Params, Params.Keyboard.State.SelectableText, Pos.TextTargets)
        DrawText(Params, join(Params.Keyboard.State.SelectedCharacters, '-'), ...
            Params.Keyboard.Pos.CharDisplay,  Params.Keyboard.Text.CharDisplayOpts{:})
        DrawText(Params, join(Params.Keyboard.State.SelectedWords, ' '), ...
            Params.Keyboard.Pos.WordDisplay,  Params.Keyboard.Text.WordDisplayOpts{:})
        if Params.Keyboard.ShowWordBox, DrawWordBox(Params, 'DrawTitle', false); end
        if ~isempty(Pos.F_Arrow), DrawArrow(Params, Pos.F_Arrow, 'R'); end
        if ~isempty(Pos.B_Arrow), DrawArrow(Params, Pos.B_Arrow, 'L'); end
end


end  % function

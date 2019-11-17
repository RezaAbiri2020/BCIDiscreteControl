function [Params] = UpdateKeyboard(Params)
% function: Short description
%
% Extended description

p = inputParser;
p.addRequired('Params', @(x) isstruct(x) && isfield(x, 'Keyboard'))
p.CaseSensitive = false;
parse(p, Params)

% switch Params.Keyboard.State.Mode
%     case 'Character'
%         % unnecessary, but ensures character state always shows charactrs
%         Params.Keyboard.State.SelectableText = Params.Keyboard.Text.CharacterSets;
%         Params.Keyboard.State.CurrentColor = Params.Keyboard.CharColor;
%     case 'Word'
%         Params.Keyboard.State.CurrentColor = Params.Keyboard.WordColor;
%     otherwise
%         Params.Keyboard.State.SelectableText = Params.Keyboard.Text.CharacterSets;
%         Params.Keyboard.State.CurrentColor = Params.Keyboard.CharColor;
% end

% Params = CheckKeys(Params);
% Params = MakeSelection(Params);
Pos = Params.Keyboard.Pos;
% Screen('FillRect', Params.WPTR, Params.Keyboard.State.CurrentColor, ...
%         Params.Keyboard.State.CurrentTargetEdges);
switch Params.Keyboard.State.Mode
case 'End'
    DrawText(Params, Params.Keyboard.State.SelectableText, Params.Keyboard.State.CurrentTargets)
otherwise
    DrawText(Params, Params.Keyboard.State.SelectableText, Pos.TextTargets)
    DrawText(Params, join(Params.Keyboard.State.SelectedCharacters, '-'), ...
            Params.Keyboard.Pos.CharDisplay,  Params.Keyboard.Text.CharDisplayOpts{:})
    DrawText(Params, join(Params.Keyboard.State.SelectedWords, ' '), ...
            Params.Keyboard.Pos.WordDisplay,  Params.Keyboard.Text.WordDisplayOpts{:})
    DrawWordBox(Params, 'DrawTitle', false);
    DrawArrow(Params, Pos.F_Arrow, 'R')
    DrawArrow(Params, Pos.B_Arrow, 'L')
end


end  % function

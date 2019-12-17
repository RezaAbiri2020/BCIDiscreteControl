function [Params] = UpdateKeyboard(Params)
% function: Short description
%
% Extended description

p = inputParser;
p.addRequired('Params', @(x) isstruct(x) && isfield(x, 'Keyboard'))
p.CaseSensitive = false;
parse(p, Params)

%%%
% Screen('Preference', 'TextRenderer', 0);

Pos = Params.Keyboard.Pos;
switch Params.Keyboard.State.Mode
    case 'End'
        DrawText(Params, Params.Keyboard.State.SelectableText, Params.Keyboard.State.CurrentTargets)
    otherwise
        if Params.DrawFormattedText,
            DrawText(Params, Params.Keyboard.State.SelectableText, Pos.TargetEdges')
            chars = Params.Keyboard.State.SelectedCharacters;
            chars{end+1} = '_'; % add _, repl 2space w/ 1space, - w/ ''
            char_str = strrep(strrep(join(chars, ''), '  ', ' '), '-','');
            DrawText(Params, char_str, ...
                Params.Keyboard.Pos.CharDisplayEdges, ...
                Params.Keyboard.Text.CharDisplayOpts{:})
            DrawText(Params, join(Params.Keyboard.State.SelectedWords, ' '), ...
                Params.Keyboard.Pos.WordDisplay,  Params.Keyboard.Text.WordDisplayOpts{:})
        else,
            DrawText(Params, Params.Keyboard.State.SelectableText, Pos.TextTargets)
            DrawText(Params, join(Params.Keyboard.State.SelectedCharacters, '-'), ...
                Params.Keyboard.Pos.CharDisplay,  Params.Keyboard.Text.CharDisplayOpts{:})
            DrawText(Params, join(Params.Keyboard.State.SelectedWords, ' '), ...
                Params.Keyboard.Pos.WordDisplay,  Params.Keyboard.Text.WordDisplayOpts{:})
        end
        if Params.Keyboard.ShowWordBox, DrawWordBox(Params, 'DrawTitle', false); end
        if ~isempty(Pos.F_Arrow), DrawArrow(Params, Pos.F_Arrow, 'R'); end
        if ~isempty(Pos.B_Arrow), DrawArrow(Params, Pos.B_Arrow, 'L'); end
end

%%%
% Screen('Preference', 'TextRenderer', 1);
end  % function

function [ Params ] = UpdateState(Params, new_state)
% SetState: Set the keyboard state and save state history
%
% Extended description

% Save state history
Params.Keyboard.History.State = [Params.Keyboard.History.State, Params.Keyboard.State];
current_state = Params.Keyboard.State;
switch new_state
    case 'Character'
        switch current_state.Mode
            case 'Character'
                Params.Keyboard.State.Mode = 'Character';
                Params = MatchWords(Params);
                Params = GetNextWordSet(Params);
            case 'Word'
                Params.Keyboard.State.Mode = 'Character';
                Params.Keyboard.State.SelectedCharacters = {};
                Params.Keyboard.State.WordBoxColor = Params.Keyboard.WordColor;
                Params = MatchWords(Params);
                Params = GetNextWordSet(Params);
        end
        Params.Keyboard.State.SelectableText = Params.Keyboard.Text.CharacterSets;
        Params.Keyboard.State.CurrentColor = Params.Keyboard.CharColor;
    case 'Word'
        Params.Keyboard.State.Mode           = 'Word';
        Params.Keyboard.State.WordBoxColor   = Params.Keyboard.NextWordColor;
        Params.Keyboard.State.SelectableText = Params.Keyboard.State.NextWordSet;
        Params.Keyboard.State.CurrentColor   = Params.Keyboard.WordColor;
        Params = GetNextWordSet(Params);
    case 'End'
        switch current_state.Mode
            case 'End'
                ExperimentStop(Params, 1);
            otherwise
                Params.Keyboard.State.Mode               = 'End';
                Params.Keyboard.State.CurrentTargets     = Params.Keyboard.End.Targets;
                Params.Keyboard.State.CurrentTargetEdges = Params.Keyboard.End.TargetEdges;
                Params.Keyboard.State.CurrentColor       = Params.Keyboard.End.Color;
                Params.Keyboard.State.SelectableText     = Params.Keyboard.End.TargetLabels;
                Params.Keyboard.State.SelectedCharacters = {};
                Params.Keyboard.State.SelectedWords      = {};
        end
    case 'Reset'
        Params.Keyboard.State = Params.Keyboard.History.InitState;
        Params.Keyboard.History.State = {};
end

% Override target color
Params.TargetsColor        = Params.Keyboard.State.CurrentColor; % all targets

end  % SetState

function [Params] = MakeSelection(Params)
% [Params] = MakeSelection(Params)
%
% Extended description

switch Params.Keyboard.State.Mode
    case 'Character'
        if any(Params.Keyboard.State.InText)
            Params.Keyboard.N_Back = 0;
            % dbs added undo, space, and backspace
            char = Params.Keyboard.State.SelectableText(Params.Keyboard.State.InText);
            switch char{1},
                case 'SPACE',
                    Params.Keyboard.State.SelectedCharacters = ...
                        [Params.Keyboard.State.SelectedCharacters, {' '}];
                    Params = UpdateState(Params, 'Character');
                case {'UNDO', 'DELETE'}, % like a back arrow
                    Params.Keyboard.N_Back = Params.Keyboard.N_Back + 1;
                    if length(Params.Keyboard.History.State) >= 1 && Params.Keyboard.N_Back < Params.Keyboard.MaxUndo,
                        Params.Keyboard.History.State{end}.SelectedCharacters = ...
                            Params.Keyboard.History.State{end}.SelectedCharacters(1:end-1);
                        Params.Keyboard.State = Params.Keyboard.History.State{end};
                        Params.Keyboard.History.State = Params.Keyboard.History.State(1:end-1);
                    end % if length(History) >= 1
                case {'START OVER'}, % reset
                    Params.Keyboard.N_Back = 0;
                    Params = UpdateState(Params, 'Reset');
                otherwise,
                    Params.Keyboard.State.SelectedCharacters = [Params.Keyboard.State.SelectedCharacters, char];
                    Params = UpdateState(Params, 'Character');
            end
            
        elseif any(Params.Keyboard.State.InArrow)
            switch Params.Keyboard.Pos.ArrowLabels{Params.Keyboard.State.InArrow}
                case 'Forward'
                    Params.Keyboard.N_Back = 0;
                    Params = UpdateState(Params, 'Word');
                case 'Back'
                    Params.Keyboard.N_Back = Params.Keyboard.N_Back + 1;
                    if length(Params.Keyboard.History.State) >= 1 && Params.Keyboard.N_Back < Params.Keyboard.MaxUndo
                        Params.Keyboard.History.State{end}.SelectedCharacters = ...
                            Params.Keyboard.History.State{end}.SelectedCharacters(1:end-1);
                        Params.Keyboard.State = Params.Keyboard.History.State{end};
                        Params.Keyboard.History.State = Params.Keyboard.History.State(1:end-1);
                    else
                        Params = UpdateState(Params, 'End');
                    end % if length(History) >= 1
            end
        end
    case 'Word'
        if any(Params.Keyboard.State.InText)
            Params.Keyboard.N_Back = 0;
            Params.Keyboard.State.SelectedWords = [Params.Keyboard.State.SelectedWords, ...
                Params.Keyboard.State.SelectableText(Params.Keyboard.State.InText)];
            % Reset to 0-character state
            Params = UpdateState(Params, 'Character');
        elseif any(Params.Keyboard.State.InArrow)
            switch Params.Keyboard.Pos.ArrowLabels{Params.Keyboard.State.InArrow}
                case 'Forward'
                    Params.Keyboard.N_Back = 0;
                    Params = UpdateState(Params, 'Word');
                case 'Back'
                    Params.Keyboard.N_Back = Params.Keyboard.N_Back + 1;
                    if length(Params.Keyboard.History.State) >= 1 && Params.Keyboard.N_Back < Params.Keyboard.MaxUndo
                        Params.Keyboard.State = Params.Keyboard.History.State{end};
                        Params.Keyboard.History.State = Params.Keyboard.History.State(1:end-1);
                    else
                        Params = UpdateState(Params, 'End');
                    end % if length(History) >= 1
            end
        end
    case 'End'
        switch Params.Keyboard.End.TargetLabels{Params.Keyboard.State.InCurrent}
            case 'CONTINUE'
                Params.Keyboard.N_Back = 0;
                Params.Keyboard.State = Params.Keyboard.History.State{end};
                Params.Keyboard.History.State = Params.Keyboard.History.State(1:end-1);
            case 'STOP'
                ExperimentStop(Params, 1);
            case 'Reset'
                Params.Keyboard.N_Back = 0;
                Params = UpdateState(Params, 'Reset');
        end % switch arrow label
end % switch Params.Keyboard.State.Mode

end  % MakeSelection

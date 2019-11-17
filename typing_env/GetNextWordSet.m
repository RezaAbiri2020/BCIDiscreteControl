function [ Params ] = GetNextWordSet( Params )
% GetNextWordSet: Short description
%
% Extended description

% TODO: add other selection methods
% TODO: update words based on state


if length(Params.Keyboard.State.WordMatches) >= Params.Keyboard.State.NText
    % BUG: account for length == NText
    ix_next_words = Params.Keyboard.State.WordMatches(1:Params.Keyboard.State.NText);
    Params.Keyboard.State.NextWordSet = Params.Keyboard.Text.WordSet(ix_next_words);
    % remove current words from matches list
    Params.Keyboard.State.WordMatches = Params.Keyboard.State.WordMatches(Params.Keyboard.State.NText+1:end);
else
    ix_next_words = Params.Keyboard.State.WordMatches;
    Params.Keyboard.State.NextWordSet = Params.Keyboard.Text.WordSet(ix_next_words);
    Params.Keyboard.State.NextWordSet(end+1:Params.Keyboard.State.NText) = {' '};
end

end  % GetNextWordSet

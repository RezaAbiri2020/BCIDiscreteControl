function [ Params ] = MatchWords( Params )
% [ Params ] = MatchWords( Params )

KP = Params.Keyboard;

n_char = length(KP.State.SelectedCharacters);
if n_char > 0
    if Params.DEBUG
        % keyboard;
    end
    word_len = cellfun(@length, KP.Text.WordSet(KP.State.WordMatches));
    KP.State.WordMatches(word_len < n_char) = [];
    current_matches = KP.Text.WordSet(KP.State.WordMatches);
    b_matches = false(length(current_matches), 1);
    for i_c = 1:length(KP.State.SelectedCharacters{n_char})
        t_char = {KP.State.SelectedCharacters{n_char}(i_c)};
        t_matches = cellfun(@(x) startsWith(x(n_char:end), t_char, 'IgnoreCase', true), current_matches);
        b_matches = or(b_matches, t_matches);
    end
    KP.State.WordMatches = KP.State.WordMatches(b_matches);
    t_matches = current_matches(b_matches);
    ix_match = SortWords(t_matches);
    KP.State.WordMatches = KP.State.WordMatches(ix_match);
else
    KP.State.WordMatches = 1:KP.Text.CorpusSize;
end
Params.Keyboard = KP;
end  % MatchWords

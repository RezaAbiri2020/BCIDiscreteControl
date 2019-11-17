function [ Params ] = DrawWordBox( Params, varargin)
% [ Params ] = DrawWordBox( Params )

p = inputParser;
p.addRequired('Params', @isstruct);
p.addOptional('DrawTitle', false, @islogical);
parse(p, Params, varargin{:});

KP = Params.Keyboard;
% Screen('FillRect', Params.WPTR, KP.Pos.WordBox.Color, KP.Pos.WordBox.Edges);
Screen('FillRect', Params.WPTR, KP.State.WordBoxColor, KP.Pos.WordBox.Edges);
words = KP.State.NextWordSet;
n_words = length(words);
pos = KP.Pos.WordBox.FirstEntry;
for i_w = 1:n_words
    DrawText(Params, words(i_w), pos, KP.Text.WordBox.TextOpts{:});
    pos = pos + KP.Pos.WordBox.WordSpacing;
end


Params.Keyboard = KP;
end  % DrawWordBox

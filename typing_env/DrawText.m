function DrawText(Params, Text, Positions, varargin)
% DrawText(Params, Text, Positions)
% Draw each element in Text at its corresponding Position

p = inputParser;
p.addRequired('Params', @isstruct)
p.addRequired('Text', @iscellstr)
p.addRequired('Positions', @(x) ndims(x)==2)
p.addOptional('FontSize', 24, @isnumeric)
p.addOptional('Offset', [9, 8], @isnumeric)
p.addOptional('Color', [0, 0, 0], @isnumeric)
p.CaseSensitive = false;
parse(p, Params, Text, Positions, varargin{:})

Screen('TextSize', Params.WPTR, p.Results.FontSize);
Screen('TextStyle', Params.WPTR, 1);
x_offset = p.Results.Offset(1);
y_offset = p.Results.Offset(2);

% if displaying selected text
if size(Positions,1) == 1,
    wrap_len = 80;
else,
    wrap_len = 8;
end

for i=1:length(Text)
    if Params.DrawFormattedText == true,
        DrawFormattedText(Params.WPTR, Text{i}, ...
            'centerblock', 'center', p.Results.Color, wrap_len, [], [], ...
            [], [], Positions(i,:));
    else,
        Screen('DrawText', Params.WPTR, Text{i}, Positions(i, 1) - x_offset * length(Text{i}), Positions(i, 2) - y_offset, p.Results.Color);
    end
end

end  % DrawText

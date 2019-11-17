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
for i=1:length(Text)
    Screen('DrawText', Params.WPTR, Text{i}, Positions(i, 1) - x_offset * length(Text{i}), Positions(i, 2) - y_offset, p.Results.Color);
end

end  % DrawText

function DrawArrow(Params, tip, direction, varargin)
% DrawArrow(tip, direction, varargin)
% Draw an arrow pointing left or right

p = inputParser;
p.addRequired('Params', @isstruct)
p.addRequired('tip', @(x) numel(x)==2)
p.addRequired('direction', @(x) x=='L' || x=='R')
p.addOptional('HeadSize', 30, @isnumeric)
p.addOptional('ShaftLength', 100, @isnumeric)
p.addOptional('Color', @isnumeric)
p.addOptional('Stroke', 3, @isnumeric)
p.addOptional('StrokeColor', [0, 0, 0, 0], @isnumeric)
p.CaseSensitive = false;
parse(p, Params, tip, direction, varargin{:})

head   = tip; % coordinates of head
width  = p.Results.HeadSize;           % width of arrow head
shaft  = p.Results.ShaftLength;
color = choose_color(direction);

points = [ [0, 0];            % vertex
           [width, width];   % left corner
           [width, width/2]; % head top back edge
           [shaft, width/2]; % shaft top corner
           [shaft, -width/2]; % shaft bottom corner
           [width, -width/2]; % head bottom back edge
           [width, -width];   % right corner
          ];
switch direction
    case 'R'
        points = head - points;
    case 'L'
        points = head + points;
end

Screen('FillPoly', Params.WPTR, color, points);
if p.Results.Stroke > 0
    Screen('FramePoly', Params.WPTR, p.Results.StrokeColor, points, p.Results.Stroke);
end

% Helper functions
    function c = choose_color(str_direction)
        switch str_direction
            case 'R'
                c = [0, 255, 0];
            case 'L'
                c = [255, 0, 0];
        end
    end % choose_color

end  % function

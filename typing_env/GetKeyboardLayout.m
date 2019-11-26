function Params = GetKeyboardLayout(Params)
% Params = GetKeyboardLayout(Params)

% initialize
Params.ReachTargetPositions = [];
Params.ReachTargetWindows   = [];
Params.ReachTargetText      = {};
Params.ReachTargetColors    = [];

% translate keyboard
keyboard_x = 0;
keyboard_y = 50;

% 5 W's + how questions
height = 30;
width = 45;
top_left = [-6, -6];
text = {' How ',' What '
    ' When ',' Where '
    ' Who ',' Why '};
color = [148, 242, 233];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% prepositions
height = 30;
width = 45;
top_left = [-4, -6];
text = {' And ',' But ',' Can ',' Could ',' For '
    ' From ',' That ',' The ',' There ',' This '
    ' To ',' Was ',' Will ',' With ',' Would '};
color = [235, 187, 237];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% misc words
height = 30;
width = 45;
top_left = [+1, -6];
text = {' Are ',' Come ',' Did ',' Does '
    ' Get ',' Had ',' Have ','Is'
    ' No ',' Need ',' Put ',' Say '
    '',' Take ', ' Think ', ' Want '};
color = [189, 247, 139];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% pronouns
height = 30;
width = 45;
top_left = [-6, -3];
text = {' I ',' I''m ', ''
    ' Me ',' My ',''
    ' You ',' Your ',''
    ' He ',' Him ',' His '
    ' She ',' Her ',''
    ' It ',' We ',''
    ' They ',' Their ',' Them '};
color = [240, 226, 173];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% contractions
height = 30;
width = 45;
top_left = [-4, -3];
text = {' Can''t '
    ' Don''t '
    ' Not '};
color = [255, 255, 255];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% vowels
height = 48;
width = 45;
top_left = [-3, -2];
text = {'A'
    'E'
    'I'
    'O'
    'U'};
color = [242, 247, 94];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y + 22;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% Consonants
height = 48;
width = 45;
top_left = [-2, -2];
text = {'B','C','D','UNDO',''
    'F','G','H','SPACE',''
    'J','K','L','M','N'
    'P','Qu','R','S','T'
    'V','W','X','Y','Z'};
color = [243, 245, 196];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y + 22;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% misc words
height = 30;
width = 45;
top_left = [+2, -2];
text = {' Please ',' OK ',' Thanks '};
color = [209, 145, 227];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% misc words
height = 30;
width = 45;
top_left = [+2, -1];
text = {' Hold On ','START OVER', 'DELETE'
    '','',' I''m Done '};
color = [252, 240, 162];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% suffixes + heart
height = 30;
width = 45;
top_left = [+3, 0];
text = {' <3 ',''
    '. ','-ed '
    '','-ing '
    '','-s '};
color = [255, 255, 255];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% punctuation keys
height = 30;
width = 20;
top_left = [+4, +2];
text = {', ','? '
    '! ',''''
    ': ','$ '};
color = [255, 255, 255];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x + 75;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% more right keys
height = 30;
width = 45;
top_left = [+4, +4];
text = {' Msg Code '};
color = [242, 247, 94];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% number keys
height = 30;
width = 42;
top_left = [-5, +5];
text = {'1','2','3','4','5','6','7','8','9','0'};
color = [209, 145, 227];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 8;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x - 55;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% yes
height = 30;
width = 42;
top_left = [-6, +5];
text = {' YES '};
color = [85, 148, 77];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 8;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x - 55;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% no
height = 30;
width = 42;
top_left = [+5, +5];
text = {' NO '};
color = [201, 64, 54];
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 8;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        if isempty(text{i,ii}), continue; end
        x = x_sp*(top_left(1) + (ii-1)) + keyboard_x - 55;
        y = y_sp*(top_left(2) + (i-1)) + keyboard_y;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
        Params.ReachTargetColors(end+1,:)   = color;
    end
end

% number of targets
Params.NumReachTargets = size(Params.ReachTargetPositions, 1);

end % GetKeyboardLayout
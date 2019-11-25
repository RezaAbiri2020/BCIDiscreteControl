function Params = GetKeyboardLayout(Params)
% Params = GetKeyboardLayout(Params)

% initialize
Params.ReachTargetPositions = [];
Params.ReachTargetWindows   = [];
Params.ReachTargetText      = {};

% top rows
height = 30;
width = 45;
top_left = [-6, -6];
text = {'How','What','And','But','Can','Could','For','Are','Come','Did','Does'
    'When','Where','From','That','The','There','This','Get','Had','Have','Is'
    'Who','Why','To','Was','Will','With','Would','No','Need','Put','Say'};
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        x = x_sp*(top_left(1) + (ii-1));
        y = y_sp*(top_left(2) + (i-1));
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
    end
end

% left keys
height = 30;
width = 45;
top_left = [-6, -3];
text = {'I','I''m','Can''t'
    'Me','My','Don''t'
    'You','Your','Not'
    'He','Him','His'
    'She','Her',''
    'It','We',''
    'They','Their','Them'
    '','',''};
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        x = x_sp*(top_left(1) + (ii-1));
        y = y_sp*(top_left(2) + (i-1));
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
    end
end

% middle keys
height = 48;
width = 45;
top_left = [-3, -2];
text = {'A','B','C','D','UNDO'
    'E','F','G','H','SPACE'
    'I','J','K','L','M'
    'O','P','Qu','R','S'
    'U','V','W','X','Y'};
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        x = x_sp*(top_left(1) + (ii-1));
        y = y_sp*(top_left(2) + (i-1)) + 22;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
    end
end

% more middle keys
height = 48;
width = 45;
top_left = [+2, +0];
text = {'N'
    'T'
    'Z'};
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        x = x_sp*(top_left(1) + (ii-1));
        y = y_sp*(top_left(2) + (i-1)) + 22;
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
    end
end

% right keys
height = 30;
width = 45;
top_left = [+2, -3];
text = {'Take','Think','Want'
    'Please','OK','Thanks'
    'Hold On','Start Over', 'Back'};
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        x = x_sp*(top_left(1) + (ii-1));
        y = y_sp*(top_left(2) + (i-1));
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
    end
end

% more right keys
height = 30;
width = 45;
top_left = [+3, 0];
text = {'<3','Finished'
    '.','-ed'};
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        x = x_sp*(top_left(1) + (ii-1));
        y = y_sp*(top_left(2) + (i-1));
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
    end
end

% more right keys
height = 30;
width = 45;
top_left = [+4, +2];
text = {'-ing'
    '-s'
    'Msg Code'};
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        x = x_sp*(top_left(1) + (ii-1));
        y = y_sp*(top_left(2) + (i-1));
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
    end
end

% punctuation keys
height = 30;
width = 20;
top_left = [+4, +2];
text = {',','?'
    '!',''''
    ':','$'};
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 10;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        x = x_sp*(top_left(1) + (ii-1)) + 75;
        y = y_sp*(top_left(2) + (i-1));
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
    end
end

% number keys
height = 30;
width = 45;
top_left = [-6, +5];
text = {'YES','1','2','3','4','5','6','7','8','9','0','NO'};
x_sz = width;
y_sz = height;
x_sp = x_sz*2 + 8;
y_sp = y_sz*2 + 10;
for i = 1:size(text,1),
    for ii = 1:size(text,2),
        x = x_sp*(top_left(1) + (ii-1)) - 38;
        y = y_sp*(top_left(2) + (i-1));
        Params.ReachTargetPositions(end+1,:)= [x, y];
        Params.ReachTargetWindows(end+1,:)  = [x-x_sz y-y_sz x+x_sz y+y_sz];
        Params.ReachTargetText{end+1,1}     = text{i,ii};
    end
end

% number of targets
Params.NumReachTargets = size(Params.ReachTargetPositions, 1);

end % GetKeyboardLayout
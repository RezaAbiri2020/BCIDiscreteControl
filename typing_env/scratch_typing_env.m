addpath(genpath('../../'))
addpath(genpath('../../'))

ExperimentStart('test', 2, 0, 1)

pwd


Params.Subject = 'test';
Params.ControlMode = 2;
Params.BLACKROCK = 0;
Params.DEBUG = 1;

Params = GetParams(Params);

Params.ReachTargetPositions

[screen_w, screen_h] = Screen('WindowSize', 0);
% [Params.WPTR, Params.ScreenRectangle] = Screen('OpenWindow', 0, 0, [670 80 3170 2080]); % Left, Top, Right, Bottom
[Params.WPTR, Params.ScreenRectangle] = Screen('OpenWindow', 0, 0, [50 50 2000 1000]);

Params.Center = [mean(Params.ScreenRectangle([1,3])),mean(Params.ScreenRectangle([2,4]))];
TrialData.Block = 1;
TrialData.Trial = 1;
TrialData.TargetID = 1;

% Code below to be added to CursorEnv master code
KP = SetKeyboardParams(Params); % proabably add this to ExperimentStart
Params.Keyboard = KP;

KP.State.SelectedCharacters = {'ABCD'};
Params.Keyboard = KP;
Params = MatchWords(Params);
KP = Params.Keyboard;

KP.State.SelectedCharacters = [KP.State.SelectedCharacters, 'MNOPQ'];
Params.Keyboard = KP;
Params = MatchWords(Params);
KP = Params.Keyboard;

Params.Keyboard.State.Mode = 'Word';

Params.Keyboard = KP;
Params = UpdateKeyboard(Params);
Screen('Flip', Params.WPTR);

Screen('CloseAll')


KP = SetKeyboardParams('NoDisplay', true);
corpus = KP.Text.WordSet;
word_lens = cellfun(@length, corpus);
[~, ix_sort] = sort(word_lens);
words = corpus(ix_sort);

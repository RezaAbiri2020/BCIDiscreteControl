function [Params] = CheckKeys(Params)
% [b_in_text, b_in_arrow] = CheckKeys(KP)

% TODO: change to accurate check
KP = Params.Keyboard;

Targets = KP.State.CurrentTargets;
if KP.State.TargetID > 0
    b_In_Target = KP.State.TargetID;
else,
    b_In_Target = [];
end

KP.State.InArrow = ismember(KP.Pos.ArrowTargets, Targets(b_In_Target, :), 'rows');
KP.State.InText  = ismember(KP.Pos.TextTargets,  Targets(b_In_Target, :), 'rows');
KP.State.InCurrent = ismember(KP.State.CurrentTargets, Targets(b_In_Target, :), 'rows');

Params.Keyboard = KP;
end  % CheckKeys

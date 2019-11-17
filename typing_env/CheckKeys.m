function [Params] = CheckKeys(Params)
% [b_in_text, b_in_arrow] = CheckKeys(KP)

% TODO: change to accurate check
KP = Params.Keyboard;
% Targets = [KP.Pos.ArrowTargets; KP.Pos.TextTargets];
Targets = KP.State.CurrentTargets;
% target_edges = KP.State.CurrentTargetEdges;
n_targets = size(Targets, 1);
% pos_curosr = real(Cursor.State(1:2)') + Params.Center;
b_In_Target = false(n_targets, 1);
if KP.State.TargetID > 0
    b_In_Target(KP.State.TargetID) = true;
end
% for i = 1:n_targets
%     t_edge = target_edges(:, i);
%     t_b_in = pos_curosr(1) >= t_edge(1) && pos_curosr(1) <= t_edge(3);
%     t_b_in = t_b_in && (pos_curosr(2) >= t_edge(2) && pos_curosr(2) <= t_edge(4));
%     b_In_Target(i) = t_b_in;
% end

KP.State.InArrow = ismember(KP.Pos.ArrowTargets, Targets(b_In_Target, :), 'rows');
KP.State.InText  = ismember(KP.Pos.TextTargets,  Targets(b_In_Target, :), 'rows');
KP.State.InCurrent = ismember(KP.State.CurrentTargets, Targets(b_In_Target, :), 'rows');

inFlag = any(KP.State.InCurrent);
Params.Keyboard = KP;
end  % CheckKeys

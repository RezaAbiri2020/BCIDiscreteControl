function UpdateClicker(Params, Neuro, Clicker)
% Applies discrete decoder to update click state (within cursor)

global Cursor

if Params.GenNeuralFeaturesFlag,
   [~,~,B] = GetMouse();
   if any(B)
       Clicking = -1;
   else
       Clicking =1;
   end
else,
   [~, Click_Decision] = Clicker.Func(Neuro.NeuralFeatures);
   if Click_Decision <= Params.DecisionBoundary %click decision criteria
       Clicking = -1; % clicking
   else
       Clicking = 1; % not clicking
   end
end

% must click for X bins in a row
if Clicking==-1, % clicking
    Cursor.ClickState = Cursor.ClickState + 1;
else, % not clicking
    Cursor.ClickState = 0;
end

end % UpdateClicker
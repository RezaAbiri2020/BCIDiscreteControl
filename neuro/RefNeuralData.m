function Neuro = RefNeuralData(Neuro),
% function Neuro = RefNeuralData(Neuro)
% references neural data based on stored Parameters
% 
% Neuro - 
%   .BroadbandData - [ samples x channels ]
% Params

switch Neuro.ReferenceMode,
    case 0, % no reference
        mu = zeros(size(Neuro.BroadbandData,1),1);
        ref_data = Neuro.BroadbandData;
        mu = zeros(size(Neuro.BroadbandData,1),1);
    case 1, % common mean
        channels = setdiff(1:Neuro.NumChannels,Neuro.BadChannels);
        mu = mean(Neuro.BroadbandData(:,channels),2);
        ref_data = Neuro.BroadbandData - mu;
    case 2, % common median
        channels = setdiff(1:Neuro.NumChannels,Neuro.BadChannels);
        mu = median(Neuro.BroadbandData(:,channels),2);
        ref_data = Neuro.BroadbandData - mu;
end % reference mode

% put in Neuro structure
Neuro.BroadbandData = ref_data;
Neuro.Reference     = mu;

end % RefNeuralData
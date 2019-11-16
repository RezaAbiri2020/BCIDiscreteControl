function Neuro = ZscoreChannels(Neuro),
% function Neuro = ZscoreChannels(Neuro)
% zscores neural data based on stored channel statistics
% 
% Neuro.BroadbandData - [ samples x channels ]

% get current channel stats
mu = Neuro.ChStats.mean;
sigma = sqrt(Neuro.ChStats.var);
sigma(sigma==0) = 1;

% zscore
zneural_data = bsxfun(@minus,Neuro.BroadbandData,mu);
zneural_data = bsxfun(@rdivide,zneural_data,sigma);

% output
Neuro.BroadbandData = zneural_data;

end % ZscoreChannels
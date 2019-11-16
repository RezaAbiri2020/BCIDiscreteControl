function Neuro = UpdateChStats(Neuro)
% function Neuro = UpdateChStats(Neuro)
% update rolling estimate of mean and variance for each channel
% Neuro 
% 	.BroadbandData - [ samples x channels ]
%   .ChStats - structure, which is updated

X = Neuro.BroadbandData;

% update buffer
idx = Neuro.ChStats.Idx + 1;
idx = mod(idx-1, Neuro.ChStats.BufSize)+1;
Neuro.ChStats.Buf{idx} = X;
Neuro.ChStats.Idx = idx;

% compute stats
X2 = cat(1,Neuro.ChStats.Buf{:});
Neuro.ChStats.mean = mean(X2,1);
Neuro.ChStats.var = var(X2,[],1);

% % updates w/ Welford's Alg.
% w                   = size(X,1);
% Neuro.ChStats.wSum1 = Neuro.ChStats.wSum1 + w;
% Neuro.ChStats.wSum2 = Neuro.ChStats.wSum2 + w*w;
% meanOld             = Neuro.ChStats.mean;
% Neuro.ChStats.mean  = meanOld + (w / Neuro.ChStats.wSum1) * mean(X - repmat(meanOld,w,1));
% Neuro.ChStats.S     = Neuro.ChStats.S + w*mean( (X - repmat(meanOld,w,1)).*(X - repmat(Neuro.ChStats.mean,w,1)) );
% Neuro.ChStats.var   = Neuro.ChStats.S / (Neuro.ChStats.wSum1 - 1);

end % UpdateNeuralStats
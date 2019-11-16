function Neuro = UpdateFeatureStats(Neuro)
% function Neuro = UpdateFeatureStats(Neuro)
% update rolling estimate of mean and variance for each feature
% Neuro 
% 	.NeuralFeatures - [ features x 1 ]
%   .FeatureStats - structure, which is updated

X = Neuro.NeuralFeatures';

% update buffer
idx = Neuro.FeatureStats.Idx + 1;
idx = mod(idx-1, Neuro.FeatureStats.BufSize)+1;
Neuro.FeatureStats.Buf{idx} = X;
Neuro.FeatureStats.Idx = idx;

% compute stats
X2 = cat(1,Neuro.FeatureStats.Buf{:});
Neuro.FeatureStats.mean = mean(X2,1);
Neuro.FeatureStats.var = var(X2,[],1);

% % updates w/ Welford's Alg.
% w                           = 1;
% Neuro.FeatureStats.wSum1    = Neuro.FeatureStats.wSum1 + w;
% Neuro.FeatureStats.wSum2    = Neuro.FeatureStats.wSum2 + w*w;
% meanOld                     = Neuro.FeatureStats.mean;
% Neuro.FeatureStats.mean     = meanOld + (w / Neuro.FeatureStats.wSum1) * (X - meanOld);
% Neuro.FeatureStats.S        = Neuro.FeatureStats.S + w*(X - meanOld).*(X - Neuro.FeatureStats.mean);
% Neuro.FeatureStats.var      = Neuro.FeatureStats.S / (Neuro.FeatureStats.wSum1 - 1);

% ignore phase features
NumPhase = sum([Neuro.FilterBank.phase_flag]);
Neuro.FeatureStats.mean(1:NumPhase*Neuro.NumChannels) = 0;
Neuro.FeatureStats.var(1:NumPhase*Neuro.NumChannels) = 0;

end % UpdateNeuralStats
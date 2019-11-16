function Neuro = ZscoreFeatures(Neuro),
% function Neuro = ZscoreFeatures(Neuro)
% zscores neural features based on stored feature statistics
% 
% Neuro.NeuralFeatures - [ features x 1 ]

% get current channel stats
mu = Neuro.FeatureStats.mean';
sigma = sqrt(Neuro.FeatureStats.var');
sigma(sigma==0) = 1;

% zscore
zfeatures = bsxfun(@minus,Neuro.NeuralFeatures,mu);
zfeatures = bsxfun(@rdivide,zfeatures,sigma);

% output
Neuro.NeuralFeatures = zfeatures;

end % ZscoreFeatures
function Neuro = ZscoreFeatures_LongTerm(Neuro),
% function Neuro = ZscoreFeatures_LongTerm(Neuro)
% zscores filtered bands based on precalculated long-term feature statistics
%
% Neuro.NeuralFeatures - [ features x 1 ]

% get current channel stats
mu = Neuro.LongTermStats.mean;
sigma = Neuro.LongTermStats.sd;
sigma(sigma==0) = 1;

% zscore
z_bands = Neuro.FilteredData - Neuro.LongTermStats.mean;
z_bands = z_bands / sigma;
% zfeatures = bsxfun(@minus,Neuro.NeuralFeatures,mu);
% zfeatures = bsxfun(@rdivide,zfeatures,sigma);

% output
Neuro.FilteredData = z_bands;

end % ZscoreFeatures

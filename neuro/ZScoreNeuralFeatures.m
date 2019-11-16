function z_neural_features = ZScoreNeuralFeatures(neural_features,base_features)
% z_neural_features = ZScoreNeuralFeatures(neural_features,base_features)
% z-scores neural features based on features during a baseline period
% ignores first row (feature) since don't want to z-score phase

% remove first feature since don't want to z-score phase
base_features.mu(1,:) = 0;
base_features.sigma(1,:) = 1;

z_neural_features = neural_features - base_features.mu;
z_neural_features = z_neural_features ./ base_features.sigma;

end % ZScoreNeuralFeatures


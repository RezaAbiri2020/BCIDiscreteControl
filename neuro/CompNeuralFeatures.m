function Neuro = CompNeuralFeatures(Neuro),
% Neuro = CompNeuralFeatures(Neuro)
% computes neural features
% phase in delta band + pwr in all available bands
% sets features on bad channels to 0
%
% Neuro
%   .DeltaBuf - buffer of delta band filtered neural data [ samps x chans ]
%   .FilteredData - filtered data from last bin [ samps x chans x frqs ]
%   .NeuralFeatures - vector of features for decoding [ features*chans x 1 ]

% allocate memory
samps = Neuro.NumSamps;
neural_features = zeros(Neuro.NumFeatures,Neuro.NumChannels);

% first compute hilbert for low freq bands
H = hilbert(Neuro.FilterDataBuf);

% compute phase features
idx = [Neuro.FilterBank.phase_flag];
idx = idx(1:Neuro.NumBuffer);
ang = angle(H(:,:,idx)); % instantaneous angle
for i=1:Neuro.NumPhase,
    neural_features(i,:) = angle(sum(exp(1i*squeeze(ang(end-samps+1:end,:,i)))));
end

% compute pwr in low freq bands based on hilbert (only keep last bin)
hilb_pwr = abs(H); % [samples x channels x freqs]
pwr1 = squeeze(log10(mean(hilb_pwr(end-samps+1:end,:,:),1)))'; % avg in last bin
% [freqs x channels]

% compute average pwr for all remaining freq bands in last bin
pwr2 = squeeze(log10(mean(Neuro.FilteredData(:,:,Neuro.NumBuffer+1:end).^2, 1)))';
% [freqs x channels]

% combine feature vectors and remove singleton dimension
pwr = cat(1,pwr1,pwr2);
feature_idx = [Neuro.FilterBank.feature];
for i=(Neuro.NumPhase+1):Neuro.NumFeatures,
    idx = feature_idx == i;
    neural_features(i,:) = mean(pwr(idx,:),1);
end

if Neuro.SpatialFiltering,
    % remap features to reflect spatial layout of ecog grid
    [R,C] = size(Neuro.ChMap);
    Nch = 128; % channels
    feature_map = cell(1,Neuro.NumFeatures);
    for i=1:Neuro.NumFeatures,
        feature_map{i} = zeros(R,C);
        for ch=1:Nch,
            [r,c] = find(Neuro.ChMap == ch);
            feature_map{i}(r,c) = neural_features(i,ch);
        end
    end

    % perform spatial filter per feature w/ param in filter bank
    feature_map_filt = cell(1,Neuro.NumFeatures);
    for i=1:Neuro.NumFeatures,
        if i==Neuro.NumPhase,
            idx = find([Neuro.FilterBank.feature]==i+1,1);
            sz = Neuro.FilterBank(idx).spatial_filt_sz;
        else,
            idx = find([Neuro.FilterBank.feature]==i,1);
            sz = Neuro.FilterBank(idx).spatial_filt_sz;
        end
        feature_map_filt{i} = medfilt2(feature_map{i},[sz,sz],'symmetric');
    end

    % remap to 2d matrix [ features x channels ]
    new_neural_features = zeros(size(neural_features));
    for i=1:Neuro.NumFeatures,
        for ch=1:Nch,
            [r,c] = find(Neuro.ChMap == ch);
            new_neural_features(i,ch) = feature_map_filt{i}(r,c);
        end
    end

    % vectorize
    new_neural_features = reshape(new_neural_features',[],1);

else, % spatial filtering off
    % vectorize
    new_neural_features = reshape(neural_features',[],1);
end

% buffer of neural features
if Neuro.NumFeatureBins>1,
    Neuro.NeuralFeaturesBuf = circshift(Neuro.NeuralFeaturesBuf,[0,-1]);
    Neuro.NeuralFeaturesBuf(:,Neuro.NumFeatureBins) = new_neural_features;
    % circular mean for phase features
    phase_idx = 1:Neuro.NumPhase*Neuro.NumChannels;
    Neuro.NeuralFeatures(phase_idx,1) = ...
        angle(sum(exp(1i * Neuro.NeuralFeaturesBuf(phase_idx,:)),2));
    % regular mean for pwr features
    pwr_idx = Neuro.NumPhase*Neuro.NumChannels+1:Neuro.NumFeatures*Neuro.NumChannels;
    Neuro.NeuralFeatures(pwr_idx,1) = ...
        mean(Neuro.NeuralFeaturesBuf(pwr_idx,:),2);
else, % put features straight into Neuro
    Neuro.NeuralFeatures = new_neural_features;
end

end % CompNeuralFeatures


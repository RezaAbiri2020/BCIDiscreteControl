function SavePersistence(Params,Neuro,KF,TaskFlag)
% Save key (possibly changing variables) in persistence directory
% important variables to save:
%   ch_stats - mean/var of signal on each channel
%   feature_stats - mean/var of each feature
%   KF - kalman filter
%   FeatureMask - needs to be saved with kalman filter
% other vars
%   Params.Persistencedir - where to save
%   TaskFlag - only save kalman filter if not in imagined blocks

% channel stats
ch_stats = Neuro.ChStats;
save(fullfile(Params.Persistencedir, 'ch_stats.mat'),...
    'ch_stats', '-v7.3', '-nocompression');

% feature stats
feature_stats = Neuro.FeatureStats;
save(fullfile(Params.Persistencedir, 'feature_stats.mat'),...
    'feature_stats', '-v7.3', '-nocompression');

% save kalman filter and corresponding feature mask
if TaskFlag>1 && exist('KF','var'),
    FeatureMask = Params.FeatureMask;
    
    if ~Params.GenNeuralFeaturesFlag % if it is not in mouse mode control
        if size(KF.C,2) == 5,
            save(fullfile(Params.Persistencedir, 'kf_params.mat'),...
                'KF', 'FeatureMask', '-v7.3', '-nocompression');
        else,
            save(fullfile(Params.Persistencedir, 'kf_params_1D.mat'),...
                'KF', 'FeatureMask', '-v7.3', '-nocompression');
        end
        
    end
    
end

end
%#ok<*INUSD> 
%#ok<*NASGU>
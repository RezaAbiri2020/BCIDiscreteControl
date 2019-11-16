function ExperimentStop(Params, fromPause)
if ~exist('fromPause', 'var'), fromPause = 0; end

% Close Screen
Screen('CloseAll');

% Close Serial Port and audio
fclose('all');

% Update parameters of full kalman filter in persistence folder
f1 = load(fullfile(Params.Persistencedir, 'full_kf_params.mat'));
f2 = load(fullfile(Params.Persistencedir, 'kf_params.mat'));
KF = f1.KF; % initialize to full kf, then update params
KF.P                                            = f2.KF.P;
KF.R                                            = f2.KF.R;
KF.ESS                                          = f2.KF.ESS;
KF.S(Params.FeatureMask,:)                      = f2.KF.S;
KF.T(Params.FeatureMask,Params.FeatureMask)     = f2.KF.T;
KF.C(Params.FeatureMask,:)                      = f2.KF.C;
KF.Q(Params.FeatureMask,Params.FeatureMask)     = f2.KF.Q;
KF.Tinv(Params.FeatureMask,Params.FeatureMask)  = f2.KF.Tinv;
KF.Qinv(Params.FeatureMask,Params.FeatureMask)  = f2.KF.Qinv;
save(fullfile(Params.Persistencedir, 'full_kf_params.mat'), ...
    'KF', '-v7.3', '-nocompression')

% Save persistence folder with Data
mkdir(fullfile(Params.Datadir,'persistence'))
copyfile(fullfile(Params.Persistencedir, 'kf_params.mat'),...
    fullfile(Params.Datadir, 'persistence', 'kf_params.mat'));

% quit
fprintf('Ending Experiment\n')
if fromPause, keyboard; end

end % ExperimentStop

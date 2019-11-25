function Params = LoadFeatureMask(Params)
% Params = LoadFeatureMask(Params)
% if UseFeatureMask is set to True, asks user to choose a mask file
% otherwise, sets mask to all features

if Params.UseFeatureMask,
    % loads feature mask
    [filename,pathname] = uigetfile('*.mat', 'Choose Feature Mask (Press Cancel for None)');
    
    % pressed cancel
    if isequal(filename,0) || isequal(pathname,0),
        % sets all bad channels to 0, o.w. 1
        Mask = ones(Params.NumChannels*Params.NumFeatures,1);
        for i=1:length(Params.BadChannels),
            bad_ch = Params.BadChannels(i);
            Mask(bad_ch+(0:Params.NumChannels:Params.NumChannels*(Params.NumFeatures-1)),1) = 0;
        end
        Params.FeatureMask = Mask==1;
    else, % user file
        f = load(fullfile(pathname,filename));
        Params.FeatureMask = f.mask==1;
    end
else,
    % sets all bad channels to 0, o.w. 1
    Mask = ones(Params.NumChannels*Params.NumFeatures,1);
    for i=1:length(Params.BadChannels),
        bad_ch = Params.BadChannels(i);
        Mask(bad_ch+(0:Params.NumChannels:Params.NumChannels*(Params.NumFeatures-1)),1) = 0;
    end
    Params.FeatureMask = Mask==1;

end

end % LoadFeatureMask
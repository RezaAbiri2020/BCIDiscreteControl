function Neuro = ApplyFilterBank(Neuro)
% Neuro = ApplyFilterBank(neural_data,Neuro)
% Neuro - structure w/ vars
%   .FilterBank - updates filter bank states
%   .BroadbandData - everything in buffer [ samples x channels ]
%   .FilteredData - [ samples x channels x filters ]

% allocate memory [ samples x channels x filters ]
[samps, chans] = size(Neuro.BroadbandData);
filtered_data = zeros(samps,chans,length(Neuro.FilterBank));

% apply each filter and track filter state
for i=1:length(Neuro.FilterBank),
    [filtered_data(1:samps,1:chans,i), Neuro.FilterBank(i).state] = ...
        filter(...
        Neuro.FilterBank(i).b, ...
        Neuro.FilterBank(i).a, ...
        Neuro.BroadbandData, ...
        Neuro.FilterBank(i).state);
end

% put in Neuro
Neuro.FilteredData = filtered_data;

end % ApplyFilterBank


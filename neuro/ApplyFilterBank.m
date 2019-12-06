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

% re filter the HG filtered data i.e. 9 thru 16 
idx = find([Neuro.FilterBank.feature]==7);

% low pass filter the HG amplitude
for i=1:length(idx)
     [filtered_data(1:samps,1:chans,idx(i)), Neuro.LFOFilter.state{i}] = ...
        filter(...
        Neuro.LFOFilter.b, ...
        Neuro.LFOFilter.a, ...
        abs(hilbert(filtered_data(1:samps,1:chans,idx(i)))), ...
        Neuro.LFOFilter.state{i});    
end

% put in Neuro
Neuro.FilteredData = filtered_data;

end % ApplyFilterBank


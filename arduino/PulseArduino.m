function PulseArduino(ptr,pin,num_pulses)

high_dur = 1; % ms
low_dur = 1; % ms
for n=1:num_pulses,
    writeDigitalPin(ptr, pin, 1);
    WaitSecs(high_dur/1000);
    writeDigitalPin(ptr, pin, 0);
    WaitSecs(low_dur/1000);
end

end
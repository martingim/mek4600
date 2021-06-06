close all
%%setup filenames and flow rates
filenames = [];
for i=30:48
    filenames = [filenames; sprintf("14042021/210514_07%d.wav", i)];
end
n_runs = size(filenames, 1);
% set up flow rates 
D = 0.008;

flow_rates = [  34;34;
                0;0;
                225;225;225;
                1250;1250;1260;
                1745;1765;1750;
                2005;2075;2030;
                2330;2270;2295];
same_flow_rates = [1,2;3,4;5,7;8,10;11,13;14,16;17,19];
same_flow_rates = [1,2;3,4;5,6;8,9;11,12;14,15;17,18];
Re = flow_rate_to_Re(flow_rates, D);
%% Calculate noise power spectrum
[noise1, Fs] = audioread(filenames(3));
[noise2, Fs] = audioread(filenames(4));
noise = [noise1;noise2];
[noise_power, noise_f] = pspectrum(noise, Fs, "power");


%% plot the power spectrum for runs combined
figure
set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')
hold on
legends = [];
    
for i=1:size(same_flow_rates, 1)
    turb_sound = [];
    r = 0;
    for j=same_flow_rates(i,1):same_flow_rates(i,2)
        filename = filenames(j)
        [y, Fs] = audioread(filename);
        turb_sound = [turb_sound;y];
        r = r + Re(j);
    end
    r = -same_flow_rates(i,1)+same_flow_rates(i,2);
    [turb_sound, ~] = buffer(turb_sound, Fs*0.05);
    [p, f] = pspectrum(turb_sound, Fs, "power");
    p = mean(p, 2);
    energy;
    start_f = 200;
    f(200)
    %p = p-noise_power;
    [~, start_idx] = min(abs(f-start_f));
    end_f = 1700;
    [~, end_idx] = min(abs(f-end_f));
    f_line = f(start_idx:end_idx)';
    p_line = p(start_idx:end_idx);
    
    %line = fit(log10(f_line'), log10(p_line), 'poly1', 'Weight', 1./log10(f_line+1e-6));
    %plot(f_line', 10.^line(log10(f_line)))
    plot(f, p)
    %line.p1
    
    legends = [legends; sprintf("Re:%.3d", Re(j))];
end
legends = [legends; "-5/3 slope"];
x = linspace(125, 20000);
y = 0.8*x.^(-5/3);
plot(x, y, '--k')

legend(legends)
title('Periodogram')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')
ylabel("PSD")
xlabel("Frequency [Hz]")

%% plot the power spectrum for same Re
figure
set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')
hold on
legends = [];
for run_sequence=1:7
    figure
    set(gca, 'YScale', 'log')
    set(gca, 'XScale', 'log')
    hold on
    legends = [];
    for i=same_flow_rates(run_sequence,1):same_flow_rates(run_sequence,2)
        turb_sound = [];

        filename = filenames(i)
        [turb_sound, Fs] = audioread(filename);

        [turb_sound, ~] = buffer(turb_sound, Fs);
        [p, f] = pspectrum(turb_sound, Fs, "power");
        p = mean(p, 2);

        plot(f, p)
        legends = [legends; sprintf("%s, Re:%.3d",filename, Re(i))];
        clearvars p turbsound
    end
    legend(legends, 'Interpreter', 'none')
    title('Periodogram')
    xlabel('Frequency (Hz)')
    ylabel('Power/Frequency (dB/Hz)')
    ylabel("PSD")
    xlabel("Frequency [Hz]")
end
%% plot the spectrogram
figure;
for run_sequence=7
    j = 1;
    for i=[1, 3, 15]
        turb_sound = [];

        filename = filenames(i)
        [turb_sound, Fs] = audioread(filename);
        subplot(3,1,j)
        pspectrum(turb_sound, Fs, "spectrogram", 'FrequencyLimits',[1 5000]);
        title(sprintf("Re %.0f", Re(i)))
        j = j+1;
        
    end

end

%%
    
figure
hold on
filename_no_flow = "180404_0359_CCLD_uten_flow.wav";
filename_with_flow = "180404_0360_CCLD_med_flow.wav";

[y, Fs] = audioread(filename_no_flow);
subplot(2, 1, 1)
[p, f] = pspectrum(y, Fs, "power");
loglog(f, p)
ylabel("PSD")
xlabel("Frequency [Hz]")

[y, Fs] = audioread(filename_with_flow);
subplot(2, 1, 2)
[p, f] = pspectrum(y, Fs, "power");
loglog(f, p)
ylabel("PSD")
xlabel("Frequency [Hz]")

%%

figure;
y = y(1:44000);
N = size(y, 1);

ydft = fft(y);
ydft = ydft(1:N/2+1);
psdy =  abs(ydft).^2;
psdy(2:end-1) = 2*psdy(2:end-1);
freq = 0:Fs/length(y):Fs/2;


plot(freq,psdy)
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')



%%

figure
res = [];
Re = flow_rate_to_Re(flow_rates, 0.008);
for i=1:size(same_flow_rates, 1)
    
    run_numbers = same_flow_rates(i,1):same_flow_rates(i,end);
    runs = [filenames(run_numbers)];
    [~, slope] = noise_filtering(runs, Re(run_numbers));
    res = [res;sprintf("Re:%d", Re(run_numbers(1)));sprintf("slope:%d", slope)];
end
legend(res)







% [y, Fs] = audioread(filename);
% N = length(y);
% figure;
% subplot(3, 1, 1)
% t = ((0:N-1)/Fs)';
% plot(t, y)
% title("audio sample")
% ylabel("signal")
% xlabel("t[s]")
% subplot(3, 1, 2)
% pspectrum(y, Fs, "spectrogram")
% 
% %sound(y, Fs)
% subplot(3, 1, 3)
% [p, f] = pspectrum(y, Fs, "power");
% loglog(f, p)
% ylabel("PSD")
% xlabel("Frequency [Hz]")
% 

% 
% figure;
% ydft = fft(y);
% ydft = ydft(1:N/2+1);
% psdy =  abs(ydft).^2;
% psdy(2:end-1) = 2*psdy(2:end-1);
% freq = 0:Fs/length(y):Fs/2;
% 
% loglog(freq,psdy)
% 
% title('Periodogram Using FFT')
% xlabel('Frequency (Hz)')
% ylabel('Power/Frequency (dB/Hz)')


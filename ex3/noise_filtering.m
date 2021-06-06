function [turb_sound, slope] = noise_filtering(filenames, Re)
filename_no_flow = "14042021/210514_0732.wav";
filename_no_flow2 = "14042021/210514_0733.wav";

turb_sound = [];
for i=1:length(filenames)
    [y, Fs] = audioread(filenames(i));
    turb_sound = [turb_sound; y];
end
[noise1, Fs] = audioread(filename_no_flow); %read from noise file
[noise2, Fs] = audioread(filename_no_flow2); %read from noise file
noise = [noise1;noise2];

stop_freq = 8000;
w_size = Fs;

%% make power spectrum of the noise
figure
noise_fft = fft(buffer(noise, w_size)); %moving window fft of the noise
n = size(noise_fft, 1);
noise_fft = noise_fft(1:n/2+1,:); 
noise_spectrum = abs(noise_fft.^2); %power spectrum
mean_noise_spectrum = mean(noise_spectrum, 2); %mean of the calculated power spectrums
mean_noise_spectrum(2:end-1) = 2*mean_noise_spectrum(2:end-1);
noise_freq = 0:Fs/n:Fs/2;
noise_freq = noise_freq(noise_freq<=stop_freq); %only consider frequencies up to the stop frequency
mean_noise_spectrum = mean_noise_spectrum(1:length(noise_freq));
loglog(noise_freq, mean_noise_spectrum)

%% 


%% remove the noise power
y = turb_sound;
yfft = fft(buffer(y, w_size)); %fft of the sound
N = size(yfft, 1);
yfft = yfft(1:N/2+1,:); 
yspectrum = abs(yfft.^2); %power spectrum
yspectrum = mean(yspectrum, 2);
yspectrum(2:end-1) = 2*yspectrum(2:end-1);
f = 0:Fs/N:Fs/2;
f = f(f<=stop_freq); %only consider frequencies up to the stop frequency
p = yspectrum(1:length(f))';


n_spectrum = interp1(noise_freq, mean_noise_spectrum, f);
p_spec = p-n_spectrum;
%% plot the power spectrum removed noise
figure
loglog(f, p_spec)
hold on 
loglog(f, p)

%% remove the noise fft
noise_fft = mean(abs(noise_fft), 2);
noise_fft = noise_fft(1:length(noise_freq));

y = turb_sound;
yfft = fft(buffer(y, w_size)); %fft of the sound
N = size(yfft, 1);
f = 0:Fs/N:Fs/2;
yfft = yfft(1:N/2+1,:); 
%resize to remove frequencies

f = f(f<=stop_freq);
yfft = yfft(1:length(f),:);

%remove_noise
n_fft = interp1(noise_freq, noise_fft, f)';
yfft = abs(yfft)-n_fft;

%power spectrum
yspectrum = abs(yfft.^2); %power spectrum
yspectrum = mean(yspectrum, 2);
yspectrum(2:end-1) = 2*yspectrum(2:end-1);





%% plot the fft removed noise
figure
plot(log10(f), smooth(log10(yspectrum), 400))
hold on 
plot(log10(f), log10(p))
plot(log10(f), log10(n_fft))

%%calculate the slope
[~, start_idx] = min(abs(f-10^1.5));
[~, end_idx] = min(abs(f-10^3.5));
f_line = f(start_idx:end_idx)';
p = yspectrum(start_idx:end_idx);

line = fit(log10(f_line), log10(p), 'poly1');
plot(log10(f_line), line(log10(f_line)))
title(sprintf("Re %d", Re(1)))
s = smooth(log10(yspectrum), 5);
s = smooth(s, 50);
s = smooth(s, 400);

slope = line.p1;

close
close
close
%figure

plot(log10(f), s)
hold on 
plot(log10(f_line), line(log10(f_line)))

title(sprintf("Re=%d, slope=%d", Re(1), line.p1))
% line2 = fit(f', yspectrum, 'smoothingspline');
% plot(log10(f), log10(line2(f)))
end















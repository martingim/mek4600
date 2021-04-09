filename = "210507_0689.wav";
[y, Fs] = audioread(filename);
N = length(y);
figure;
subplot(3, 1, 1)
t = ((0:N-1)/Fs)';
plot(t, y)
title("audio sample")
ylabel("signal")
xlabel("t[s]")
subplot(3, 1, 2)
pspectrum(y, Fs, "spectrogram")

%sound(y, Fs)
subplot(3, 1, 3)
[p, f] = pspectrum(y, Fs, "power");
loglog(f, p)
ylabel("PSD")
xlabel("Frequency [Hz]")


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


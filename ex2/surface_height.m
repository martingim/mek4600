function [a, fig] = surface_height(run_number)
image_names
height_config
folder = day_folder(run_number);
f = frequency(run_number); %The frequency of the run
[omega,T,K,LAMBDA,CP,CG] = wparam(f, 0.33); %calculate the wavenumber and phase velocity
sensor_distance = 0.4; %the dstance between the sensors in meters(should maybe change this to a vector)
%start and stop frame for measuring the elevation of the surface
surface_frame_start = surface_start_stop(run_number, 1);
surface_frame_end = surface_start_stop(run_number, 2);


sensor_samplerate = 100; %Hz
min_separation = 1/f*sensor_samplerate*0.8; %minimum separation when finding the crests and troughs
%read sensor data from file
sensordata = table2array(readtable(folder + sprintf("/run%d.csv", run_number)));

%remove zeros
sensordata = sensordata(:,5:8);
sensordata(sensordata<350|sensordata>850) = NaN; %replace the outliers with NaN

%convert the data from the sensors to measured surface elevation in meters
measured_surface = [sensor1(sensordata(:,1)), sensor2(sensordata(:,2)) sensor3(sensordata(:,3)) sensor4(sensordata(:,4))];

%subtract the mean from the surface to get zero mean
surface_mean = mean(measured_surface(1:100,:), 'omitnan');
measured_surface = measured_surface -surface_mean;

%plot the sensor data from all four sensors with the same waves on top of
%each other
sensor_offset = round(sensor_samplerate*sensor_distance/CP)-2; %sensor offset in samples to plot the same waves on top of each other
% figure;
% hold on 
% plot(measured_surface(:,1))
% plot(measured_surface(1*sensor_offset:end,2))
% plot(measured_surface(2*sensor_offset:end,3))
% plot(measured_surface(3*sensor_offset:end,4))
% legend('sensor1', 'sensor2', 'sensor3', 'sensor4')
% 
% %Find the crests on troughs from the first sensor and plot with the
% %measured data
% time = (1:size(measured_surface, 1))/100;
% figure;
% hold on
% surf = measured_surface(:,1);
% plot(time, measured_surface(:,1))
% LMax = islocalmax(measured_surface(:,1), 'MinSeparation', min_separation);
% LMin = islocalmin(measured_surface(:,1), 'MinSeparation', min_separation);
% plot(time(LMin), surf(LMin), 'x')
% plot(time(LMax), surf(LMax), 'x')


%%
%find the crests and troughs of the measured surface to find the mean
%amplitude of the waves. %%maybe change this later to only look at one wave
% surf = measured_surface(surface_frame_start:surface_frame_end,:); %change this to use the sensor_offset
surf = zeros(surface_frame_end-surface_frame_start-3*sensor_offset, 4);

surf(:,1) = measured_surface(surface_frame_start + sensor_offset*0:surface_frame_end-3*sensor_offset-1,1);
surf(:,2) = measured_surface(surface_frame_start + sensor_offset*1:surface_frame_end-2*sensor_offset-1,2);
surf(:,3) = measured_surface(surface_frame_start + sensor_offset*2:surface_frame_end-1*sensor_offset-1,3);
surf(:,4) = measured_surface(surface_frame_start + sensor_offset*3:surface_frame_end-0*sensor_offset-1,4);


surf = fillmissing(surf(:,:),'linear');

smooth_surf = zeros(size(surf));
smooth_surf(:,1) = smooth(surf(:,1),0.02,'rloess');
smooth_surf(:,2) = smooth(surf(:,2),0.02,'rloess');
smooth_surf(:,3) = smooth(surf(:,3),0.02,'rloess');
smooth_surf(:,4) = smooth(surf(:,4),0.02,'rloess');
% %% plot measured and smoothed
% figure;
% hold on 
% plot(smooth_surf(:,1), '--')
% plot(smooth_surf(:,2), '--')
% plot(smooth_surf(:,3), '--')
% plot(smooth_surf(:,4), '--')
% plot(surf(:,1))
% plot(surf(:,2))
% plot(surf(:,3))
% plot(surf(:,4))
% legend('1', '2', '3', '4','1', '2', '3', '4')

mean_amplitude = zeros(size(surf, 2),1);
for i=1:size(surf, 2)
    LMax = islocalmax(smooth_surf(:,i), 'MinSeparation', min_separation);
    LMin = islocalmin(smooth_surf(:,i), 'MinSeparation', min_separation);
    mean_amplitude(i) = (mean(smooth_surf(LMax,i))-mean(smooth_surf(LMin, i)))/2;
end
a = mean(mean_amplitude);

%% plot the measured surface with theoretical linear and non linear
end_time = 1;
t_measured = 0:0.01:end_time;

% figure;
% plot(surf(:,1))
t = 0:0.01:end_time;
eta = a*cos(-omega*t); %the linear surface
eta_non_linear = a*cos(-omega*t) +  0.5*a^2*K*cos(2*(-omega*t)) + 3/8*K^2*a^3*cos(3*(-omega*t)); %the non-linear surface
mean(eta)
mean(eta_non_linear)
%plot the surfaces

plot(t, eta)
hold on 
plot(t, eta_non_linear)

%find the first crest to start plotting from
S = zeros(4,1);
S_s = zeros(4,1);
surface = zeros(size(t_measured, 2), 4);
surface_s = zeros(size(t_measured, 2), 4);

for i=1:4
    crests = islocalmax(smooth(surf(:,i),0.01,'rloess'), 'MinSeparation', 10);
    crest_found = -1;
    while crest_found<0
        [m, start_idx] = max(crests); %the index to start plotting the measured surface from
        

        if smooth_surf(start_idx, i)<0.9*a
            crests(start_idx) = 0;
        else
            crest_found=1;
        end
    end
    if i==1
        measured_mean = surf(start_idx:start_idx+size(t_measured, 2)-1,i);
        smoothed_measured_mean = smooth_surf(start_idx:start_idx+size(t_measured, 2)-1,i);
        surface(:,i) = surf(start_idx:start_idx+size(t_measured, 2)-1,i);
    else
        surface(:,i) = surf(start_idx:start_idx+size(t_measured, 2)-1,i);
        measured_mean(:,:) = measured_mean(:,:) + surf(start_idx:start_idx+size(t_measured, 2)-1,i);
        smoothed_measured_mean(:,:) = smoothed_measured_mean(:,:) + smooth_surf(start_idx:start_idx+size(t_measured, 2)-1,i);
    
    end
    
    %plot(t_measured, smooth_surf(start_idx:start_idx+size(t_measured, 2)-1,i)', '--')
end
measured_mean = measured_mean./4;


smoothed_measured_mean = smoothed_measured_mean./4;
S = std(surface-measured_mean);
crests = islocalmax(smoothed_measured_mean);
crest_values = smoothed_measured_mean(crests);
troughs = islocalmin(smoothed_measured_mean);
trough_values = smoothed_measured_mean(troughs);
smoothed_measured_mean_n =  smoothed_measured_mean;% -(mean(crest_values) - eta_non_linear(1) );
smoothed_measured_mean = smoothed_measured_mean;% -(mean(crest_values) - eta(1) );

non_lin_rms = rms(smoothed_measured_mean_n-eta_non_linear');
lin_rms = rms(smoothed_measured_mean - eta');

if lin_rms<non_lin_rms
    plot(t_measured, smoothed_measured_mean)
    disp('linear')
else
    plot(t_measured, smoothed_measured_mean_n)
    disp('non linear')
end

%legend('linear', 'non-linear', '1', '2', '3', '4', 'mean of the sensor data')
%legend('linear', 'non-linear', 'mean of the smoothed sensor data', 'Location', 'southoutside')
title(sprintf('surface elevation run:%d', run_number))
xlabel('t[s]')
ylabel('$\eta [m]$', 'interpreter', 'latex', 'FontSize', 15, 'rotation', 0)
% 
% figure;
% %% FFT of the measured surface
% surf = surf(1:end-rem(size(surf, 1), 2),:); %resize to simplify
% 
% X1 = surf(:,1);
% X2 = surf(:,2);
% X3 = surf(:,3);
% X4 = surf(:,4);
% Y1 = fft(X1);
% Y2 = fft(X2);
% Y3 = fft(X3);
% Y4 = fft(X4);
% 
% L = size(surf, 1);
% P2_1 = abs(Y1/L);
% P2_2 = abs(Y2/L);
% P2_3 = abs(Y3/L);
% P2_4 = abs(Y4/L);
% 
% P1_1 = P2_1(1:L/2+1);
% P1_2 = P2_2(1:L/2+1);
% P1_3 = P2_3(1:L/2+1);
% P1_4 = P2_4(1:L/2+1);
% 
% P1_1(2:end-1) = (P1_1(2:end-1) + P1_2(2:end-1) + P1_3(2:end-1) + P1_4(2:end-1))./2;
% Fs = 100;
% frequencies = Fs*(0:(L/2))/L;
% 
% figure;
% hold on
% plot(frequencies, P1_1)
% plot(f, 0, 'x')
% plot(2*f, 0, 'x')
% plot(3*f, 0, 'x')
% title(sprintf('FFT of the measured height. Run:%d', run_number))
% legend('fft of the measured surface', 'f', '2f', '3f')
% xlabel('frequency[Hz]')
% xlim([0 f*3.2])
% 
% 
% 
% %% FFT of the measured surface
% figure;
% X = smoothed_measured_mean;
% Y = fft(X);
% L = size(smoothed_measured_mean, 1);
% P2 = abs(Y/L);
% 
% P1 = P2(1:L/2+1);
% 
% P1(2:end-1) = 2*P1(2:end-1);
% P1_s = P1;
% 
% 
% 
% 
% X = eta';
% Y = fft(X);
% L = size(eta', 1);
% P2 = abs(Y/L);
% 
% P1 = P2(1:L/2+1);
% 
% P1(2:end-1) = 2*P1(2:end-1);
% P1_linear = P1;
% 
% X = eta_non_linear';
% Y = fft(X);
% L = size(eta', 1);
% P2 = abs(Y/L);
% 
% P1 = P2(1:L/2+1);
% 
% P1(2:end-1) = 2*P1(2:end-1);
% Fs = 100;
% frequencies = Fs*(0:(L/2))/L;
% 
% 
% hold on
% plot(frequencies, P1)
% plot(frequencies, P1_linear)
% plot(frequencies, P1_s)
% 
% 
% title(sprintf('FFT of the surface height. Run:%d', run_number))
% legend('linear wave', 'non-linear wave', 'mean of smoothed')
% xlabel('frequency[Hz]')
% xlim([0 f*3.2])
end
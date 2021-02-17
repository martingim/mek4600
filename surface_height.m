close all

%start and stop frame for measuring the elevation of the surface
surface_frame_start = 589;
surface_frame_end = 2074;

sensor_samplerate = 100; %Hz
min_separation = 1/frequency*sensor_samplerate*0.8;
%read sensor data from file
sensordata = table2array(readtable(folder + 'run2_3.csv'));

%remove zeros
sensordata = sensordata(:,5:8);
sensordata(sensordata<100) = NaN;


measured_surface = [sensor1(sensordata(:,1)), sensor2(sensordata(:,2)) sensor3(sensordata(:,3)) sensor4(sensordata(:,4))];
surface_mean = mean(measured_surface, 'omitnan');
%surface_mean = mean(surface_mean);
measured_surface = measured_surface -surface_mean;

sensor_offset = round(frequency*sensor_samplerate); %sensor offset in frames
time = (1:size(measured_surface, 1))/100;
figure;
hold on
surf = measured_surface(:,1);
plot(time, measured_surface(:,1))
LMax = islocalmax(measured_surface(:,1), 'MinSeparation', min_separation);
LMin = islocalmin(measured_surface(:,1), 'MinSeparation', min_separation);
plot(time(LMin), surf(LMin), 'x')
plot(time(LMax), surf(LMax), 'x')
figure;
hold on 
plot(measured_surface(sensor_offset:end,2))
plot(measured_surface(sensor_offset*2:end,3))
plot(measured_surface(sensor_offset*3:end,4))


%%
surf = measured_surface(surface_frame_start:surface_frame_end,:);
mean_amplitude = [];
for i=1:size(surf, 2)
    LMax = islocalmax(surf(:,i), 'MinSeparation', min_separation);
    LMin = islocalmin(surf(:,i), 'MinSeparation', min_separation);
    mean_amplitude = [mean_amplitude (mean(surf(LMax,i))-mean(surf(LMin, i)))/2];
end


%% FFT of the signal
X = fillmissing(sensordata(:,1),'linear');
Y = fft(X);

L = size(sensordata, 1);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
Fs = 100;
f = Fs*(0:(L/2))/L;

figure;
plot(f, P1)
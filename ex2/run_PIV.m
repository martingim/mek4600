function [] = run_PIV(run_number)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%mask images
image_names
n_waves = 3;
for wave=1:n_waves
    image_mask(image_name(run_number, wave*2-1));
    image_mask(image_name(run_number, wave*2));
    disp(run_number)
end

parfor wave=1:n_waves
    perform_PIV(run_number, wave);
end
load gong
sound(y, Fs)

end


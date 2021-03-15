function [] = run_PIV(run_number)
%PIV of one run
%   measks the images and performs PIV of the three waves chosen in image 
%   names from one run. Uses paralell processing toolbox

%mask images
image_names
n_waves = 3;
for wave=1:n_waves
    image_mask(image_name(run_number, wave*2-1));
    image_mask(image_name(run_number, wave*2));
    disp(sprintf('masked images for run %d, wave %d',  run_number, wave))
end

parfor wave=1:n_waves
    perform_PIV(run_number, wave);
end
load gong
sound(y, Fs)

end


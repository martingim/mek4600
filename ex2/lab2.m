close all

n_runs = 15;
n_waves = 3;
max_arrows = 50; %max number of arrows in one dim in the quiver plots
height = 0.33;

%mask images
image_names

for run_number=1:n_runs
    for wave=1:n_waves
        image_mask(image_name(run_number, wave*2-1));
        image_mask(image_name(run_number, wave*2));
        disp(run_number)
    end
end


%Perform the piv passes
tic
parfor run_number=1:n_runs
    for wave=1:n_waves
        fprintf("run nuber:%d, wave number:%d", run_number, wave);
        perform_PIV(run_number, wave);
    end
end
disp('finished all piv passes')
toc

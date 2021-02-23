close all

n_runs = 10;
n_waves = 3;
max_arrows = 50; %max number of arrows in one dim in the quiver plots

for run_number=1:n_runs
    for wave=1:n_waves
        perform_PIV(run_number, wave);
    end
end

plot_velocities(run_number, wave, max_arrows)


% %surface 
% [idx1,eta1] = max(mask1);
% [idx2,eta2] = max(mask2);
% 
% [etax,etay] = tformfwd(tform(ceil(run_number/5)),1:size(im1,2),(eta1+eta2)/2);

close all

n_runs = 15;
n_waves = 3;
max_arrows = 50; %max number of arrows in one dim in the quiver plots

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

%% plotting
run_number = 3;
wave = 3;
plot_alpha(run_number, wave)
mean_alpha
plot_run(run_number)
plot_crest_profile(run_number, wave)
mean_crest_profile
plot_surface
plot_velocities(run_number,wave,50)

% %%old code for calculating sigma
% 
% %% Calculate sigma
% [M, N] = size(Uw);
% sigma = 0;
% m = 0;
% for i=1:M
%     m = m + max(idx(i,:)); % add one if there is a 1 in the mask on this row
%     n = 1e-16;
%     s = 0;
%     for j=1:N
%         if idx(i,j)==1
%             n = n + 1;
%             s = s + (V_norm(i,j)-V_norm_mean(i))^2;
%         end
%         
%     end
%     s = s/n;
%     sigma = sigma + sqrt(s);
% end
% sigma = sigma/m

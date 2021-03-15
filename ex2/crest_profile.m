function [u_crest_scaled, y, crest_mask] = crest_profile(run_number,pair_number)
%Function for finding the horizontal velocity profile under the crest
image_names
%Velocity field name
v_name = sprintf('results/velocities_run%d_wave%d.mat', run_number, pair_number);
%parameter file name
p_name = sprintf('results/params_run%d.mat', run_number);
load(v_name)
load(p_name)
%load parameters for plotting analytical solutions
a = p('a');
k = p('k');
omega = p('omega');
%constants
g = 9.82;
t = 0;
height = heights(run_number);
%analytical solution
[u, v] = analytical_solution(a, k, g, omega, t);

Uw = squeeze(UVw(1,:,:));
Vw = squeeze(UVw(2,:,:));
xw = squeeze(UVw(3,:,:));
yw = squeeze(UVw(4,:,:));
idx = squeeze(UVw(5,:,:));

%% Find the crest
V = Vw;
v_abs = abs(V);
v_mean = ones(size(v_abs, 2), 1);
for i=1:size(v_abs, 2)
    v_mean(i) = mean(v_abs((~isnan(v_abs(i,:))), i));
end


NaN_sides = ones(size(v_mean));%vector to make the values to the left and right sides of the image NaN to find the internal minimum
for i = 1:size(v_mean, 1)
    if i<size(v_mean, 1)*0.25 | i>size(v_mean, 1)*0.75
        NaN_sides(i) = NaN;
    end
end
v_mean = smooth(v_mean,0.05,'rloess');
[ ~, crest_idx] = min(v_mean.*NaN_sides);

% %plot the found horizontal speeds
% figure;
% hold on 
% plot(xw(1,:), v_mean.*NaN_sides, 'r');
% plot(xw(1,crest_idx), 0, 'x')
% title('mean v over y')

%find the velocity profile at the crest

u_crest = Uw(:,crest_idx-1:crest_idx+1);
u_crest = mean(u_crest, 2);
crest_mask = idx(:,crest_idx)&idx(:,crest_idx-1)&idx(:,crest_idx+1);
u_crest = u_crest(crest_mask);
u_crest_scaled = 1/(a*omega)*u_crest;
y = yw(:,crest_idx);
end
function [] = plot_velocities(run_number, pair_number, max_arrows)
%%plots the velocity fields from the folder results based on the rrun
%%number and the wave pair images number 

%Velocity field name
v_name = sprintf('results/velocities_run%d_wave%d.mat', run_number, pair_number);
%parameter file name
p_name = sprintf('results/params_run%d.mat', run_number);

%% load data and parameters
load(v_name)
load(p_name)

%load parameters for plotting analytical solutions
a = p('a');
k = p('k');
omega = p('omega');

%constants
g = 9.82;
t = 0;
scale = 1/(a*g*k)*7/max_arrows;
Uw = squeeze(UVw(1,:,:));
Vw = squeeze(UVw(2,:,:));
xw = squeeze(UVw(3,:,:));
yw = squeeze(UVw(4,:,:));
idx = squeeze(UVw(5,:,:));



[u, v] = analytical_solution(a, k, g, omega, t);

%% make New mask for quiver plots based on max_arows
quiver_idx = idx;

if size(quiver_idx, 2)>max_arrows || size(quiver_idx, 1)>max_arrows
    quiver_idx = zeros(size(quiver_idx));
    if size(quiver_idx, 1)>max_arrows
        interval_x = floor(size(quiver_idx, 1)/max_arrows);
    else
        interval_x = 1;
    end
    if size(quiver_idx, 2)>max_arrows
        interval_y = floor(size(quiver_idx, 2)/max_arrows);
    else
        interval_y = 1;
    end
    
    quiver_idx(1:interval_x:end, 1:interval_y:end) = 1;
    quiver_idx = logical(quiver_idx.*idx);
end
quiver_idx = logical(quiver_idx);

%% Quiver plots
figure;
%World
subplot(1,2,1);
quiver(xw(quiver_idx),yw(quiver_idx),Uw(quiver_idx)*scale,Vw(quiver_idx)*scale, 0);
legend('velocity')
title('world')
xlabel('x[m]')
ylabel('y[m]')
title(sprintf('run %d, wave %d', run_number, pair_number))

%Analytical
subplot(1,2,2)
quiver(xw(quiver_idx), yw(quiver_idx), u(xw(quiver_idx), yw(quiver_idx))*scale, v(xw(quiver_idx), yw(quiver_idx))*scale, 0)
title(sprintf('analyctical solution for run %d', run_number))
xlabel('x[m]')
ylabel('y[m]')



end

function [] = plot_alpha(run_number,pair_number)
%Plot alpha for a single wave 
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
Uw = squeeze(UVw(1,:,:));
Vw = squeeze(UVw(2,:,:));
xw = squeeze(UVw(3,:,:));
yw = squeeze(UVw(4,:,:));
idx = squeeze(UVw(5,:,:));
height = heights(run_number);


%compute alpha
alpha = compute_alpha(Uw, Vw, idx, omega, a, g, k);

y = mean(yw, 2);
y_to_crest = y(y<a); 

%% Alpha plot
figure
hold on

plot(alpha, mean(yw, 2)/height, 'x')
plot(exp(k*y_to_crest), y_to_crest/height)

legend('measured', 'theoretical')
title('Alpha plot')
xlabel('$\alpha$', 'interpreter', 'latex', 'FontSize', 20)
ylabel('$\frac{y}{h}$', 'interpreter', 'latex', 'FontSize', 20, 'rotation', 0)

end


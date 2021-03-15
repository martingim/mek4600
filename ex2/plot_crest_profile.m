function [] = plot_crest_profile(run_number,pair_number)
%plot the velocity profile under the crest
image_names
[u_crest_scaled, yw, crest_mask] = crest_profile(run_number, pair_number);
p_name = sprintf('results/params_run%d.mat', run_number);
load(p_name)
%load parameters for plotting analytical solutions
a = p('a');
k = p('k');
omega = p('omega');
%constants
g = 9.82;
t = 0;
height = heights(run_number);
y_scaled = yw(crest_mask)/height;
%analytical solution
[u, v] = analytical_solution(a, k, g, omega, t);

figure;
hold on 

plot(u_crest_scaled, y_scaled, 'x')
plot(1/(a*omega)*u(0, yw(crest_mask)), y_scaled);

legend('measured', 'theoretical')
title('theoretical and measured horizontal velocity under the crest')

xlabel('$\frac{v}{a\omega}$', 'interpreter', 'latex', 'FontSize', 20)
ylabel('$\frac{y}{h}$', 'interpreter', 'latex', 'FontSize', 20, 'rotation', 0)
end
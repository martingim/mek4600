function [alpha, t_alpha, y_scaled] = plot_alpha(run_number,pair_number)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
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
height = 0.33;

%remove some idx
idx_ = zeros(size(idx));
idx_(2:end-2,3:end-3) = idx(1:end-3,3:end-3);
idx = idx_;


%%  analytical solution
%potential of wave moving to the right
%phi = a*g/omega*exp(k*y)*sin(k*x-omega*t);
u = @(x, y) a*k*g/omega*exp(k*y).*cos(k*x-omega*t);
v = @(x, y) a*k*g/omega*exp(k*y).*sin(k*x-omega*t);


%% Find the crest
figure;
V = Vw;
v_abs = abs(V);
v_mean = ones(size(v_abs, 2), 1);
for i=1:size(v_abs, 2)
    v_mean(i) = mean(v_abs((~isnan(v_abs(i,:))), i));
end


NaN_sides = ones(size(v_mean));%vector to make the values to the left and right sides of the image NaN to find the internal minimum
for i = 1:size(v_mean, 2)
    if i<size(v_mean, 2)*0.25 || i>size(v_mean, 2)*0.75
        NaN_sides(i) = NaN;
    end
end

[ ~, crest_idx] = min(v_mean.*NaN_sides);
plot(xw(1,:), v_mean, 'r');
title('mean v over y')

%find the velocity profile at the crest

u_crest = Uw(:,crest_idx-1:crest_idx+1);
u_crest = mean(u_crest, 2);
u_crest = Uw(:,crest_idx);
u_crest = u_crest(idx(:,crest_idx)&idx(:,crest_idx-1)&idx(:,crest_idx+1));
crest_mask = idx(:,crest_idx)&idx(:,crest_idx-1)&idx(:,crest_idx+1);
u_crest_scaled = 1/(a*omega)*u_crest;
y_scaled = 1/height*yw(crest_mask);

figure;
hold on 
plot(u_crest_scaled, y_scaled, 'x')
plot(1/(a*omega)*u(xw(crest_mask)*0, yw(crest_mask)), y_scaled);

legend('measured', 'theoretical')
title('theoretical and measured horizontal velocity under the crest')

xlabel('$\frac{v}{a\omega}$', 'interpreter', 'latex', 'FontSize', 20)
ylabel('$\frac{y}{h}$', 'interpreter', 'latex', 'FontSize', 20, 'rotation', 0)



%% Alpha plot

%compute alpha
[M, N] = size(Uw);
V_norm = (Uw.^2 + Vw.^2).^0.5;
V_norm_mean = zeros(M,1)*NaN;

for i=1:M
    n = 0;
    s = 0;
    for j=1:N
        if idx(i,j)==1
            n = n + 1;
            s = s + V_norm(i,j);
        end
    end 
    V_norm_mean(i) = s/n;
end

alpha = omega/(a*g*k)*V_norm_mean;

figure
hold on
y_to_crest = yw(yw(:,1)<a, crest_idx);
plot(alpha, yw(:,crest_idx)/height, 'x')
plot(exp(k*y_to_crest), y_to_crest/height)
legend('measured', 'theoretical')
title('Alpha plot')
xlabel('$\alpha$', 'interpreter', 'latex', 'FontSize', 20)
ylabel('$\frac{y}{h}$', 'interpreter', 'latex', 'FontSize', 20, 'rotation', 0)

t_alpha = exp(k*y_to_crest);
y_scaled = y_to_crest/height;

end


function [y_scaled, u_crest_scaled, alpha, crest_mask] = plot_velocities(run_number, pair_number, max_arrows)
%%plots the velocity fields from the folder results based on the rrun
%%number and the wave pair images number 


height = 0.33;

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



%%  analytical solution
%potential of wave moving to the right
%phi = a*g/omega*exp(k*y)*sin(k*x-omega*t);
u = @(x, y) a*k*g/omega*exp(k*y).*cos(k*x-omega*t);
v = @(x, y) a*k*g/omega*exp(k*y).*sin(k*x-omega*t);


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


% %% Velocity profile
% 
% %find the crest
% figure;
% %V(isnan(Uw))=0;
% v_abs = abs(V);
% v_mean = ones(size(v_abs, 2), 1);
% for i=1:size(v_abs, 2)
%     v_mean(i) = mean(v_abs((~isnan(v_abs(i,:))), i));
% end
% 
% NaN_sides = ones(size(v_mean));%vector to make the values to the left and right sides of the image NaN to find the internal minimum
% for i = 1:size(v_mean, 2)
%     if i<size(v_mean, 2)*0.25 || i>size(v_mean, 2)*0.75
%         NaN_sides(i) = NaN;
%     end
% end
% 
% [ ~, crest_idx] = min(v_mean.*NaN_sides);
% plot(xw(1,:), v_mean, 'r');
% title('mean v over y')
% 
% %find the velocity profile at the crest
% 
% u_crest = Uw(:,crest_idx-1:crest_idx+1);
% u_crest = mean(u_crest, 2);
% u_crest = Uw(:,crest_idx);
% u_crest = u_crest(idx(:,crest_idx)&idx(:,crest_idx-1)&idx(:,crest_idx+1));
% crest_mask = idx(:,crest_idx)&idx(:,crest_idx-1)&idx(:,crest_idx+1);
% u_crest_scaled = 1/(a*omega)*u_crest;
% y_scaled = 1/height*yw(crest_mask);
% 
% figure;
% hold on 
% plot(u_crest_scaled, y_scaled, 'x')
% plot(1/(a*omega)*u(xw(crest_mask)*0, yw(crest_mask)), y_scaled);
% 
% legend('measured', 'theoretical')
% title('theoretical and measured horizontal velocity under the crest')
% 
% xlabel('$\frac{v}{a\omega}$', 'interpreter', 'latex', 'FontSize', 20)
% ylabel('$\frac{y}{h}$', 'interpreter', 'latex', 'FontSize', 20, 'rotation', 0)


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

end

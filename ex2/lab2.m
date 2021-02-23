close all

n_runs = 10;
n_waves = 3;
max_arrows = 50; %max number of arrows in one dim in the quiver plots
height = 0.33;
for run_number=6:n_runs
    for wave=1:n_waves
        perform_PIV(run_number, wave);
    end
end



%surface 
[idx1,eta1] = max(mask1);
[idx2,eta2] = max(mask2);

[etax,etay] = tformfwd(tform(ceil(run_number/5)),1:size(im1,2),(eta1+eta2)/2);

load('velocities.mat')
load('params.mat')
run_number = 8;
alpha = containers.Map('KeyType', 'double', 'ValueType', 'any');
crest_mask = containers.Map('KeyType', 'double', 'ValueType', 'any');
y_scaled = containers.Map('KeyType', 'double', 'ValueType', 'any');
for wave = 1:3
    [y_scaled(wave), u_crest_scaled, alpha(wave), crest_mask(wave)] = plot_velocities(run_number, wave, 50);
    close all
end
%%
alpha_mean = (alpha(1) + alpha(2) + alpha(3))/3;
mask = crest_mask(1)&crest_mask(2)&crest_mask(3);
y = y_scaled(3);
plot(alpha_mean(mask), y(:,1), 'x')
hold on 
y1 = y_scaled(1);
y2 = y_scaled(2);
y3 = y_scaled(3);
a1 = alpha(1);
a2 = alpha(2);
a3 = alpha(3);







plot(a1(crest_mask(1)), y1(:,1), 'x')
plot(a2(crest_mask(2)), y2(:,1), 'x')
plot(a3(crest_mask(3)), y3(:,1), 'x')
p = params(run_number);
k = p('k');
a = p('a');
plot(exp(k*y1(:,1)*height), y1(:,1))
legend('mean', '1', '2', '3', 'analytical')



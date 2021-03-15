close all
%constants
image_names
g = 9.82;
t = 0;


alpha_mean = containers.Map('KeyType', 'double', 'ValueType', 'any');
params = containers.Map('KeyType', 'double', 'ValueType', 'any');
ak = zeros(15, 1);
kh = zeros(15, 1);
for i=1:size(run_numbers_same_params, 1)
    alpha_run_mean = containers.Map('KeyType', 'double', 'ValueType', 'any');
    for j=1:size(run_numbers_same_params, 2)
        run_params = containers.Map;
        run_number = run_numbers_same_params(i, j);
        %parameter file name
        p_name = sprintf('results/params_run%d.mat', run_number);
        
        load(p_name)
        %load parameters for plotting analytical solutions
        a = p('a');
        run_params('a') = a;
        params(run_number) = run_params;
        k = p('k');
        ak(run_number) = a*k;
        omega = p('omega');
        height = heights(run_number);
        kh(run_number) = k*height;
        v_name1 = sprintf('results/velocities_run%d_wave%d.mat', run_number, 1);
        v_name2 = sprintf('results/velocities_run%d_wave%d.mat', run_number, 2);
        v_name3 = sprintf('results/velocities_run%d_wave%d.mat', run_number, 3);
        
        
        load(v_name1)
        yw = squeeze(UVw(4,:,:));
        U1 = squeeze(UVw(1,:,:));
        V1 = squeeze(UVw(2,:,:));
        idx1 = squeeze(UVw(5,:,:));
        load(v_name2)
        U2 = squeeze(UVw(1,:,:));
        V2 = squeeze(UVw(2,:,:));
        idx2 = squeeze(UVw(5,:,:));
        load(v_name3)
        U3 = squeeze(UVw(1,:,:));
        V3 = squeeze(UVw(2,:,:));
        idx3 = squeeze(UVw(5,:,:));
        alpha1 = compute_alpha(U1, V1, idx1, omega, a, g, k);
        alpha2 = compute_alpha(U2, V2, idx2, omega, a, g, k);
        alpha3 = compute_alpha(U3, V3, idx3, omega, a, g, k);
        alpha = (alpha1 + alpha2 + alpha3)/3;
        figure;
        hold on 
        plot(alpha, yw(:,1)/0.33, 'x')
        y_to_crest = squeeze(yw(yw(:,1)<a, 60));
        plot(exp(k*y_to_crest), y_to_crest/height)
        title(sprintf('run %d mean alpha over three waves', run_number))
        
        alpha_run_mean(j) = alpha;
        
    end
    alpha_run_mean(4) = exp(k*y_to_crest);
    alpha_run_mean(5) = y_to_crest;
    alpha_mean(i) = alpha_run_mean;
    
end

figure;
for i=1:size(run_numbers_same_params, 1)
    par_alpha = alpha_mean(i);
    alpha1 = par_alpha(1);
    alpha2 = par_alpha(2);
    alpha3 = par_alpha(3);
    alpha = (alpha1 + alpha2 + alpha3)/3;
    y_to_crest = par_alpha(5);
    subplot(3,2,i)
    hold on 
    plot(par_alpha(4), y_to_crest*0.33)
    plot(alpha, yw(:,1)*0.33, 'x')
    title(sprintf('mean alpha over runs:%d, %d, %d', run_numbers_same_params(i, 1), run_numbers_same_params(i, 2), run_numbers_same_params(i, 3)))
    xlabel('$\alpha$', 'interpreter', 'latex', 'FontSize', 20)
    ylabel('$\frac{y}{h}$', 'interpreter', 'latex', 'FontSize', 20, 'rotation', 0)
    legend('analytical','mean of the measured alpha', 'Location', 'southeast')
    
end



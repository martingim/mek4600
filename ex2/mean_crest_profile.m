% For plotting the mean of the velocity profiles under the crest
close all
image_names
profile_mean = containers.Map('KeyType', 'double', 'ValueType', 'any');
for run_number=1:15
    p_name = sprintf('results/params_run%d.mat', run_number);
    load(p_name)
    a = p('a');
    k = p('k');
    omega = p('omega');
    [u_crest_scaled, yw, crest_mask] = crest_profile(run_number, 1);
    u_mean = u_crest_scaled./3;

    for wave=2:3
        [u_crest_scaled, yw, mask] = crest_profile(run_number, wave);
        crest_mask = crest_mask&mask;
        size_diff = size(u_crest_scaled,1)-size(u_mean, 1);
        if size_diff>0;
            u_mean = [zeros(size_diff, 1);u_mean];
        elseif size_diff<0;
            u_crest_scaled = [zeros(-size_diff, 1); u_crest_scaled];
        end
        u_mean = u_mean + u_crest_scaled./3;
    end
    profile_mean(run_number) = u_mean;
    figure;
    hold on
    start = size(u_mean, 1) - sum(crest_mask);
    plot(u_mean(1+start:end), yw(crest_mask)/height, 'x')
    [u, v] = analytical_solution(a, k, g, omega, t);
    plot(1/(a*omega)*u(0, yw(crest_mask)), yw(crest_mask)/height)
    legend('measured', 'theoretical')
    title(sprintf('run %d mean velocity profile', run_number));

    xlabel('$\frac{v}{a\omega}$', 'interpreter', 'latex', 'FontSize', 20)
    ylabel('$\frac{y}{h}$', 'interpreter', 'latex', 'FontSize', 20, 'rotation', 0)

end


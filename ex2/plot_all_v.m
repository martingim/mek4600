function [] = plot_all_v()
%plot all velocities from all runs
%   makes quiver plots for all the runs and waves with max 50 arrows in
%   each dimension

close all

n_runs = 15;
for run_number = 1:n_runs
    plot_run(run_number)
end

end


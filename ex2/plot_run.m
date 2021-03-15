function [] = plot_run(run_number)
%plots the velocities from all three waves from the run
%with max 50 arrows in the quiver plot
plot_velocities(run_number, 1, 50);
plot_velocities(run_number, 2, 50);
plot_velocities(run_number, 3, 50);
end


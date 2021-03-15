%plot a small part of the surface elevation compared to linear and non
%linear theory for all the runs in one figure.

image_names
                  
for i=1:size(run_numbers_same_params)
    subplot(3,2, i)
    surface_height(run_numbers_same_params(i, 1));
end
legend('linear', 'non-linear', 'mean of the smoothed sensor data', 'Location', 'southeastoutside')
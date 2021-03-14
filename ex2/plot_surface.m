run_numbers_same_params = [1 5 12;
                            2 10 13;
                            3 8 15;
                            4 9 14;
                            6 7 11];
figure;
close all
hold on                   
for i=1:size(run_numbers_same_params)
    subplot(3,2, i)
    surface_height(run_numbers_same_params(i, 1))
end
legend('linear', 'non-linear', 'mean of the smoothed sensor data', 'Location', 'southeastoutside')
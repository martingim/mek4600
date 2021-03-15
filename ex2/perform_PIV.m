function [UVw, p] = perform_PIV(run_number, pair_number)
%%perform the piv passes 

%read images and constants

image_names
coord_config
im1_name = image_name(run_number, pair_number*2-1);
im2_name = image_name(run_number, pair_number*2);
im1 = imread(im1_name);
im2 = imread(im2_name);


height = heights(run_number);
f = frequency(run_number);
[omega,T,k,LAMBDA,CP,CG]=wparam(f,height);

%a = surface_height(run_number); % run the surface height script to find the amplitude
dt = 1/60;     %based on the framerate of the videos
if run_number ==1
    dt = 1/125;
end

g = 9.81;
t = 0;

window_sizes = [128 64 48 38];
window_overlap = [0.75 0.75 0.75 0.5 0.5 0.5];

%try to load the image masks 
mask1 = image_mask(im1_name);
mask2 = image_mask(im2_name);

%% Perform PIV passes
piv1 = [];
for i= 1:size(window_sizes, 2)
    search_range = [-round(window_sizes(i)/3) round(window_sizes(i)/3) -round(window_sizes(i)/3) round(window_sizes(i)/3)];

    opt = setpivopt('range',search_range,'subwindow',window_sizes(i),window_sizes(i),window_overlap(i));
    piv1 = normalpass(piv1,im1,mask1,im2,mask2,opt);
    [piv.U, piv.V, x, y] = replaceoutliers(piv1);
    piv2 = piv1;
end

U = piv1.U;
V = piv1.V;


%Convert to world coordinates
[Uw, Vw, xw, yw] = pixel2world(tform(ceil(run_number/5)), U, V, x, y, dt);

idx = interp2(double(mask1&mask2),piv1.x,piv1.y)==1;


UVw(1,:,:) = Uw;
UVw(2,:,:) = Vw;
UVw(3,:,:) = xw;
UVw(4,:,:) = yw;
UVw(5,:,:) = idx;

save(sprintf('results/velocities_run%d_wave%d.mat', run_number, pair_number), 'UVw');

p = containers.Map;
p('a') = surface_height(run_number);
p('k') = k;
p('omega') = omega;

save(sprintf('results/params_run%d', run_number), 'p');


end
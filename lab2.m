%read images and constants
clear
close all
height_config

run_folder = "MEK4600_G3_21_10_02/2021-02-10_run2_C001H001S0001/";
image_name = '2021-02-10_run2_C001H001S0001000';
image_number1 = '020';
image_number2 = '021';
im1 = imread(run_folder + image_name + image_number1 +'.bmp');
im2 = imread(run_folder + image_name + image_number2 +'.bmp');
coord_name = '2021-02-10_coordinationphoto_C001H001S0001000001.bmp';

height_from_surface = 0.008; %the height from the free surface to the top coordinate dots
height = 0.6;
frequency = 1.75;

surface_height % run the surface height script to find the amplitude
dt = 1/60;
a = mean(mean_amplitude);
k = 12.32;
g = 9.81;
t = 0;
omega = 2*pi*frequency;

window_sizes = [64 32];
window_overlap = [0.5 0.5 0.5 0.5 0.5 0.5];
scale = 3;
max_arrows = 50; %maximum number of arrows in the quiver plots

coord = imread(coord_name);

x0 = 73;
x1 = 1988;
y0 = 398;
y0 = 472;
y1 = 2020;
[x_pos, y_pos] = ndgrid(round(x1:(x0-x1)/26:x0), round(y1:(y0-y1)/21:y0));
pixel = [reshape(x_pos, [], 1) reshape(y_pos, [], 1)];

%refine pixel positions
c = graythresh(coord);
bw = im2bw(coord, 0.9);
cc = bwconncomp(bw);
stats = regionprops(cc,'Centroid');
xc = vertcat(stats.Centroid);
idx = knnsearch(xc,pixel);
pixel = xc(idx,:);

% Define matching reference points in world coordinate
[wx,wy] = ndgrid((13:-1:-13)*0.01,(-22:1:-1)*0.01-height_from_surface);
%[wx,wy] = ndgrid((1:-1:-1)*0.01,(-1:1:1)*0.01-height_from_surface);
world = [wx(:) wy(:)];
[tform, err, env] = createcoordsystem(pixel, world, 'cubic');







%%
%analytical solution
%potential of wave moving to the left
%phi = a*g/omega*exp(k*y)*sin(-k*x-omega*t);
u = @(x, y) a*k*g/omega*exp(k*y).*cos(k*x-omega*t);
v = @(x, y) a*k*g/omega*exp(k*y).*sin(k*x-omega*t);
if exist('mask1', 'var')&&exist('mask2', 'var')==1

else
    mask1 = mask_image(flipud(im1));
    mask2 = mask_image(flipud(im2));
end

%make pixel to world transform
if exist('tform', 'var') ==1

else
    coord = imread(coord_name);
    imagesc(coord)
    h = impoly;
    title('select from top right towards left')
    pixel = h.getPosition;
    
    %refine pixel positions
    c = graythresh(coord);
    bw = im2bw(coord);
    cc = bwconncomp(bw);
    stats = regionprops(cc,'Centroid');
    xc = vertcat(stats.Centroid);
    idx = knnsearch(xc,pixel);
    pixel = xc(idx,:);
    
    % Define matching reference points in world coordinate
    [wx,wy] = ndgrid((10:-5:-10)*0.01,(-10:5:-5)*0.01);
    world = [wx(:) wy(:)];
    [tform, err, env] = createcoordsystem(pixel, world, 'linear');
end

% Perform PIV passes
piv1 = [];
for i= 1:size(window_sizes, 2)
    search_range = [-round(window_sizes(i)/3) round(window_sizes(i)/3) -round(window_sizes(i)/3) round(window_sizes(i)/3)];

    opt = setpivopt('range',search_range,'subwindow',window_sizes(i),window_sizes(i),window_overlap(i));
    piv1 = normalpass(piv1,im1,mask1,im2,mask2,opt);
    piv2 = piv1;
end

%Replace outliers
[U,V, x, y] = replaceoutliers(piv1);

%Convert to world coordinates
[Uw, Vw, xw, yw] = pixel2world(tform, U, V, x, y, dt);

%surface 
[idx1,eta1] = max(mask1);
[idx2,eta2] = max(mask2);

[etax,etay] = tformfwd(tform,1:size(im1,2),(eta1+eta2)/2);
%% Plot velocities 


idx = interp2(double(mask1&mask2),piv1.x,piv1.y)==1;
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

%World
figure;
hold on;
quiver(xw(quiver_idx),yw(quiver_idx),Uw(quiver_idx),Vw(quiver_idx), scale);
plot(etax(1:end-3),etay(1:end-3),'r');
legend('velocity', 'surface')
title('world')
xlabel('x[m]')
ylabel('y[m]')
hold off;

%Pixel
figure;
hold on
set(gca,'Ydir','reverse')
quiver(x(quiver_idx),y(quiver_idx),U(quiver_idx),V(quiver_idx),scale);
plot(1:size(im1, 2), eta1, 'r');
title('pixel')
hold off

%Analytical
figure;
quiver(xw(quiver_idx), yw(quiver_idx), u(xw(quiver_idx), yw(quiver_idx)), v(xw(quiver_idx), yw(quiver_idx)), scale)
title('analyctical')
xlabel('x[m]')
ylabel('y[m]')

%find the crest
figure;
V(isnan(V))=0;
v_abs = abs(V);
v_mean = mean(v_abs, 1);
[v_min, crest_idx] = min(v_mean(3:end-2));
plot(xw(1,3:end-2), v_mean(3:end-2), 'r');
title('mean v over y')

%find the velocity profile at the crest
figure;
hold on 
u_crest = Uw(:,crest_idx-1:crest_idx+1);
u_crest = mean(u_crest, 2);
u_crest = u_crest(idx(:,crest_idx)&idx(:,crest_idx-1)&idx(:,crest_idx+1));
crest_mask = idx(:,crest_idx)&idx(:,crest_idx-1)&idx(:,crest_idx+1);
plot(u_crest, yw(crest_mask), 'x')
plot(u(xw(crest_mask)*0, yw(crest_mask)), yw(crest_mask));
title('theoretical and measured horizontal velocity under the crest')
legend('measured', 'theoretical')
xlabel('v[m/s]')
ylabel('y[m]')

figure;
hold on 
u_crest_scaled = 1/(a*omega)*u_crest;
y_scaled = 1/height*yw(crest_mask);
plot(u_crest_scaled, y_scaled, 'x')
plot(1/(a*omega)*u(xw(crest_mask)*0, yw(crest_mask)), y_scaled);

legend('measured', 'theoretical')

title('scaled velocity and water depth')
xlabel('$\frac{v}{a\omega}$', 'interpreter', 'latex', 'FontSize', 20)
ylabel('$\frac{y}{h}$', 'interpreter', 'latex', 'FontSize', 20, 'rotation', 0)

%%
[M, N] = size(Uw);
V = zeros(M,1)*NaN;

for i=1:M
    n = 0;
    s = 0;
    for j=1:N
    
        if idx(i,j)==1
            n = n + 1;
            s = s + (Uw(i,j)^2+Vw(i,j)^2)^0.5;
        end
    end 
    V(i) = s/n;
    
end
alpha = omega/(a*g*k)*V;
figure
hold on
y_to_crest = yw(yw(:,1)<0.02, crest_idx);
plot(alpha, yw(:,crest_idx)/height, 'x')
plot(exp(k*y_to_crest), y_to_crest/height)
legend('measured', 'theoretical')
title('Alpha plot')
xlabel('$\alpha$', 'interpreter', 'latex', 'FontSize', 20)
ylabel('$\frac{y}{h}$', 'interpreter', 'latex', 'FontSize', 20, 'rotation', 0)
%%
V = (Uw.^2+Vw.^2).^0.5;
V_mean = mean(V, 2);
sigma = mean(sqrt(mean((V-V_mean).^2, 1)), 2);
sigma
sigma = 0;
m = 0;
for i=1:M
    m = m + 1;
    n = 1e-16;
    s = 0;
    for j=1:N
        if idx(i,j)==1
            n = n + 1;
            s = s + (V(i,j)-V_mean(i))^2;
        end
        
    end
    s = s/n
    sigma = sigma + sqrt(s);
end
sigma = sigma/m










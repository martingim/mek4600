%read images and constants

close all
height_config
image_names
coord_config
run_number = 3;
im1 = imread(image_name(run_number, 1));
im2 = imread(image_name(run_number, 2));
mask1_name = image_name(run_number, 1) + ".mask.mat";
mask2_name = image_name(run_number, 2) + ".mask.mat";


height = 0.33;
f = frequency(run_number);
[omega,T,k,LAMBDA,CP,CG]=wparam(f,height);

surface_height % run the surface height script to find the amplitude
dt = 1/60;     %based on the framerate of the videos
a = mean(mean_amplitude); %the mean of the amplitudes found from the four sensors
g = 9.81;
t = 0;

window_sizes = [64 32];
window_overlap = [0.5 0.5 0.5 0.5 0.5 0.5];
scale = 3;
max_arrows = 50; %maximum number of arrows in the quiver plots


%%
%analytical solution
%potential of wave moving to the left
%phi = a*g/omega*exp(k*y)*sin(-k*x-omega*t);
u = @(x, y) a*k*g/omega*exp(k*y).*cos(k*x-omega*t);
v = @(x, y) a*k*g/omega*exp(k*y).*sin(k*x-omega*t);

%try to load the image masks 
try
    load(mask1_name)
    load(mask2_name)
catch %if it doesn't work mask and save the mask.
    mask1 = mask_image(flipud(im1));
    mask2 = mask_image(flipud(im2));
    save(mask1_name, 'mask1')
    save(mask2_name, 'mask2')
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
[Uw, Vw, xw, yw] = pixel2world(tform(ceil(run_number/5)), U, V, x, y, dt);

%surface 
[idx1,eta1] = max(mask1);
[idx2,eta2] = max(mask2);

[etax,etay] = tformfwd(tform(ceil(run_number/5)),1:size(im1,2),(eta1+eta2)/2);
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
V_ = V;
V_(isnan(V))=0;
v_abs = abs(V_);
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
V_norm_mean = zeros(M,1)*NaN;

for i=1:M
    n = 0;
    s = 0;
    for j=1:N
    
        if idx(i,j)==1
            n = n + 1;
            s = s + (Uw(i,j)^2+Vw(i,j)^2)^0.5;
        end
    end 
    V_norm_mean(i) = s/n;
    
end
alpha = omega/(a*g*k)*V_norm_mean;
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
V_norm = (Uw.^2+Vw.^2).^0.5;
V_mean = mean(V_norm, 2);
sigma = mean(sqrt(mean((V_norm-V_mean).^2, 1)), 2);
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
            s = s + (V_norm(i,j)-V_mean(i))^2;
        end
        
    end
    s = s/n
    sigma = sigma + sqrt(s);
end
sigma = sigma/m










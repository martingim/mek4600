%% script for making the coordinate transforms from pixel to world
%makes the transform by guessing the points to be in a grid and then using
%a knn search to find the middle of the points in the photo.
close all
coord_name1 = "MEK4600_G3_21_10_02/2021-02-10_coordinationphoto_C001H001S0001000001.bmp";
coord_name2 = "MEK4600_G3_21_17_02/2021-02-17_coordinationphoto_C001H001S0001000001.bmp";
coord_name3 = "MEK4600_G3_21_24_02/2021-02-24_coordphoto_C001H001S0001000001.bmp";

coord = imread(coord_name1);

x0 = 73;
x1 = 1988;
y0 = 472;
y1 = 2020;
yr = 400;
x_points = 27;

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
[wx,wy] = ndgrid((13:-1:-13)*0.01,(-21:1:0)*0.01);
world = [wx(:) wy(:)];
[tform1, err, env] = createcoordsystem(pixel, world, 'cubic');
%show coord image and chosen poinbts
% imshow(coord)
% hold on 
% plot(pixel(:,1),pixel(:,2), 'x')


%Find height from the surface to the top points under water
%by using the mean of the y location of the top points under water and
%their reflections

%top points in pixel 
points_x = round(x1:(x0-x1)/(x_points-1):x0);
t_points_y = ones(x_points, 1)*y0;
r_points_y = ones(x_points, 1)*yr;

t_points = [points_x' t_points_y];
reflec_points = [points_x' r_points_y];

idx = knnsearch(xc,t_points);
t_points = xc(idx,:);

idx = knnsearch(xc,reflec_points);
reflec_points = xc(idx,:);
%plot(reflec_points(:,1), reflec_points(:,2), 'xb')


reflection = tformfwd(tform1, reflec_points);
t_points = tformfwd(tform1, t_points);
height_from_surface = mean((reflection(:,2) + t_points(:,2))/2);
%make the transform again

[wx,wy] = ndgrid((13:-1:-13)*0.01,(-21:1:0)*0.01 - height_from_surface);
world = [wx(:) wy(:)];
[tform1, err, env] = createcoordsystem(pixel, world, 'cubic');





%% coordinate system from second lab day 
coord2 = imread(coord_name2);

%approximate dot positions in pixel location
x0 = 21;
x1 = 1836;
y0 = 470;
y1 = 2041;
yr = 389;
x_points = 25;
y_points = 22;
[x_pos, y_pos] = ndgrid(round(x1:(x0-x1)/(x_points-1):x0), round(y1:(y0-y1)/(y_points-1):y0));
pixel = [reshape(x_pos, [], 1) reshape(y_pos, [], 1)];

%refine pixel positions
c = graythresh(coord2);
bw = im2bw(coord2, 0.9);
cc = bwconncomp(bw);
stats = regionprops(cc,'Centroid');
xc = vertcat(stats.Centroid);
idx = knnsearch(xc,pixel);
pixel2 = xc(idx,:);
 
%show the initial dot guess and refined positions
% imshow(bw)
% hold on
% plot(pixel(:,1), pixel(:,2), 'rx')
% plot(pixel2(:,1), pixel2(:,2), 'yx')

% Define matching reference points in world coordinate
[wx,wy] = ndgrid((12:-1:-12)*0.01,(-21:1:0)*0.01);

world = [wx(:) wy(:)];
[tform2, err, env] = createcoordsystem(pixel2, world, 'cubic');


%Find height from the surface to the top points under water
%by using the mean of the y location of the top points under water and
%their reflections

%top points in pixel 
points_x = round(x1:(x0-x1)/(x_points-1):x0);
t_points_y = ones(x_points, 1)*y0;
r_points_y = ones(x_points, 1)*yr;

t_points = [points_x' t_points_y];
reflec_points = [points_x' r_points_y];
idx = knnsearch(xc,t_points);
t_points = xc(idx,:);

idx = knnsearch(xc,reflec_points);
reflec_points = xc(idx,:);
% plot(reflec_points(:,1), reflec_points(:,2), 'xb')

reflection = tformfwd(tform2, reflec_points);
t_points = tformfwd(tform2, t_points);
height_from_surface = mean((reflection(:,2) + t_points(:,2))/2);
%make the transform again

[wx,wy] = ndgrid((12:-1:-12)*0.01,(-21:1:0)*0.01 - height_from_surface);
world = [wx(:) wy(:)];
[tform2, err, env] = createcoordsystem(pixel2, world, 'cubic');




%% coordinate system from third lab day
coord3 = imread(coord_name3);

%approximate dot positions in pixel location
x0 = 8;
x1 = 1995;
y0 = 468;
y1 = 2020;
yr = 420;
x_points = 28;
y_points = 22;
[x_pos, y_pos] = ndgrid(round(x1:(x0-x1)/(x_points-1):x0), round(y1:(y0-y1)/(y_points-1):y0));
pixel = [reshape(x_pos, [], 1) reshape(y_pos, [], 1)];

%refine pixel positions
c = graythresh(coord3);
bw = im2bw(coord3, 0.9);
cc = bwconncomp(bw);
stats = regionprops(cc,'Centroid');
xc = vertcat(stats.Centroid);
idx = knnsearch(xc,pixel);
pixel3 = xc(idx,:);
 
%show the initial dot guess and refined positions
% imshow(bw)
% hold on
% plot(pixel(:,1), pixel(:,2), 'rx')
% plot(pixel3(:,1), pixel3(:,2), 'yx')

% Define matching reference points in world coordinate
[wx,wy] = ndgrid((14:-1:-13)*0.01,(-21:1:0)*0.01);
world = [wx(:) wy(:)];
[tform3, err, env] = createcoordsystem(pixel3, world, 'cubic');



%Find height from the surface to the top points under water
%by using the mean of the y location of the top points under water and
%their reflections

%top points in pixel 
points_x = round(x1:(x0-x1)/(x_points-1):x0);
t_points_y = ones(x_points, 1)*y0;
r_points_y = ones(x_points, 1)*yr;

t_points = [points_x' t_points_y];
reflec_points = [points_x' r_points_y];

idx = knnsearch(xc,t_points);
t_points = xc(idx,:);

idx = knnsearch(xc,reflec_points);
reflec_points = xc(idx,:);


reflection = tformfwd(tform3, reflec_points);
t_points = tformfwd(tform3, t_points);
height_from_surface = mean((reflection(:,2) + t_points(:,2))/2);
%make the transform again

[wx,wy] = ndgrid((14:-1:-13)*0.01,(-21:1:0)*0.01 - height_from_surface);
world = [wx(:) wy(:)];
[tform3, err, env] = createcoordsystem(pixel3, world, 'cubic');



%%
tform = [tform1 tform2 tform3];

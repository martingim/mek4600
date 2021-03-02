function [mask] = image_mask(img_name)
%Loads image mask from file or creates mask and saves it to file
mask_name = img_name + "mask.mat";
try
    load(mask_name)
catch %if it doesn't work mask and save the mask.
    figure;
    set(gca,'Ydir','normal')
    img = imread(img_name);
    imagesc(img);
    h = impoly();
    mask = h.createMask();
    save(mask_name, 'mask')
end


end


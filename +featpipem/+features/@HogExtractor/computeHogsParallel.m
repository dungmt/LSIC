function [ results ] = computeHogsParallel( input, image_root, reshape_size, binsize, hogsize )
% https://code.google.com/p/webcam-classifier-toolbox/source/browse/trunk/data_management_code/computeHogsParallel.m?r=74
% Note: need to pass in the extra variables, as matlab starts throwing
% transparency errors if you just call load_settings

% This code also assumes that matlabpool stuff is handled elsewhere

disp('Compute_hogs_parallel: Calculating hog features');
parfor ix = 1:length(input)
    fn = strcat(image_root, sprintf('%08d',input(ix).cam_id), '/', num2str(input(ix).day), '_', num2str(input(ix).hour, '%06d'), '.jpg');
    %disp(fn);
    img = imread(fn);
    disp(['ComputeHogsParallel: ' num2str(size(input(ix).ppl_rects,1)+size(input(ix).bg_rects,1)) ' features']);
    
    ppl_rect = num2cell(input(ix).ppl_rects, 2); % gather rows into each element of cell
    ppl_hogs = cellfun(@(x) calc_hog(img, x, reshape_size, binsize), ppl_rect, 'UniformOutput', false);
    input(ix).ppl_hogs = reshape(cell2mat(ppl_hogs), [hogsize length(ppl_hogs)])';
    
    bg_rect = num2cell(input(ix).bg_rects, 2); % gather rows into each element of cell
    bg_hogs = cellfun(@(x) calc_hog(img, x, reshape_size, binsize), bg_rect, 'UniformOutput', false);
    input(ix).bg_hogs = reshape(cell2mat(bg_hogs), [hogsize length(bg_hogs)])';
end

results = input;
disp('ComputeHogsParallel: Done. ');
end

function [out] = calc_hog(img, rect, reshape_size, binsize)
x = rect(1);
y = rect(2);
xx= x + rect(3);
yy= y + rect(4);
img_rectangle = img(y:yy, x:xx, :);
img_rectangle = imresize(img_rectangle, reshape_size);
hh = vl_hog(single(img_rectangle), binsize);
out = reshape(hh, [size(hh,1)*size(hh,2)*size(hh,3), 1, 1]);
end

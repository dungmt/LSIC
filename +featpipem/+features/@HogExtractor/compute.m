function [hog] = compute(obj, im)
%COMPUTE Summary of this function goes here
%   Detailed explanation goes here

    if obj.numOrientations>0
        hog = vl_hog(im, obj.cellSize, 'verbose', 'numOrientations', obj.numOrientations) ;
    elseif obj.variant==true
        hog = vl_hog(im, obj.cellSize, 'verbose', 'variant', 'dalaltriggs') ;
    else
        hog = vl_hog(im, obj.cellSize, 'verbose') ;
    end
    hog = reshape(hog, [size(hog,1)*size(hog,2)*size(hog,3), 1, 1]);
    
end


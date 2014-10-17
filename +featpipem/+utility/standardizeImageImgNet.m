function im = standardizeImageImgNet(im)
%STANDARDIZEIMAGE Summary of this function goes here
%   NOTE: all PASCAL VOC images are RGB and already size-normalized, so the
%   output of this function for them is always equivalent to:
%   single(rgb2gray(im))

%if ndims(im) == 3
%    im = rgb2gray(im);
%elseif ndims(im) ~= 2
%    error('Input image not valid');
%end

%im = single(im);

if ndims(im) == 3
    im = im2single(im);
elseif ndims(im) == 2
%elseif ismatrix(im)
    im_new = cat(3,im,im);
    im_new = cat(3,im_new,im);
    im = im_new;
    im = im2single(im);
    clear im_new;
else
    error('Input image not valid');
end
% resize theo ti le 4:3
    numrows = size(im,1);
    numcols = size(im,2);
    angle = 90;
    if  numrows > numcols 
        im = imrotate(im,angle);        
    end;
    
    im = imresize(im, [192 256]) ;
%if size(im,1) > 256, im = imresize(im, [256 NaN]) ; end

end


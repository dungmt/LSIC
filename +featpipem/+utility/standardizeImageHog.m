function im = standardizeImageHog( im )

    if ndims(im) == 3
        im = im2single(im);
    elseif ndims(im) == 2
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

end


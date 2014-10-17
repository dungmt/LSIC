
%<!-- saved from url=(0063)http://www.cs.columbia.edu/~mmerler/project/code/imresizecrop.m -->
function img = imresizecrop(img, M, METHOD)
%
% img = imresizecrop(img, M, METHOD);
%
% Output a square image of size M x M.


scaling = M/min([size(img,1) size(img,2)]);
scaling = scaling(1);
newsize = round([size(img,1) size(img,2)]*scaling);
img = imresize(img, newsize, METHOD);

[nr nc cc] = size(img);
sr = floor((nr-M)/2);
sc = floor((nc-M)/2);

img = img(sr+1:sr+M, sc+1:sc+M,:);


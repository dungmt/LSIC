%
% This script shows how to use the LabelMe toolbox to read the annotations.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Modeling the shape of the scene: a holistic representation of the spatial envelope
% Aude Oliva, Antonio Torralba
% International Journal of Computer Vision, Vol. 42(3): 145-175, 2001.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% First download the images and annotations and create the next folder
% structure
%   yourpath/images/spatial_envelope_256x256_static_8outdoorcategories
%   yourpath/annotations/spatial_envelope_256x256_static_8outdoorcategories
%
% Download also the LabelMe toolbox and add it to the Matlab path:
%   http://labelme.csail.mit.edu/LabelMeToolbox/index.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% put here the name of the images and annotations paths:
HOMEIMAGES = 'yourpath/images';
HOMEANNOTATIONS = 'yourpath/annotations';

% You can also use the images online but it will work faster if you
% download your own copy of the images and annotations.
% HOMEIMAGES = 'http://labelme.csail.mit.edu/Images';
% HOMEANNOTATIONS = 'http://labelme.csail.mit.edu/Annotations';


% Create the LabelMe index structure:
Dlabelme = LMdatabase(HOMEANNOTATIONS, {'spatial_envelope_256x256_static_8outdoorcategories'});

% You can visualize the images:
LMdbshowscenes(Dlabelme(1:36), HOMEIMAGES);

% To see the object names and the number of instances, use the next
% command:
[names, counts] = LMobjectnames(Dlabelme);

% The functions in the toolbox will allow you searching for objects, and
% extracting segmentation masks.


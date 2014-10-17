function codebook = train256(obj, imlist)
%TRAIN Summary of this function goes here
%   Detailed explanation goes here

% -------------------------------------------------------------------------
% 1. Extract features for training into 'feats' matrix
%     applying any limits on number of features/images
% -------------------------------------------------------------------------

% if trainimage_count was not left at it's default value
% (indicating all detected images should be used for training)
% select a subset of the images
if obj.trainimage_limit > 0
    idxs = 1:length(imlist);
    idxs = vl_colsubset(idxs, obj.trainimage_limit);
    imlist = imlist(idxs);
end

if obj.descount_limit > 0
    % set truncation value for image features just a little bit
    % larger than descount_limit, so if there are any images
    % with fewer than descount_limit/numImages we still have
    % some chance of getting descount_limit descriptors in the end
     img_descount_limit = ceil(obj.descount_limit / ...
         length(imlist) * 1.1);
    
 %   img_descount_limit=obj.descount_limit;
    
    fprintf('Extracting a maximum of %d features from each image...\n', ...
        img_descount_limit);
end
% gioi han so featutes


feats_a = cell(length(imlist),1);

% iterate through images, computing features
pfImcount = length(imlist);
for ii = 1:length(imlist)
    fprintf('Computing features for: %s %f %% complete\n', ...
        imlist{ii}, ii/pfImcount*100.00);

%     pathToFileNameFeature = fullfile();
   % if ~exist(imlist{ii},'file') continue;
     load(imlist{ii});
     feats_all = feats;
    
    % im = imread(imlist{ii});
    % im = featpipem.utility.standardizeImage256(im);
   %  feats_all = obj.featextr.compute(im); %#ok<PFBNS>
    
    % if a descount limit applies, discard a fraction of features now to
    % save memory
    if obj.descount_limit > 0
        feats_a{ii} = vl_colsubset(feats_all, ...
                 img_descount_limit);
    else
        feats_a{ii} = feats_all;
    end
end
clear feats_all;
% concatenate features into a single matrix
feats_a = cat(2, feats_a{:});

extractedFeatCount = size(feats_a,2);
fprintf('%d features extracted\n', extractedFeatCount);

if obj.descount_limit > 0
    % select subset of features for training
    
    if obj.descount_limit > extractedFeatCount
        obj.descount_limit = extractedFeatCount;
    end
    feats_a = vl_colsubset(feats_a, obj.descount_limit);
    % output status message
    fprintf('%d features will be used for training of codebook (%f %%)\n', ...
        obj.descount_limit, obj.descount_limit/extractedFeatCount*100.0);
end

% -------------------------------------------------------------------------
% 2. Cluster codebook centres
% -------------------------------------------------------------------------

fprintf('Clustering features...\n');

% if maxcomps is below 1, then use exact kmeans, else use approximate
% kmeans with maxcomps number of comparisons for distances
if obj.maxcomps < 1
    codebook = vl_kmeans(feats_a, obj.cluster_count, ...
        'verbose', 'algorithm', 'elkan');
else
    codebook = featpipem.lib.annkmeans(feats_a, obj.cluster_count, ...
        'verbose', true, 'MaxNumComparisons', obj.maxcomps, ...
        'MaxNumIterations', 150);
end

fprintf('Done training codebook!\n');

end


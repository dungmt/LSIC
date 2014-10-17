function codebook = trainfromfileindex(obj, listfileidx, ratio_images) 
%TRAIN Summary of this function goes here
%   Detailed explanation goes here

% -------------------------------------------------------------------------
% 1. Extract features for training into 'feats' matrix
%     applying any limits on number of features/images
% -------------------------------------------------------------------------

% if trainimage_count was not left at it's default value
% (indicating all detected images should be used for training)
% select a subset of the images
numfileidx = length(listfileidx);
if numfileidx<1
    return ;
end
fprintf('\nLoading data to train code book....');
setOfFeatsToTrainCodeBook2 = cell(numfileidx,1);


%  for i=380: numfileidx                  
 for i=1: numfileidx
      
    fprintf('\n Loading data %d/ %d: %s...',i,numfileidx, listfileidx{i});
    tmp=load(listfileidx{i},'setOfFeats');  
    fprintf(' finish !!!');
    num_images = size(tmp.setOfFeats,1);
    fprintf('\n\t num_images = %d',num_images);
% continue;
    num_images_selected_to_train_codebook = uint32(ratio_images *num_images);    
    rand_indices = randperm(num_images); 
    rand_indices_cb = rand_indices(1:num_images_selected_to_train_codebook);
    
    setOfFeatsToTrainCodeBook2{i}=tmp.setOfFeats(rand_indices_cb);    
    
   % setOfFeatsToTrainCodeBook = cat(1,setOfFeatsToTrainCodeBook, setOfFeats_cb) ; 
   
    fprintf('.');
 end
% pause;
setOfFeatsToTrainCodeBook =cat(1,setOfFeatsToTrainCodeBook2{:});
clear setOfFeatsToTrainCodeBook2;
fprintf('finish !\n');


if obj.trainimage_limit > 0
    idxs = 1:length(setOfFeatsToTrainCodeBook);
    idxs = vl_colsubset(idxs, obj.trainimage_limit);   
    setOfFeatsToTrainCodeBook = setOfFeatsToTrainCodeBook(idxs);
end

if obj.descount_limit > 0
    % set truncation value for image features just a little bit
    % larger than descount_limit, so if there are any images
    % with fewer than descount_limit/numImages we still have
    % some chance of getting descount_limit descriptors in the end
     img_descount_limit = ceil(obj.descount_limit / ...
         length(setOfFeatsToTrainCodeBook) * 1.1);
    
 %   img_descount_limit=obj.descount_limit;
    
    fprintf('Extracting a maximum of %d features from each image...\n', ...
        img_descount_limit);
end
% gioi han so featutes


feats_a = cell(length(setOfFeatsToTrainCodeBook),1);

% iterate through images, computing features

for ii = 1:length(setOfFeatsToTrainCodeBook)
     feats_all = setOfFeatsToTrainCodeBook{ii};    
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

fprintf('\nClustering features...\n');

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

fprintf('\nDone training codebook!\n');

end


function conf  = ExtractAndSaveFeatures(conf,start_Idx,end_Idx, step)
    fprintf('\n -----------------------------------------------');
	fprintf('\n Extracting features of images...');
    fprintf('\n\t Features type: %s',conf.feature.typeFeature);

        
    if strcmp(conf.feature.typeFeature,'hog')
        %Khong dung BOW    
        extractHogs(conf);
    elseif strcmp(conf.feature.typeFeature,'gist')
        %Khong dung BOW    
        extractGISTDescriptors(conf);   
    else
        % Dung BOW
        if strcmp(conf.datasetName ,'Caltech256') || strcmp(conf.datasetName ,'SUN397') 
            if extractKeypoints(conf,start_Idx,end_Idx, step) ~=0  % 0: error, 1: ready : 2: extracte            
                conf = trainCodeBook(conf);
                conf = initEncoderPooler(conf);
                calHistogram(conf, start_Idx,end_Idx, step);        
              
            else
                error('The number of class in conf.class.Names is empty !');
            end
        elseif strcmp(conf.datasetName ,'ILSVRC65')  
%             % extractKeypoints_Chunk(conf) ;
%             %%--------------------------------------------------------------------- 
% 
%             conf = ilsvrc.ILSVRC_CreateCodeBook(conf);
%             conf = ilsvrc.ILSVRC_InitEncoderPooler(conf);
        elseif strcmp(conf.datasetName ,'ILSVRC2010')  
            % extractKeypoints_Chunk(conf) ;
            %%--------------------------------------------------------------------- 

            conf = ilsvrc.ILSVRC_CreateCodeBook(conf);
            conf = ilsvrc.ILSVRC_InitEncoderPooler(conf);
            fprintf('\n\t -----------------------------------------------');
            fprintf('\n\t Extracting features...');
            targetset = 'train';
            ilsvrc.ILSVRC_ExtractFeature(conf, targetset, conf.BOW.pooler); 
            targetset = 'val';
            ilsvrc.ILSVRC_ExtractFeature(conf, targetset, conf.BOW.pooler);
            targetset = 'test';
            ilsvrc.ILSVRC_ExtractFeature(conf, targetset, conf.BOW.pooler);
        elseif strcmp(conf.datasetName ,'ILSVRC65')  
            fprintf('\n Data set da tinh feature roi !\n');
         elseif strcmp(conf.datasetName ,'ImageCLEF2012')  
                conf = imgCLEF.trainCodeBook(conf);
                conf = initEncoderPooler(conf);
%                 imgCLEF.calHistogram(conf, start_Idx,end_Idx, step);   
                
                % imgCLEF.calHistogramSave(conf, start_Idx,end_Idx)
        else
            error('Dataset %s is not supported !', conf.datasetName);
        end
    end    
end
    %% -------------------------------------------------------------------
    %                                           Step 1: Extract  Keypoints
    % --------------------------------------------------------------------
    % Feature: xy ly song song theo tung thu muc
    function result = extractHogs(conf) 
        numClass = length(conf.class.Names);
        if numClass <1            
            result = 0;
            return ;
        end
        fprintf('Extracting hog features...');
        pathToFileNameFeatureIndex = fullfile(conf.path.pathToFeaturesDir,conf.feature.fileNameFeatureIndex);
        
         if exist(pathToFileNameFeatureIndex,'file')
              result = 1;
              fprintf('finish(ready) ! \n');
              return;
         end
         
        setOfFeatures_IndexFile =cell(numClass,1);
        
        tic;
        extstr = 'jpg|jpeg|gif|png|bmp';
        pathToFeaturesDir = conf.path.pathToFeaturesDir;
        pathToImagesDir = conf.path.pathToImagesDir;
        for ci = 1:numClass
            class_ci = conf.class.Names{ci};
      
            fprintf('\nComputing features for class: %s (%d/%d)-',class_ci,ci,numClass);   
            filename_feat = [class_ci conf.feature.suffixFeature];
            filename = fullfile(pathToFeaturesDir , filename_feat);            
            
            if exist(filename,'file')               
                setOfFeatures_IndexFile{ci} = filename_feat;
                fprintf('finish !\n'); 
                continue;
            end
      
         
            pathToImagesDir_In      = fullfile(pathToImagesDir,class_ci);

            ims = utility.getFileNamesAtPath(pathToImagesDir_In,extstr);
            num_images = length(ims);
            if num_images==0
                error('No images in class %s \n',class_ci); 
            end

            fprintf('(%d images)\n',num_images); 
            
            setOfFeatures  = cell(num_images,1);
            setOfImages = cell(num_images,1);
            feature = conf.feature.featextr;
                        
            parfor ii = 1:num_images
                  % load in image to get size
                  fprintf('.'); 
                  setOfImages{ii} = imread(fullfile(pathToImagesDir_In, ims{ii}));
                  setOfImages{ii} = featpipem.utility.standardizeImageHog(setOfImages{ii});                  
            end
            parfor ii = 1:num_images                  
                  %fprintf('  computing features for image: %s....\n',ims{ii});      
                  fprintf('.'); 
                  feature1 = feature;                  
                  setOfFeatures{ii} =feature1.compute(setOfImages{ii});   
             end
             
            save(filename,  'setOfFeatures','ims','-v7.3');  
            setOfFeatures_IndexFile{ci} = filename_feat;
            
            fprintf('finish !\n');  
            
        end    

        save(pathToFileNameFeatureIndex,  'setOfFeatures_IndexFile', '-v7.3');             
        
        fprintf('\nTime to extract features is : %f seconds !\n',toc);
        result = true;
    end
    %% -------------------------------------------------------------------
    %                                                calculating Histogram
    % --------------------------------------------------------------------
    % Tinh hist cho cac anh
    function result = calHistogram(conf, start_Idx,end_Idx, step)
        numClass = length(conf.class.Names);
        if numClass <1            
            result = 0;
            return ;
        end
        fprintf('\tExtracting features...');
        pathToFileNameFeatureIndex = fullfile(conf.path.pathToFeaturesDir,conf.feature.fileNameFeatureIndex);
        
         if exist(pathToFileNameFeatureIndex,'file')
              result = 1;
              fprintf('finish(ready) ! \n');
              return;
         end
         
        setOfFeatures_IndexFile =cell(numClass,1);
                
        %5555555555555
        tic;
                
        Classes = conf.class.Names;       
        fprintf('\n Calculating histogram........\n');
        suffixKeyPoints = conf.BOW.suffixKeyPoints;
        pathToKeyPointsDir = conf.BOW.path.pathToKeyPointsDir;
        pathToFeaturesDir = conf.path.pathToFeaturesDir;
        
         for ci = start_Idx: step: end_Idx
%        for ci = 228: 228
            class_ci = Classes{ci};
            fprintf('\n\t Computing features for class: %s (%d/%d)-',class_ci,ci,numClass);
            filename_feat = [class_ci conf.feature.suffixFeature];
            path_filename_feat = fullfile(pathToFeaturesDir, filename_feat);
            
            if exist(path_filename_feat,'file')               
                setOfFeatures_IndexFile{ci} = filename_feat;
                fprintf('finish !\n'); 
                continue;
            end
       
            filename_keypoints = [fullfile(pathToKeyPointsDir, class_ci) suffixKeyPoints];
            if ~exist(filename_keypoints,'file')
                error('error: file not found %s',filename_keypoints);
            end
            
             
            tmp = load(filename_keypoints); % save(filename,  'setOfFeats', 'setOfFrames', 'setOfImgSize','-v7.3');
            
            setOfImgSize  = tmp.setOfImgSize;            
            setOfFeats= tmp.setOfFeats;
            setOfFrames = tmp.setOfFrames;
            
            num_images = length(setOfFeats);            
            if num_images==0
                error('No images in class %s \n',class_ci); 
            end
            fprintf('(%d images)\n',num_images);
             
             % tinh encode: song song
             setOfFeatures = cell(length(tmp.setOfFeats),1);
             pooler =conf.BOW.pooler;
             parfor ii = 1:num_images
             %for ii = start_Idx: step: end_Idx
                 fprintf('.');
                 pooler_tmp = pooler;
                  setOfFeatures{ii} = pooler_tmp.compute(setOfImgSize{ii}, setOfFeats{ii}, setOfFrames{ii});            %#ok<*PFOUS>
%                  setOfFeatures{ii} = pooler_tmp.compute(setOfImgSize{ii}, setOfFeats{ii}, setOfFrames{ii});            
             end

            % ghi data da encode

%              save(sprintf('%s.%d.%d.mat',filename,start_Idx,end_Idx),  'setOfFeatures','-v7.3'); 
             save(path_filename_feat,  'setOfFeatures','-v7.3'); 
             %save(filename,  'setOfFeats','ims','-v7.3');  
             setOfFeatures_IndexFile{ci} = filename_feat;
             
             clear setOfFeats;
             clear setOfFrames;
             clear setOfImgSize;
             clear setOfFeatures;    
             
             fprintf('finish ! \n');
         end
        
         ready=1;
         for ci = 1: conf.class.Num
            class_ci = Classes{ci};
            filename_feat = [class_ci conf.feature.suffixFeature];
            path_filename_feat = fullfile(pathToFeaturesDir, filename_feat);            
            if ~exist(path_filename_feat,'file')               
                ready=0;
                break;
            end
         end
        if ready==1               
            save(pathToFileNameFeatureIndex,  'setOfFeatures_IndexFile', '-v7.3');             
        end
        fprintf('\nTime to extract features is : %f seconds !\n',toc);
        
    end
    %% -------------------------------------------------------------------
    %                                           Step 1: Extract  Keypoints
    % --------------------------------------------------------------------
    % Feature: xy ly song song theo tung thu muc
    function result = extractKeypoints(conf, start_Idx,end_Idx, step) 
    
        numClass = length(conf.class.Names);
        if numClass <1            
            result = 0;
            return ;
        end
        
        
        fprintf('\n\tExtracting keypoints...');
        
        pathToFileNameKeyPointsIndex = fullfile(conf.BOW.path.pathToKeyPointsDir,conf.BOW.fileNameKeyPointsIndex);
       
        if exist(pathToFileNameKeyPointsIndex,'file') 
             result = 1;
             fprintf('finish(ready) ! \n');
             return;
        end
        
        setOfKeyPoints_IndexFile =cell(numClass,1);
        
        tic;
        extstr = 'jpg|jpeg|gif|png|bmp';
        suffixKeyPoints  =conf.BOW.suffixKeyPoints;

        pathToKeyPointsDir = conf.BOW.path.pathToKeyPointsDir;
        pathToImagesDir = conf.path.pathToImagesDir;
        
        for ci=start_Idx: step: end_Idx
%         for ci = 228:numClass
            class_ci = conf.class.Names{ci};
      
            fprintf('\n\t\tExtracting keypoints for class: %s (%d/%d)-',class_ci,ci,numClass);   
            filename_keypoints      = [class_ci suffixKeyPoints];
            filename = fullfile(pathToKeyPointsDir, filename_keypoints);            

            if exist(filename,'file')
                setOfKeyPoints_IndexFile{ci} = filename;
                fprintf('finish !\n'); 
                continue;
            end
   
         
            pathToImagesDir_In      = fullfile(pathToImagesDir,class_ci);

            ims = utility.getFileNamesAtPath(pathToImagesDir_In,extstr);
            num_images = length(ims);
            if num_images==0
                fprintf('No images in class %s \n',class_ci); 
            end

            fprintf('(%d images)\n',num_images); 
            
            setOfFeats =cell(num_images,1);
            setOfFrames=cell(num_images,1);
            setOfImgSize=cell(num_images,1);
            feature = conf.feature.featextr;

          %parfor ii = 1:num_images
               for ii = 1:num_images
                  % load in image to get size
                  feature1 = feature;
       %             
                  filename_img = fullfile(pathToImagesDir_In, ims{ii});
                   fprintf('\n %s',filename_img);
                  im = imread(filename_img);
                  im = featpipem.utility.standardizeImage256(im);
                  [feats, frames] = feature1.compute(im);
                  img_size = size(im);
                  setOfFeats{ii} = feats;
                  setOfFrames{ii} = frames;
                  setOfImgSize{ii} = img_size; 
                  fprintf('.'); 
               end
            fprintf('\n Saving %s...',filename);
            save(filename,  'setOfFeats', 'setOfFrames', 'setOfImgSize','-v7.3');    
            setOfKeyPoints_IndexFile{ci} = filename;

            
            clear setOfFeats setOfFrames setOfImgSize;           
            fprintf('finish !\n');  
            
        end    
 
        save(pathToFileNameKeyPointsIndex,  'setOfKeyPoints_IndexFile', '-v7.3'); 

        fprintf('\nTime to extract keypoint is : %f seconds !\n',toc);
        result = true;
    end
    %% -------------------------------------------------------------------
    %                                                     Train vocabulary
    % --------------------------------------------------------------------
    % train/load codebook
    function conf = trainCodeBook(conf)
        
        fprintf('\n\tCreating codebook...');
        % pathToFileNameCodeBook = 'D:\Dung Document\00_Nghiencuu\classification - Object detection\DataSet\LSVRC\2010\BOW\codebooks\ILSVRC2010_kmeans_10000.mat';
        pathToFileNameCodeBook = fullfile(conf.BOW.path.pathToCodeBooksDir,conf.BOW.fileNameCodeBook);
        
        if exist(pathToFileNameCodeBook,'file')             
            tmp = load(pathToFileNameCodeBook) ;
            conf.BOW.codebook =  tmp.codebook;
        %?    conf.BOW.codebkgen = tmp.codebkgen;
            fprintf('finish (ready)!\n');
            return;
        end
        
     
        pathToFileNameKeyPointsIndex = fullfile(conf.BOW.path.pathToKeyPointsDir,conf.BOW.fileNameKeyPointsIndex);
       
        if ~ exist(pathToFileNameKeyPointsIndex,'file') 
            error('error: File not found %s',pathToFileNameKeyPointsIndex);
        end
             
         setOfFeatsTrainCodeBook_tmp = load(pathToFileNameKeyPointsIndex);
         ratio_images = conf.BOW.ratio_images_selected_to_train_codebook;
         % do training...
         tic;
         codebook = conf.BOW.codebkgen.trainfromfileindex(setOfFeatsTrainCodeBook_tmp.setOfKeyPoints_IndexFile,ratio_images );
         conf.BOW.codebook = codebook;
       %  save(pathToFileNameCodeBook,'codebook','codebkgen');  
         save(pathToFileNameCodeBook,'codebook');  
         fprintf('finish!\n');
         fprintf('\tTime to create codebook: %f seconds\n', toc);
        
    end

   %% initialize encoder + pooler
    
    function conf = initEncoderPooler(conf)
        if size(conf.BOW.codebook )==0
            error('error: Code book is empty !');
        end
        if strcmp(conf.BOW.typeEncoder,'LLCEncoder')
            conf.BOW.encoder = featpipem.encoding.LLCEncoder(conf.BOW.codebook );
            conf.BOW.encoder.max_comps = 500;
            conf.BOW.encoder.norm_type = 'none';

            conf.BOW.pooler = featpipem.pooling.SPMPooler(conf.BOW.encoder);
            conf.BOW.pooler.subbin_norm_type = 'none';   % 'l1' or 'l2' (or other value = none)
            conf.BOW.pooler.norm_type = 'l2';            % 'l1' or 'l2' (or other value = none)
            conf.BOW.pooler.pool_type = 'max';           % 'sum' or 'max'
            conf.BOW.pooler.kermap = 'none';             % 'homker', 'hellinger' (or other value = none [default])
            %conf.BOW.pooler.post_norm_type = 'none';    % 'l1' or 'l2' (or other value = none)
            %conf.BOW.pooler.quad_divs = 2;              % value = 2 [default])
            %conf.BOW.pooler.horiz_divs = 3;             % value = 3 [default])
        elseif strcmp(conf.BOW.typeEncoder,'VQEncoder')
            % VQEncoder
            conf.BOW.encoder = featpipem.encoding.VQEncoder(conf.BOW.codebook );
            conf.BOW.encoder.max_comps = 25; % max comparisons used when finding NN using kdtrees
            conf.BOW.encoder.norm_type = 'none'; % normalization to be applied to encoding (either 'l1' or 'l2' or 'none')

            conf.BOW.pooler = featpipem.pooling.SPMPooler(conf.BOW.encoder);
            conf.BOW.pooler.subbin_norm_type = 'none'; % normalization to be applied to SPM subbins ('l1' or 'l2' or 'none')
            conf.BOW.pooler.norm_type = 'l1'; % normalization to be applied to whole SPM vector
            conf.BOW.pooler.pool_type = 'sum'; % SPM pooling type (either 'sum' or 'max')
            conf.BOW.pooler.kermap = 'homker'; % additive kernel map to be applied to SPM (either 'none' or 'homker')
        elseif strcmp(conf.BOW.typeEncoder,'KCBEncoder')            
            conf.BOW.encoder = featpipem.encoding.KCBEncoder(conf.BOW.codebook );
            conf.BOW.encoder.max_comps = 500;
            conf.BOW.encoder.norm_type = 'none';
            conf.BOW.encoder.sigma = 45;

            conf.BOW.pooler = featpipem.pooling.SPMPooler(conf.BOW.encoder);
            conf.BOW.pooler.subbin_norm_type = 'none';
            conf.BOW.pooler.norm_type = 'l1';
            conf.BOW.pooler.pool_type = 'sum';
            conf.BOW.pooler.kermap = 'homker';


        end
    end
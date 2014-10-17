function result = extractGISTDescriptors(conf) 
        numClass = length(conf.class.Names);
        if numClass <1            
            result = 0;
            return ;
        end

        %%
        fprintf('Extracting GIST features...');
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
            path_filename_feat = fullfile(pathToFeaturesDir , filename_feat);            
            
            if exist(path_filename_feat,'file')               
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
             
              
        %%%%
            parfor ii = 1:num_images
                  % load in image to get size
                  fprintf('.'); 
                  setOfImages{ii} = imread(fullfile(pathToImagesDir_In, ims{ii}));
             %     setOfImages{ii} = featpipem.utility.standardizeImageHog(setOfImages{ii});                  
            end
            
            [setOfFeatures{1}, param] = feature.compute(setOfImages{1}); % first call
            feature.param = param;
            parfor ii = 2:num_images                  
                  %fprintf('  computing features for image: %s....\n',ims{ii});      
                  fprintf('.'); 
                  feature1 = feature;                  
                  setOfFeatures{ii} =feature1.compute(setOfImages{ii});   
             end
             
            save(path_filename_feat,  'setOfFeatures','ims','-v7.3');  
            setOfFeatures_IndexFile{ci} = filename_feat;
            
            fprintf('finish !\n');  
            
        end    

        save(pathToFileNameFeatureIndex,  'setOfFeatures_IndexFile', '-v7.3');             
        
        fprintf('\nTime to extract features is : %f seconds !\n',toc);
        result = true;
end
    

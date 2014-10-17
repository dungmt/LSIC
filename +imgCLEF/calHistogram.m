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
        
		extstr = 'jpg|jpeg|gif|png|bmp';
            suffixKeyPoints  =conf.BOW.suffixKeyPoints;
            pathToKeyPointsDir = conf.BOW.path.pathToKeyPointsDir;
            pathToImagesDir = conf.path.pathToImagesDir;
            pathToImagesDir_In = pathToImagesDir;
            
            ims = utility.getFileNamesAtPath(pathToImagesDir_In,extstr);
            num_images = length(ims);
            if num_images==0
                error('No images in dir %s \n',pathToImagesDir_In); 
            end

            num_images_selected = num_images;
			%num_images_selected = num_images*conf.BOW.ratio_images_selected_to_train_codebook;
            fprintf('\n\t Total images: %d',num_images); 
            fprintf('\n\t Num_images_selected_to_train_codebook: %d',num_images_selected); 

            setOfKeyPoints_IndexFile =cell(1,1);
            ci=1;
            class_ci = 'imageclef2012';
            filename_keypoints      = [class_ci suffixKeyPoints];
            filename = fullfile(pathToFeaturesDir, filename_keypoints);   
			
            if exist(filename,'file')
                setOfKeyPoints_IndexFile{ci} = filename;
                fprintf('finish !\n');                
            else 

				ims_selected = ims;%(rand_indices_train_selected); 

				setOfFeatures = cell(num_images_selected,1);
				pooler =conf.BOW.pooler;          
			    feature = conf.feature.featextr;
                matlabpool open 10;
				parfor ii = 1:num_images_selected
                	filename_img = fullfile(pathToImagesDir_In, ims_selected{ii});
                    fprintf('\n %d - %s',ii,filename_img);
					im = imread(filename_img);
					im = featpipem.utility.standardizeImage256(im);
					[feats, frames] = feature.compute(im);                  %#ok<PFBNS>
					img_size = size(im);
					setOfFeatures{ii} = pooler.compute(img_size, feats, frames); %#ok<PFOUS,PFBNS>
				    
                end

              
			   % ghi data da encode
			fprintf('\n Saving %s...',filename);
            filename_feat=sprintf('%s.%d.%d.mat',filename,start_Idx,end_Idx);
            save(filename_feat,  'setOfFeatures','-v7.3');             
            setOfFeatures_IndexFile{ci} = filename_feat;
            
             matlabpool close;
        end
                           
        save(pathToFileNameFeatureIndex,  'setOfFeatures_IndexFile', '-v7.3');             
        
        fprintf('\nTime to extract features is : %f seconds !\n',toc);
        
    end
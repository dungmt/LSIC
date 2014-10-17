function conf = trainCodeBook(conf)
        
        fprintf('\n\tCreating codebook...');
        pathToFileNameCodeBook = fullfile(conf.BOW.path.pathToCodeBooksDir,conf.BOW.fileNameCodeBook);
        
        if exist(pathToFileNameCodeBook,'file')             
            tmp = load(pathToFileNameCodeBook) ;
            conf.BOW.codebook =  tmp.codebook;
            fprintf('finish (ready)!\n');
            return;
        end
        
        pathToFileNameKeyPointsIndex = fullfile(conf.BOW.path.pathToKeyPointsDir,conf.BOW.fileNameKeyPointsIndex);
       
        if ~ exist(pathToFileNameKeyPointsIndex,'file') 
      
            % Doc tat ca anh trong thu muc anh
            
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
            filename = fullfile(pathToKeyPointsDir, filename_keypoints);            
            if exist(filename,'file')
                setOfKeyPoints_IndexFile{ci} = filename;
                fprintf('finish !\n');                
            else 
                setOfFeats  =cell(num_images_selected,1);
                setOfFrames =cell(num_images_selected,1);
                setOfImgSize =cell(num_images_selected,1);


               feature = conf.feature.featextr;
			   
			   rand_indices = randperm(num_images);
               rand_indices_train_selected   = rand_indices(1:num_images_selected); 
               ims_selected = ims;%(rand_indices_train_selected); 

               for ii = 1:num_images_selected
                  % load in image to get size
                  feature1 = feature;
        %             
                  %filename_img = fullfile(pathToImagesDir_In, ims{ii});
				  filename_img = fullfile(pathToImagesDir_In, ims_selected{ii});
				  
				  
                   fprintf('\n %d - %s',ii,filename_img);
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
                save(pathToFileNameKeyPointsIndex,  'setOfKeyPoints_IndexFile', '-v7.3'); 
            end
        end
             
         setOfFeatsTrainCodeBook_tmp = load(pathToFileNameKeyPointsIndex);
         % do training...
         %ratio_images=conf.BOW.ratio_images_selected_to_train_codebook;
		 ratio_images=1;
		  

         tic;
         codebook = conf.BOW.codebkgen.trainfromfileindex(setOfFeatsTrainCodeBook_tmp.setOfKeyPoints_IndexFile,ratio_images );
         conf.BOW.codebook = codebook;
       %  save(pathToFileNameCodeBook,'codebook','codebkgen');  
         save(pathToFileNameCodeBook,'codebook');  
         fprintf('finish!\n');
         fprintf('\tTime to create codebook: %f seconds\n', toc);
        
    end

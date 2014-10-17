function conf = ILSVRC_CreateCodeBook(conf)
   % pathToFileNameCodeBook = 'D:\Dung Document\00_Nghiencuu\classification - Object detection\DataSet\LSVRC\2010\BOW\codebooks\ILSVRC2010_kmeans_10000.mat';
   fprintf('\n\t -----------------------------------------------');
   fprintf('\n\t Creating codebook...');
   pathToFileNameCodeBook = fullfile(conf.BOW.path.pathToCodeBooksDir,conf.BOW.fileNameCodeBook);
   if exist(pathToFileNameCodeBook,'file') 
        tmp = load(pathToFileNameCodeBook) ;
        conf.BOW.codebook =  tmp.codebook;
        %?    conf.BOW.codebkgen = tmp.codebkgen;
        fprintf('finish (ready)!');
		num_codeword = size(tmp.codebook,2);
		num_dim = size(tmp.codebook,1);		
		
		fprintf('\n\t\t Number of dimension: %d',num_dim);
		fprintf('\n\t\t Number of codewords: %d',num_codeword);		
		fprintf('\n\t\t Codebook are created by: %s',conf.BOW.typeCodebkGen);
		fprintf('\n');
        return;
   end
   
   fprintf('\n\t Creating codebook...');     
   ratio_images = conf.BOW.ratio_images_selected_to_train_codebook;
   cluster_count =conf.BOW.voc_size;
   img_descount_limit = 10000;
   pathToFileNameFeats = fullfile(conf.BOW.path.pathToKeyPointsDir,'feats.mat');
   
   %% -------------------------------------------------------------------
   %                                        doc danh sanh anh va chon anh  
   % --------------------------------------------------------------------
   pathToFileNameKeyPointsIndex = fullfile(conf.BOW.path.pathToKeyPointsDir,conf.BOW.fileNameKeyPointsIndex);
   fprintf('\n\t\t Selecting images to create codebook...');  
   if ~ exist(pathToFileNameKeyPointsIndex,'file') 
            % classes = subdirectories
         %%   conf.class.Names = utility.getDirectoriesAtPath(conf.path.pathToImagesDir );
            numClass = length(conf.class.Names);
            if numClass <1  
                error('Not found class in directory %s\n',conf.path.pathToImagesDir );
            end
            setOfFileNameToTrainCodeBook2 = cell(numClass,1);
            extstr = 'JPEG';
            for ci = 1:numClass
                class_ci = conf.class.Names{ci};
                pathToImagesDir_In      = fullfile(conf.path.pathToImagesDir,class_ci);
                ims = utility.getFileNamesAtPath(pathToImagesDir_In,extstr);
                num_images = length(ims);
                % chon ngau nhien trong danh sach anh them vao danh sach                
                  
                num_images_selected_to_train_codebook = uint32(ratio_images *num_images);    
                rand_indices = randperm(num_images); 
				rand_img = cell(num_images_selected_to_train_codebook,1);
                for jj=1:num_images_selected_to_train_codebook
					rand_img{jj} = fullfile(pathToImagesDir_In,ims{rand_indices(jj)} );
                end				
                setOfFileNameToTrainCodeBook2{ci}= rand_img;     
				clear	 rand_img	;		
                
            end
            setOfFileNameToTrainCodeBook =cat(1,setOfFileNameToTrainCodeBook2{:});                   
            save(pathToFileNameKeyPointsIndex,'setOfFileNameToTrainCodeBook','-v7.3');
            fprintf('finish !\n');         
   else
       if ~exist(pathToFileNameFeats,'file') 
            fprintf('\n\t\t Loading set of file name to create code book ...');
            load(pathToFileNameKeyPointsIndex);
            fprintf('finish (ready) !\n');     
       end
   end
   
   
   %% -------------------------------------------------------------------
   %                                                    Extract keypoints  
   % --------------------------------------------------------------------		 

   
   fprintf('\n\t\t Computing keypoints of images...');
   if exist(pathToFileNameFeats,'file') 
       fprintf('\n\t\t Loading keypoints from file ...');
       load(pathToFileNameFeats);		
       fprintf('finish (ready) !\n'); 
   else       
       num_images_train = length(setOfFileNameToTrainCodeBook);
           
       pathToSaveKps = fullfile(conf.BOW.path.pathToKeyPointsDir,'traincb');
       if ~exist(pathToSaveKps,'dir')
           mkdir(pathToSaveKps);
           if ~exist(pathToSaveKps,'dir')
                error('Can not create directory %s\n',pathToSaveKps);
           end           
       end
       
       % --------------------------------------------------------------------	
       % Extract key points and save to disk
       
       num_workers = max(matlabpool('size'), 1);
       chunk_size =  uint32(num_images_train / num_workers)+1;    
       chunk_starts_ = 1:chunk_size:num_images_train;

       % allocate chunks to workers
       chunk_starts = cell(num_workers);
       for w = 1:num_workers
           chunk_starts{w} = chunk_starts_(w:num_workers:end);
       end
        
%        featextr1 = featpipem.features.PhowExtractor();
%        featextr1 .step = 3; 
       featextr1 = conf.feature.featextr;
       setOfFileName = {}; %cell (num_images_train,1);
       %iterate through chunks assigned to current worker
       parfor w = 1:num_workers
           % iterate through images, computing features  
           for c = 1:length(chunk_starts{w})           
                    this_chunk_size = min(chunk_size, num_images_train-chunk_starts{w}(c)+1);
                    % iterate through images in current chunk
                    for ii = chunk_starts{w}(c):chunk_starts{w}(c)+this_chunk_size-1
                         filename_img = setOfFileNameToTrainCodeBook{ii};                  %#ok<PFBNS>
                         [~,name,ext] = fileparts(filename_img);
                        % setOfFileName{ii} = name; 
                        % fprintf('Computing features for: %s%s %f %% complete\n', name,ext, ii/pfImcount*100.00);   
                         fprintf('\n\t\t Computing keypoints for: %s%s', name,ext);                    
                         filename_kp= fullfile(pathToSaveKps,[name '.mat']);
                         if ~exist(filename_kp,'file')  
                            im = imread(filename_img);
                            im = featpipem.utility.standardizeImageImgNet(im);
                            feats_all= featextr1.compute(im);         %#ok<PFBNS>
                            feats_all = vl_colsubset(feats_all, img_descount_limit);
                            % save keypoint da tao    
                            savekps(filename_kp, feats_all); 
                            fprintf('...finish !');
                         else
                         %    load (filename_kp);
                            fprintf('...ready !');
                         end
                       %  feats{ii} = feats_all;                    
                    end
           end
       end
       % --------------------------------------------------------------------	
       % Read key points from disk   
       img_descount_limit_new = 2000;
       feats = cell(num_images_train,1); % chua danh sach dac trung 
       for ii = 1:num_images_train
            filename_img = setOfFileNameToTrainCodeBook{ii};                 
           % [~,name,ext] = fileparts(filename_img{1});
            [~,name,ext] = fileparts(filename_img);
            %name = setOfFileName{ii};
            fprintf('\n\t\t Loading features for (%4d): %s.JPEG',ii, name);
            filename_kp= fullfile(pathToSaveKps,[name '.mat']);
            tmp=load(filename_kp);
            feats_all = vl_colsubset(tmp.feats_all, img_descount_limit_new);
            feats{ii} = feats_all;
       end
        clear feats_all;
        clear tmp;
        clear setOfFileNameToTrainCodeBook;

        % concatenate features into a single matrix
        tic;
        fprintf('\n\t\t Saving feats to file...');
        save(pathToFileNameFeats,'feats','-v7.3');
        fprintf('finish (%f)',toc);
        tic;
        fprintf('\nConverting feats cell to matrix...');
        feats = cat(2, feats{:});  
        fprintf('finish (%f)',toc);

        tic;
        fprintf('\nSaving_2 feats to file...');
        save(pathToFileNameFeats,'feats','-v7.3');
        fprintf('finish (%f)',toc);

        extractedFeatCount = size(feats,2);
        fprintf('%d features extracted\n', extractedFeatCount);
   end

% -------------------------------------------------------------------------
% 2. Cluster codebook centres
% -------------------------------------------------------------------------
    fprintf('\n\t Creating CodeBook (%d codewords)...',cluster_count);

    tic;
    % Quantize the descriptors to get the visual words
    if strcmp(conf.BOW.typeCodebkGen,'kmeans')
        codebook = vl_kmeans(feats, cluster_count, 'verbose', 'algorithm', 'elkan') ;    
    else
        %codebook = featpipem.lib.annkmeans(feats, cluster_count, 'verbose', true, 'MaxNumComparisons', maxcomps, 'MaxNumIterations', 150);  
        codebook = featpipem.lib.annkmeans(feats, cluster_count, 'verbose', true, 'MaxNumIterations', 150); 
    end
    fprintf(' finish !');

    fprintf('\n\t Saving codebook to file...');
    save(pathToFileNameCodeBook,'codebook');   
    fprintf('finish (%f) !\n',toc);      
    conf.BOW.codebook = codebook;
    %fprintf('Time to create codebook: %f seconds\n', toc);         
    
end
function savekps(filename_kp, feats_all)
    save(filename_kp,'feats_all','-v7.3');  
end



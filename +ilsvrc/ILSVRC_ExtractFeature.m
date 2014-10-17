function ILSVRC_ExtractFeature(prms, targetset, pooler)
% Extract feature for training, validation and test set
% *** Training images
% 
% The training images are the same images in the ImageNet 2010 Spring Release. 
% You can browse the images of a synset at
%     http://www.image-net.org/synset?wnid=WNID
% where WNID is the WordNet ID of the synset, as in the meta file.
% 
% There is a tar file for each synset, named by its WNID. The image files are named 
% as x_y.JPEG, where x is WNID of the synset and y is an integer (not fixed width and not
% necessarily consecutive). All images are in JPEG format. 
%
% *** Validation images
% 
% There are a total of 50,000 validation images. They are named as
% 
%       ILSVRC2010_val_00000001.JPEG
%       ILSVRC2010_val_00000002.JPEG
%       ...
%       ILSVRC2010_val_00049999.JPEG
%       ILSVRC2010_val_00050000.JPEG
%       datasetName_set_id.ext
% There are 50 validation images for each synset.
% 
% The ground truth of the validation images is in 
%     data/ILSVRC2010_validation_ground_truth.txt,
% where each line contains one ILSVRC2010_ID for one image, in the ascending alphabetical 
% order of the image file names.
%
% *** Test images
% 
% There are a total of 150,000 test images, which will be released separately at a later
% time. The test files are named as
% 
%       ILSVRC2010_test_00000001.JPEG
%       ILSVRC2010_test_00000002.JPEG
%       ...
%       ILSVRC2010_test_00149999.JPEG
%       ILSVRC2010_test_00150000.JPEG

% Note: Hai tap nay giong nhau ve cach dat ten file       
   
    pathToFeaturesDir = prms.path.pathToFeaturesDir;    
    % targetset = 'val';
    switch targetset
        case 'val'               
           num_images = 50000; % 50,000 validation images
        case 'test'            
            num_images = 150000; % 150,000 test images
        case 'train'
            num_images = 0;      % tap train tinh rieng 
    end
    % Kiem tra cac file da duoc tao chua ? Neu tao roi thi khong tao lai
    pathToFeaturesDir_Out = fullfile (pathToFeaturesDir,targetset);    
    filename_index = fullfile(pathToFeaturesDir_Out,'index.mat');
    
    if exist(filename_index,'file')
        fprintf('\n\t\t Features of "%s" dataset is ready exist !',targetset);
        return;
    end
    
        
    datasetName = prms.datasetName;
    % extstr = 'JPEG';    
    pathToImagesDir_In = fullfile(prms.dir.rootImagesDir, targetset);   
     
    
    if ~exist(pathToFeaturesDir_Out,'dir')
        mkdir(pathToFeaturesDir_Out);
        if ~exist(pathToFeaturesDir_Out,'dir')             
            error('Can not create directory %s\n',pathToFeaturesDir_Out);
        end    
    end
    matlabpool open 10;
    chunk_size = 1000;  % 1,000 images/pool
    num_workers = matlabpool('size');    % 5 pool     
    if num_workers ==0
        num_workers=1;
    end
    
    featextr = prms.feature.featextr;
  
    output_dim = pooler.get_output_dim;
    
    if strcmp(targetset,'train')

        classes = utility.getDirectoriesAtPath(pathToImagesDir_In);
        num_Class = length(classes);
        if num_Class <1  
             error('Not found class in directory %s\n',conf.path.pathToImagesDir );
        end
        
        chunk_starts_ = 1:num_Class;
        if num_Class < num_workers
            num_workers = num_Class;
        end     
		fprintf('\n-----------------------------------------------');
		fprintf('\nExtract features for Training images');
		fprintf('\nNumber of classes: %d',num_Class);
		fprintf('\nNumber of workers: %d',num_workers);
		fprintf('\n');
		
        %%---------------------------------------------------------------------   
        % allocate chunks to workers
        chunk_starts = cell(num_workers);
        for w = 1:num_workers
            chunk_starts{w} = chunk_starts_(w:num_workers:end);
        end    
        chunk_files_by_worker = cell(num_workers, 1);
        %%%%
        extstr = 'JPEG';
        % compute chunks
        %parfor w = 1:num_workers
        parfor w = 1:num_workers
            length_chunk_starts_w = length(chunk_starts{w});
            
            for c = 1:length_chunk_starts_w
                class_ci = classes{chunk_starts{w}(c)}; %#ok<PFBNS>
                fprintf('\n\t\t Processing chunk starting at %d (worker: %d round: %d class: %s)...\n', chunk_starts{w}(c), w, c,class_ci);  
                
                 % path = fullfile(pathToFeaturesDir_Out, [targetset,'.',num2str(val_id,'%.4d'),'.sbow.mat'] );
                path = fullfile(pathToFeaturesDir_Out, [class_ci,'.sbow.mat'] );
                if exist(path,'file')
                    fprintf('Chunkfile exists. Skipping...\n');
                    continue;
                end
                
                %%%%==================================
                pathToImagesDir_In2      = fullfile(pathToImagesDir_In,class_ci);
                ims = utility.getFileNamesAtPath(pathToImagesDir_In2,extstr);
                num_images = length(ims);
                assert(num_images>0);
				fprintf('num_images=%d',num_images);
                fprintf('pathToImagesDir_In2=%s',pathToImagesDir_In2);
                
% 				rand_indices = randperm(num_images); 
% 				ims = ims(rand_indices(1:300));
% 				num_images = min(num_images,300);
                
                start_i = 1; %chunk_starts{w}(c);            
                this_chunk_size = num_images; %min(chunk_size, num_images - start_i +1);
                end_i   = num_images; %chunk_starts{w}(c)+this_chunk_size-1;
                %val_id = uint32(start_i/chunk_size)+1;

                setOfFeatures = zeros(output_dim, this_chunk_size, 'single'); 
                % iterate through images in current chunk
                for i = start_i:end_i                
                    filename_img = fullfile(pathToImagesDir_In2, ims{i} );
                    fprintf('  computing features for image: %s....\n',filename_img); 
                    if ~ exist(filename_img,'file')
                        error('Error: File "%s" does not exist !',path);                    
                    end
                  %  info = imfinfo(filename_img);
                    im = imread(filename_img);
%                     if strcmp(info.PhotometricInterpretation,'CMYK')
                    if (size(im,3) == 4)
                        im = utility.rgb2cmyk(im);
                        fprintf('\n\t Convert CMYK to RGB: %s', filename_img);
                        imwrite(im,filename_img);
                    end
                    
                    im = featpipem.utility.standardizeImageImgNet(im);
                    [feats, frames] = featextr.compute(im); %#ok<PFBNS>
                    cur_code = pooler.compute(size(im), feats, frames);                 %#ok<PFBNS>
                    if any(isnan(cur_code))
                        error('NaNs in the code of chunk %d (worker: %d round: %d)!', i, w, c);
                    end                
                    setOfFeatures(:,i - start_i + 1) = cur_code;                    
                end
                index = start_i:end_i;
                %waitfor(save_chunk_(path,setOfFeatures,index));
                save_chunk_(path,setOfFeatures,index);  % de xay ra loi
              %  chunk_files_by_worker{w}{end+1} = path;
            end

        end
        save(filename_index,'chunk_files_by_worker','-v7.3');

    else
        chunk_starts_ = 1:chunk_size:num_images;
        if num_images < chunk_size
            num_workers =1;
        end
    
		fprintf('\n-----------------------------------------------');
		fprintf('\nExtract features for %s images', targetset);
		fprintf('\nNumber of images: %d',num_images);
		fprintf('\nNumber of workers: %d',num_workers);
		fprintf('\n');
     
        %%---------------------------------------------------------------------   
        % allocate chunks to workers
        chunk_starts = cell(num_workers);
        for w = 1:num_workers
            chunk_starts{w} = chunk_starts_(w:num_workers:end);
        end    
        chunk_files_by_worker = cell(num_workers, 1);
        % compute chunks
        parfor w = 1:num_workers
            for c = 1:length(chunk_starts{w})
                fprintf('Processing chunk starting at %d (worker: %d round: %d)...\n', chunk_starts{w}(c), w, c);        

                start_i = chunk_starts{w}(c);            
                this_chunk_size = min(chunk_size, num_images - start_i +1);
                end_i   = chunk_starts{w}(c)+this_chunk_size-1;
                val_id = uint32(start_i/chunk_size)+1;

                setOfFeatures = zeros(output_dim, this_chunk_size, 'single');      
                
                path = fullfile(pathToFeaturesDir_Out, [targetset,'.',num2str(val_id,'%.4d'),'.sbow.mat'] );

                if exist(path,'file')
                    fprintf('Chunkfile exists. Skipping...\n');
                    continue;
                end
                % iterate through images in current chunk
                for i = start_i:end_i                
                    filename_img = fullfile(pathToImagesDir_In, [datasetName,'_',targetset,num2str(i,'_%.8d'),'.JPEG'] );
                    fprintf('  computing features for image: %s....\n',filename_img); 
                    if ~ exist(filename_img,'file')
                        error('Error: File "%s" does not exist !',path);                    
                    end
                    im = imread(filename_img);
                    if (size(im,3) == 4)
                        im = utility.rgb2cmyk(im);
                        fprintf('\n\t Convert CMYK to RGB: %s', filename_img);
                        imwrite(im,filename_img);
                    end
                    im = featpipem.utility.standardizeImageImgNet(im);
                    [feats, frames] = featextr.compute(im); %#ok<PFBNS>
                    cur_code = pooler.compute(size(im), feats, frames);                 %#ok<PFBNS>
                    if any(isnan(cur_code))
                        error('NaNs in the code of chunk %d (worker: %d round: %d)!', i, w, c);
                    end   
                    %cur_code = ones(output_dim,1,'single');             
                    setOfFeatures(:,i - start_i + 1) = cur_code;
                  
                end
                index = start_i:end_i;
                save_chunk_(path,setOfFeatures,index);
               % chunk_files_by_worker{w}{end+1} = path;
            end

        end
        save(filename_index,'chunk_files_by_worker','-v7.3');
    end
end
function save_chunk_(filename, setOfFeatures, index) %#ok<INUSD>
save(filename,'setOfFeatures','index','-v7.3');
end

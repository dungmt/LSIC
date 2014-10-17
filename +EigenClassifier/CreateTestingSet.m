function [ conf ] = CreateTestingSet( conf )
%UNTITLED Summary of this function goes here
% Tao tap validation va test thanh 1 file ??

    
    
   fprintf('\n -----------------------------------------------');
   fprintf('\n Creating testing dataset by combining classes into one file ...');   
   path_filename_test_selected   = conf.test.path_filename;           
   if exist(path_filename_test_selected,'file')
        fprintf('finish (ready) !');
        return;
   end
   
 
   num_classes = conf.class.Num;
   Classes     = conf.class.Names;
 
   pathToIMDBDirTest    = conf.path.pathToIMDBDirTest;
      if strcmp(conf.datasetName,'ImageCLEF2012')  

        extstr = 'mat';
        pathToFeaturesDir =  fullfile(conf.dir.rootDir,'test_images/images');
        
        ims = utility.getFileNamesAtPath(pathToFeaturesDir,extstr);
        num_images = length(ims);
        if num_images==0
                error('No images in class %s \n',pathToFeaturesDir); 
        end
        dim_feature = conf.BOW.pooler.get_output_dim();
        instance_matrix  = zeros(dim_feature,num_images);
        label_vector     = zeros(1,num_images);
        fprintf('\n num_images test:%d ',num_images);
        fprintf('\n Loading test: ');
        for k = 1:num_images
            filename_test = ims{k};          
            path_filename_test = fullfile(pathToFeaturesDir,filename_test);
            tmpf = load(path_filename_test);
            instance_matrix(:,k) = tmpf.setOfFeatures(:,1);
            fprintf('.');
       end
   
   
    elseif  strcmp(conf.datasetName,'ILSVRC65')  

            test_gt_map = hedging.read_gt(fullfile(conf.dir.rootDir, 'code/ilsvrc65.test.gt'));
            test_mat_location = fullfile(conf.dir.rootDir,'features/ilsvrc65.test.llc.mat');

            fprintf('\n Loading test\n');
            test_data = load(test_mat_location);

            % Make labels
            test_labels = zeros(size(test_data.ids));
            fprintf('Getting labels...\n');
            for i = 1:numel(test_labels)
              test_labels(i) = conf.class2id_map.get(test_gt_map.get(test_data.ids{i}));
            end
            instance_matrix = test_data.betas;
            label_vector =test_labels;
   
   
    elseif strcmp(conf.datasetName,'ILSVRC2010')     
        pathToIMDBDirTest =  fullfile(conf.path.pathToFeaturesDir, 'test');
        fprintf('\n\t\t Dang cap bo nho....');
        instance_matrix= zeros(50000,150000);
%         label_vector =[];
        gtruth_test_file= fullfile(conf.dir.rootDir,'data/ILSVRC2010_test_ground_truth.txt');    
        label_vector = dlmread(gtruth_test_file);
        sum_num_images = 150000;
        fprintf(' done');
        
        for j=1:150 
                str_id = num2str(j,'%.4d');
                filename_test = ['test.',str_id,'.sbow.mat'] ;
                path_filename_test = fullfile(pathToIMDBDirTest, filename_test);
                if ~exist(path_filename_test,'file')  % kiem tra xem co file test                    
                    error('Missing test file %s !',path_filename_test);    
                end
                
                fprintf('\n\t\t Loading data from file %s ...',filename_test);
                load(path_filename_test); % save(filename,'setOfFeatures','index','-v7.3');
%                   Name                   Size                  Bytes  Class     Attributes
% 
%                   index                  1x1000                 8000  double              
%                   setOfFeatures      50000x1000            200000000  single            
                instance_matrix(:,(j-1)*1000 +1 :j*1000) = setOfFeatures;
               
        end
        
   else
        instance_matrix=[];
        label_vector =[];
        sum_num_images = 0;
       for ci = 1:num_classes
            class_ci = Classes{ci};            
            fprintf('\n\t\t Processing class: %s (%d/%d)...',class_ci,ci,num_classes);
            filename_sbow_of_class = [class_ci,'.sbow.mat'];
            path_filename_test = fullfile(pathToIMDBDirTest, filename_sbow_of_class );

            if ~exist(path_filename_test,'file')
                error('File %s not found ',path_filename_test);
            end

            fprintf('\n\t\t\t --> Loading file: %s...',filename_sbow_of_class);
            tmpf = load(path_filename_test);            

            num_images = size(tmpf.instance_matrix,2); % kieu cell, moi cell: kich thuoc 32000 x 1 single
            sum_num_images = sum_num_images + num_images;
            instance_matrix = [instance_matrix, tmpf.instance_matrix];     
            label_vector = [label_vector, tmpf.label_vector];  
    
       end
        
   end
    fprintf('\n\t Saving testing set into file: %s....',conf.test.filename);
    save(path_filename_test_selected,'instance_matrix','label_vector','-v7.3');
    fprintf('done');

end


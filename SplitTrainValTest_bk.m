function conf = SplitTrainValTest( conf)
    if ~strcmp( conf.datasetName,'Caltech256')
        fprintf('\n Chuc nang chi ap dung cho Caltech256');
        fprintf('\n Tren du lieu ILSVRC2010 can kiem tra lai !');
        return;  
    end   

    num_classes = conf.class.Num;
    Classes     = conf.class.Names;
    
    if conf.class.Num <1  
         error('Not found class ' );
    end
    
    fprintf('\n Creating data set for training, validation and testing...');
    if exist(conf.IMDB.path_filename_ready,'file');
        fprintf('finish (ready) !');
        return;
    end
    
    num_images_train = conf.IMDB.num_images_train; 
    num_images_test  = conf.IMDB.num_images_test;
    num_images_val   = conf.IMDB.num_images_val;
    
    num_images_sum =  num_images_train + num_images_val + num_images_test; 
   
    pathToIMDBDirTrain  = conf.path.pathToIMDBDirTrain ;
    pathToIMDBDirVal    = conf.path.pathToIMDBDirVal;
    pathToIMDBDirTest   = conf.path.pathToIMDBDirTest;
    
    num_images_test_per_chunk_file = conf.IMDB.num_images_test_per_chunk_file;
    num_images_val_per_chunk_file  = conf.IMDB.num_images_val_per_chunk_file;
  %  fprintf('\n num_images_test_per_chunk_file = %d',num_images_test_per_chunk_file);    
  %  pause;
    num_files_test = (num_images_test * num_classes)/num_images_test_per_chunk_file;  %ceil(3.4, 5.6) --> (4, 6)
    num_files_val  = (num_images_val  * num_classes)/num_images_val_per_chunk_file;
  
    num_files_test = ceil(num_files_test);
    num_files_val  = ceil(num_files_val );
   
    num_item_test_instance_matrix = ones(1,num_files_test)*num_images_test_per_chunk_file;
    num_item_val_instance_matrix  = ones(1,num_files_val)*num_images_val_per_chunk_file;
    
    num_item_test_instance_matrix(num_files_test) = (num_images_test * num_classes) - (num_files_test-1)*num_images_test_per_chunk_file;
    num_item_val_instance_matrix(num_files_val) = (num_images_val * num_classes) - (num_files_val-1)*num_images_val_per_chunk_file;
    
    path_filename_ready = fullfile(conf.path.pathToIMDBDir, conf.IMDB.filename_ready);
    if exist(path_filename_ready,'file')
        fprintf('finish (ready) !');
        return;
    end
     
   
    output_dim = conf.BOW.pooler.get_output_dim;
   
    
%     val_instance_matrix  = zeros(output_dim,num_images_val*num_classes);
%     test_instance_matrix = zeros(output_dim,num_images_test*num_classes);
%     val_label_vector=zeros(1,num_images_val*num_classes);
%     test_label_vector=zeros(1,num_images_test*num_classes);
    
    val_instance_matrix  = zeros(output_dim,num_images_val_per_chunk_file);
    test_instance_matrix = zeros(output_dim,num_images_test_per_chunk_file);
    val_label_vector     = zeros(1,num_images_val_per_chunk_file);
    test_label_vector    = zeros(1,num_images_test_per_chunk_file);
    
    col_ci_test =1;
    col_ci_val =1;
    
    val_id = 1;
    test_id = 1;
    
    pathToFeaturesDir = conf.path.pathToFeaturesDir;
    
    for ci = 1:num_classes
           % parfor ci = 1:num_classes
            class_ci = Classes{ci};
            
            fprintf('\n\t\t Processing class: %s (%d/%d)...',class_ci,ci,num_classes);
            filename_feature = [class_ci,'.mat'];
            path_filename_feature = fullfile(pathToFeaturesDir, filename_feature);
            if ~exist(path_filename_feature,'file')
                error('Features of class %s not found ',class_ci);
            end
            fprintf('\n\t\t\t --> Loading file: %s...',filename_feature);
            tmpf = load(path_filename_feature);            
            % ims = cell_cur_code_tmp.ims;
            num_images = length(tmpf.setOfFeatures); % kieu cell, moi cell: kich thuoc 32000 x 1 single
            %  Features_Mat = cell2mat(tmpf.setOfFeatures);
            fprintf('\n\t\t\t --> Splitting data...');
            rand_indices = randperm(num_images);
            rand_indices_train = rand_indices(1:num_images_train);            
            rand_indices_val   = rand_indices(num_images_train+1:num_images_train+num_images_val);
            rand_indices_test  = rand_indices(num_images_train+num_images_val+1:num_images_sum);
            
           % setOfFeatures = zeros(size(tmpf.setOfFeatures{1},1),num_images_train);
            instance_matrix = zeros(size(tmpf.setOfFeatures{1},1),num_images_train);
            label_vector   = ones(1,num_images_train)*ci;
            
            index = rand_indices_train;
            for k=1: num_images_train
            %    setOfFeatures(:,k) = tmpf.setOfFeatures{rand_indices_train(k)};
                instance_matrix(:,k) = tmpf.setOfFeatures{rand_indices_train(k)};
            end
             % setOfFeatures(:,1:num_images_train) = Features_Mat(:,rand_indices_train);
            for k=1: num_images_test
                test_instance_matrix(:,col_ci_test+k-1) = tmpf.setOfFeatures{rand_indices_test(k)};
                
            end
            for k= 1 :  num_images_val
                val_instance_matrix(:,col_ci_val+k-1) = tmpf.setOfFeatures{rand_indices_val(k)};                
            end
             
            test_label_vector(:,  col_ci_test: col_ci_test+ num_images_test -1)= ci; 
            val_label_vector (:,  col_ci_val : col_ci_val + num_images_val  -1)= ci;
            
            
           
            col_ci_test = col_ci_test+ num_images_test;
            col_ci_val  = col_ci_val + num_images_val;
            
            filename_train = [class_ci,'.sbow.mat'];
            fprintf('\n\t\t\t --> Save training data into file:%s...',filename_train);
            path_filename_train = fullfile(pathToIMDBDirTrain, filename_train );
           % save(path_filename_train,'setOfFeatures','index','-v7.3');
            save(path_filename_train,'instance_matrix','label_vector','-v7.3');
            
           % fprintf('\n col_ci_val = %d',col_ci_val);
            if col_ci_val == num_item_val_instance_matrix(val_id) + 1
                filename_val = ['val.',num2str(val_id,'%.4d'),'.sbow.mat'];
                path_filename_val =  fullfile(pathToIMDBDirVal, filename_val  );
                instance_matrix = val_instance_matrix(:,1:num_item_val_instance_matrix(val_id));  
                label_vector = val_label_vector(1:num_item_val_instance_matrix(val_id));       
                fprintf('\n\t\t\t --> Save validation data into file:%s...',filename_val);
                save(path_filename_val,'instance_matrix','label_vector','-v7.3');    
                val_id = val_id + 1;
                col_ci_val = 1;
            end
          % fprintf('\n col_ci_test = %d',col_ci_test);
            if col_ci_test == num_item_test_instance_matrix (test_id) + 1
                filename_test =  ['test.',num2str(test_id,'%.4d'),'.sbow.mat'] ;
                path_filename_test =  fullfile(pathToIMDBDirTest, filename_test );
                instance_matrix = test_instance_matrix(:,1:num_item_test_instance_matrix (test_id)); 
                label_vector = test_label_vector(1:num_item_test_instance_matrix (test_id));                 
                fprintf('\n\t\t\t --> Save testing data into file:%s...',filename_test);
                save(path_filename_test,'instance_matrix','label_vector','-v7.3');    
                test_id = test_id + 1;
                col_ci_test = 1;
            end
            
    end
    ready = 1;
    save(conf.IMDB.path_filename_ready,'ready','-v7.3');  
    % Tao tap validation va test thanh 1 file ??
    
    
%     
%     fprintf('\n\t Saving validation dataset into file: %s....',path_filename_val);   
%     path_filename_val   = fullfile(pathToIMDBDirVal,    [conf.datasetName, '.sbow.mat']);
%     path_filename_test  = fullfile(pathToIMDBDirTest,   [conf.datasetName, '.sbow.mat']);
%       
%     instance_matrix = val_instance_matrix;
%     label_vector = val_label_vector;
%     %save(path_filename_val,'val_instance_matrix','val_label_vector','-v7.3');
%     save(path_filename_val,'val_instance_matrix','val_label_vector','-v7.3');
%       
%     instance_matrix = test_instance_matrix;
%     label_vector = test_instance_matrix;
%     fprintf('\n\t Saving testing dataset into file: %s....',path_filename_test);
%    % save(path_filename_test,'test_instance_matrix','test_label_vector','-v7.3');   
%     save(path_filename_test,'instance_matrix','label_vector','-v7.3');   
    
    fprintf('\n\t End of SplitTrainValTest !');
    
end
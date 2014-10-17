function conf = SplitTrainValTest( conf,start_Idx,end_Idx, step)
        

    if conf.class.Num <1  
         error('Not found class ' );
    end
    num_classes = conf.class.Num;
    Classes     = conf.class.Names;
 
    fprintf('\n -----------------------------------------------');
    fprintf('\n Splitting dataset into training, validation and testing...');
    if exist(conf.IMDB.path_filename_ready,'file');
        fprintf('finish (ready) !');
        return;
    end
   
    num_images_train = conf.IMDB.num_images_train; 
    num_images_test  = conf.IMDB.num_images_test;
    num_images_val   = conf.IMDB.num_images_val;
    
  
    pathToIMDBDirTrain  = conf.path.pathToIMDBDirTrain ;
    pathToIMDBDirVal    = conf.path.pathToIMDBDirVal;
    pathToIMDBDirTest   = conf.path.pathToIMDBDirTest;
    
    pathToFeaturesDir   = conf.path.pathToFeaturesDir;
    
    fprintf('\n\t conf.datasetName: %s',conf.datasetName);
    fprintf('\n\t conf.IMDB.num_images_train: %.2f',num_images_train);
    fprintf('\n\t conf.IMDB.num_images_val: %.2f',num_images_val);
    fprintf('\n\t conf.IMDB.num_images_test: %.2f',num_images_test);
  
    fprintf('\n\t Splitting .....');
    ready = 0;
    switch conf.datasetName
        case 'ImageCLEF2012'   
            num_classes = conf.class.Num;            
            end_Idx = min(end_Idx,num_classes);
            pathloc = fullfile(conf.dir.rootDir,'train_annotations/concepts');    
            pathToFeaturesDirTrain=fullfile(conf.dir.rootDir,'train_images/images');   
            % for ci=start_Idx: step: end_Idx
            for ci=1: num_classes
                class_ci = Classes{ci};            
                % Doc file trong thu muc 
                                            
                fprintf('\n\t\t Processing class: %s (%d/%d) ...',class_ci,ci,num_classes);
                
                filename_sbow_of_class = [class_ci,'.sbow.mat'];
                path_filename_train = fullfile(pathToIMDBDirTrain, filename_sbow_of_class );
                path_filename_val   = fullfile(pathToIMDBDirVal, filename_sbow_of_class );
                
                if exist(path_filename_train,'file')
                    continue;
                end
                
                file_name_concept=[class_ci,'.txt'];
                path_file_name_concept = fullfile(pathloc,file_name_concept);                
                list_image_concepts = utility.readFileByLines(path_file_name_concept);
                num_images = length(list_image_concepts);             
           
                if num_images<1
                    error('Concept %s is empy !!', class_ci);
                end
                
                fprintf('\n\t\t\t --> Splitting data...');
                rand_indices = randperm(num_images);
                
                if num_images_train >0.0 && num_images_train <1.0                
                    num_images_train_in_class   = uint32(num_images_train*num_images);
                    num_images_val_in_class     = num_images - num_images_train_in_class;
                else
                    num_images_train_in_class   = num_images_train;
                    num_images_val_in_class     = num_images_val;
                end
                rand_indices_train = rand_indices(1:num_images_train_in_class);
                rand_indices_val   = rand_indices(num_images_train_in_class+1 : num_images);
                     

                fprintf('\n\t\t\t num_images: %d',num_images);
                fprintf('\n\t\t\t num_images_train_in_class: %d',num_images_train_in_class);
                fprintf('\n\t\t\t num_images_val_in_class: %d',num_images_val_in_class);
             
                
                dim_feature = conf.BOW.pooler.get_output_dim();
                instance_matrix         = zeros(dim_feature,num_images_train_in_class);
                val_instance_matrix     = zeros(dim_feature,num_images_val_in_class);
                    
                label_vector         = ones(1,num_images_train_in_class)*ci;
                val_label_vector     = ones(1,num_images_val_in_class)*ci;
                fprintf('\n\t\t Read file train:');
                for k=1: num_images_train_in_class       
                    filename_feature_of_image = sprintf('%s%s',list_image_concepts{rand_indices_train(k)},'.feat.mat');
                    path_filename_feature_of_image = fullfile(pathToFeaturesDirTrain,filename_feature_of_image);
                    tmpf = load(path_filename_feature_of_image);
                    instance_matrix(:,k) = tmpf.setOfFeatures(:,1);
                    fprintf('.');
                end
                fprintf('\n\t\t Read file val:');
                for k= 1 :  num_images_val_in_class
                    filename_feature_of_image = sprintf('%s%s',list_image_concepts{rand_indices_val(k)},'.feat.mat');
                    path_filename_feature_of_image = fullfile(pathToFeaturesDirTrain,filename_feature_of_image);
                    
                    tmpf = load(path_filename_feature_of_image);
                    val_instance_matrix(:,k) =  tmpf.setOfFeatures(:,1);       
                    fprintf('.');
                    
                end
                if num_images_train_in_class >0
                        fprintf('\n\t\t\t --> Save training data into file:%s...',filename_sbow_of_class);                        
                       % save(path_filename_train,'setOfFeatures','index','-v7.3');
                        save(path_filename_train,'instance_matrix','label_vector','rand_indices_train','-v7.3');
                end
                
                
                if num_images_val_in_class >0
                        fprintf('\n\t\t\t --> Save validation data into file:%s...',filename_sbow_of_class);                        
                        instance_matrix = val_instance_matrix;
                        label_vector = val_label_vector;
                    save(path_filename_val,'instance_matrix','label_vector','rand_indices_val','-v7.3');
                end    
             end
            ready = 1;
        case 'ILSVRC65'           
            num_items = 5700*5;
            train_data_global = zeros(100000, num_items);
            ids_global = cell(num_items);
            for fi=0:4
                filename_train_mat = sprintf('ilsvrc65.train.subset%d.llc.mat',fi);
                path_filename_train_mat = fullfile( conf.dir.rootDir,'features',filename_train_mat);      
                fprintf('\n\t\t Loadig file %s ...',path_filename_train_mat);
                train_data = load(path_filename_train_mat);
                fprintf('\n\t\t Concating data...');
                train_data_global(:, (fi)*5700+1:(fi+1)*5700) =  train_data.betas(:,1:5700);
                ids_global((fi)*5700+1:(fi+1)*5700 ) =  train_data.ids(1:5700);
            end
            fprintf(' done !!! ');
            file_data_label = fullfile(conf.dir.rootDir, 'code/ilsvrc65.train.gt');
            train_gt_map = hedging.read_gt(file_data_label);
            train_labels = zeros(num_items);
            for ii=1:num_items
%                 ids_global{ii}  %n02112826_6242
%                 train_gt_map.get(ids_global{ii}) % n02112826
                train_labels(ii) = conf.class2id_map.get(train_gt_map.get(ids_global{ii})); % 9
%                 pause;
            end
            num_classes = conf.class.Num;
            
            end_Idx = min(end_Idx,num_classes);
            for ci=start_Idx: step: end_Idx
                class_ci = Classes{ci};            
                train_labels_ci = conf.class2id_map.get(class_ci);
                fprintf('\n\t\t Processing class: %s (%d/%d) train_labels_ci=%d ...',class_ci,ci,num_classes,train_labels_ci);
                filename_sbow_of_class = [class_ci,'.sbow.mat'];
                path_filename_train = fullfile(pathToIMDBDirTrain, filename_sbow_of_class );
                
                if exist(path_filename_train,'file')
                    continue;
                end
                
                index_of_ci = find(train_labels==train_labels_ci);
                num_images = length(index_of_ci);
                    
                fprintf('\n\t\t\t --> Selecting data num_images=%d ...',num_images);
                num_images_train_selected_r = min(num_images_train,num_images);
                if num_images_train_selected_r == num_images       
                    instance_matrix = train_data_global(:,index_of_ci);  
                else
                    rand_indices = randperm(num_images);
                    rand_indices_train_selected   = rand_indices(1:num_images_train_selected_r); 
                    instance_matrix = train_data_global(:,index_of_ci(rand_indices_train_selected)); 
                end
                 label_vector = ci*ones(1,num_images_train_selected_r);
                
                   fprintf('\n\t\t\t --> Save training data into file:%s...',filename_sbow_of_class);                        
                   save(path_filename_train,'instance_matrix','label_vector','-v7.3');
                   fprintf(' finish !');
                
            end
            ready = 1;
          

        case 'ILSVRC2010'
        
            num_classes = conf.class.Num;
            fprintf('\n\t\t Validation dataset is ready !');
            fprintf('\n\t\t Testing dataset is ready !');
            if num_images_train == 0 
                fprintf('\n\t\t Selecting all image in class!');
                error('Co the tran bo nho !!!!!');
            end
            pathToFeaturesDirTrain = fullfile(pathToFeaturesDir,'train');
            
            
            for ci=start_Idx: step: end_Idx
                class_ci = Classes{ci};            
                fprintf('\n\t\t Processing class: %s (%d/%d)...',class_ci,ci,num_classes);
                filename_sbow_of_class = [class_ci,'.sbow.mat'];
                path_filename_train = fullfile(pathToIMDBDirTrain, filename_sbow_of_class );
                
                if exist(path_filename_train,'file')
                    continue;
                end
                
                filename_feature = [class_ci,'.sbow.mat'];
                path_filename_feature = fullfile(pathToFeaturesDirTrain, filename_feature);
                if ~exist(path_filename_feature,'file')
                    error('Features file of class %s not found !',class_ci);
                end
                
                fprintf('\n\t\t\t --> Loading file: %s...',filename_feature);
                tmpf = load(path_filename_feature); 
               
                % ILSVRC2010  index                  1x1019                 8152  double              
                % ILSVRC2010  setOfFeatures      50000x1019            203800000  single   
                num_images = size(tmpf.setOfFeatures,2);
                    
                fprintf('\n\t\t\t --> Selecting data...');
                num_images_train_selected_r = min(num_images_train,num_images);
                if num_images_train_selected_r == num_images       
                    instance_matrix = tmpf.setOfFeatures;  
                else
                    rand_indices = randperm(num_images);
                    rand_indices_train_selected   = rand_indices(1:num_images_train_selected_r); 
                    instance_matrix = tmpf.setOfFeatures(:,rand_indices_train_selected); 
                end
               label_vector = ci*ones(1,num_images_train_selected_r);
                
               fprintf('\n\t\t\t --> Save training data into file:%s...',filename_sbow_of_class);                        
               save(path_filename_train,'instance_matrix','label_vector','-v7.3');
               fprintf(' finish !');
             end
            ready = 1;
       
        case {'Caltech256','SUN397'}  
           % Chia moi class thanh 3 phan train/val/test
%             for ci = 1:num_classes
            for ci=start_Idx: step: end_Idx
                   % parfor ci = 1:num_classes
                    class_ci = Classes{ci};
                    fprintf('\n\t\t Processing class: %s (%d/%d)...',class_ci,ci,num_classes);
                    
                    filename_sbow_of_class = [class_ci,'.sbow.mat'];
                    path_filename_train = fullfile(pathToIMDBDirTrain, filename_sbow_of_class );
                    path_filename_test = fullfile(pathToIMDBDirTest, filename_sbow_of_class );
                    path_filename_val = fullfile(pathToIMDBDirVal, filename_sbow_of_class );
%                     if exist(path_filename_train,'file') && exist(path_filename_test,'file') && exist(path_filename_val,'file')
%                         continue;
%                     end
                    
                    filename_feature = [class_ci,'.mat'];
                    path_filename_feature = fullfile(pathToFeaturesDir, filename_feature);
                    if ~exist(path_filename_feature,'file')
                        error('Features of class %s not found %s !',class_ci,path_filename_feature);
                    end
                    fprintf('\n\t\t\t --> Loading file: %s...',filename_feature);
                    tmpf = load(path_filename_feature);            
                    % ims = cell_cur_code_tmp.ims;
                    num_images = length(tmpf.setOfFeatures); % kieu cell, moi cell: kich thuoc 32000 x 1 single
                    %  Features_Mat = cell2mat(tmpf.setOfFeatures);
                    fprintf('\n\t\t\t --> Splitting data...');
                    rand_indices = randperm(num_images);
                    if num_images_train >0.0 && num_images_train <1.0
                        num_images_train_in_class   = uint32(num_images_train*num_images);
                        num_images_val_in_class     = uint32(num_images_val*num_images);
                        num_images_test_in_class    = num_images - num_images_train_in_class - num_images_val_in_class;
                    else
                        num_images_train_in_class   = num_images_train;
                        num_images_val_in_class     = num_images_val;
                        num_images_test_in_class    = num_images_test;
                        
                    end
                    rand_indices_train = rand_indices(1:num_images_train_in_class);            
                    rand_indices_val   = rand_indices(num_images_train_in_class+1 : num_images_train_in_class+num_images_val_in_class);
                    rand_indices_test  = rand_indices(num_images_train_in_class+num_images_val_in_class+1 : num_images_train_in_class + num_images_val_in_class +num_images_test_in_class);
                    

                    fprintf('\n\t\t\t num_images: %.2f',num_images);
                    fprintf('\n\t\t\t num_images_train_in_class: %.2f',num_images_train_in_class);
                    fprintf('\n\t\t\t num_images_val_in_class: %.2f',num_images_val_in_class);
                    fprintf('\n\t\t\t num_images_test_in_class: %.2f',num_images_test_in_class);
               
                   
                    ndim =size(tmpf.setOfFeatures{1},1);
                    instance_matrix         = zeros(ndim,num_images_train_in_class);
                    test_instance_matrix    = zeros(ndim,num_images_test_in_class);
                    val_instance_matrix     = zeros(ndim,num_images_val_in_class);
                    
                    label_vector         = ones(1,num_images_train_in_class)*ci;
                    val_label_vector     = ones(1,num_images_val_in_class)*ci;
                    test_label_vector    = ones(1,num_images_test_in_class)*ci;

                    for k=1: num_images_train_in_class                  
                        instance_matrix(:,k) = tmpf.setOfFeatures{rand_indices_train(k)};
                    end
                     % instance_matrix(:,1:num_images_train_in_class) = tmpf.setOfFeature(:,rand_indices_train);
                    for k=1: num_images_test_in_class
                        test_instance_matrix(:,k) = tmpf.setOfFeatures{rand_indices_test(k)};

                    end
                    for k= 1 :  num_images_val_in_class
                        val_instance_matrix(:,k) = tmpf.setOfFeatures{rand_indices_val(k)};                
                    end

                    
                    if num_images_train_in_class >0
                        fprintf('\n\t\t\t --> Save training data into file:%s...',filename_sbow_of_class);                        
                       % save(path_filename_train,'setOfFeatures','index','-v7.3');
                        save(path_filename_train,'instance_matrix','label_vector','rand_indices_train','-v7.3');
                    end
                    if num_images_test_in_class >0
                        fprintf('\n\t\t\t --> Save testing data into file:%s...',filename_sbow_of_class);
                        
                        instance_matrix = test_instance_matrix;
                        label_vector = test_label_vector;
                        save(path_filename_test,'instance_matrix','label_vector','rand_indices_test','-v7.3');
                    end
                    if num_images_val_in_class >0
                        fprintf('\n\t\t\t --> Save validation data into file:%s...',filename_sbow_of_class);
                        
                        instance_matrix = val_instance_matrix;
                        label_vector = val_label_vector;

                        save(path_filename_val,'instance_matrix','label_vector','rand_indices_val','-v7.3');
                    end
            end         
            ready = 1;
            
    end
    
    if ready == 1
        save(conf.IMDB.path_filename_ready,'ready','-v7.3');  
        fprintf('\n\t End of SplitTrainValTest !');
    end
    
end
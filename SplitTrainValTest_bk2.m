function conf = SplitTrainValTest( conf)
        

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
    fprintf('\n conf.IMDB.num_images_train: %.2f',conf.IMDB.num_images_train);
    fprintf('\n conf.IMDB.num_images_val: %.2f',conf.IMDB.num_images_val);
    fprintf('\n conf.IMDB.num_images_test: %.2f',conf.IMDB.num_images_test);
  
    output_dim = conf.BOW.pooler.get_output_dim;
    if num_images_val>1
        val_instance_matrix  = zeros(output_dim,num_images_val);
    end
    if num_images_test>1
        test_instance_matrix = zeros(output_dim,num_images_test);
    end

    num_classes = conf.class.Num;
    num_images_val_selected = conf.IMDB.num_images_val; %conf.val.num_img_per_class;
    
    switch conf.datasetName
        case 'ILSVRC2010'
            
            path_filename_val_50 ='/data/Dataset/LSVRC/2010/experiments/train300.val50.test150/binclassifiers/ILSVRC2010.val50.sbow.mat';
            path_filename_val_30 ='/data/Dataset/LSVRC/2010/experiments/train300.val50.test150/binclassifiers/ILSVRC2010.val30.sbow.mat';
            path_filename_pre_valval_50 ='/data/Dataset/LSVRC/2010/experiments/train300.val50.test150/binclassifiers/ILSVRC2010.val50.val50.mat'
            if ~exist(path_filename_val_50,'file') || exist(path_filename_val_30,'file')
                fprintf('Da co file');
            else
           
                val50 = load (path_filename_val_50);             
                % val50.instance_matrix: [50000x50000 double]
                % val50.label_vector: [50000x1 double]

               % fileLabel=  fullfile(conf.dir.rootDir,'data/ILSVRC2010_validation_ground_truth.txt');
               % val50_label_vector = dlmread(fileLabel);
                val50_label_vector = val50.label_vector;
                num_gt_label_vector=length(val50_label_vector);
                assert( num_gt_label_vector >= num_images_val_selected*num_classes);
                [val_label_vector_sorted, index_in_val] = sort(val50_label_vector);

            %             val_label_vector_selected = zeros(num_images_val_selected*num_classes,1);
            %             index_in_val_selected= zeros(num_images_val_selected*num_classes,1);
            %             
                i=1;
                idx_selected=1;
                while i<=num_gt_label_vector
                    kk=1;
            %                 val_label_vector_selected(idx_selected) = val_label_vector_sorted(i);
                    while kk <= num_images_val_selected && i< num_gt_label_vector && val_label_vector_sorted(i) == val_label_vector_sorted(i+1)
                        val_label_vector_selected(idx_selected) = val_label_vector_sorted(i);
                        index_in_val_selected(idx_selected) = index_in_val(i);
                        kk = kk+1;
                        i= i+1;
                        idx_selected=idx_selected+1;

                    end
                    if kk <= num_images_val_selected                  
                        val_label_vector_selected(idx_selected) = val_label_vector_sorted(i);
                        index_in_val_selected(idx_selected) = index_in_val(i);  
                        i= i+1;
                        idx_selected=idx_selected+1;
                    end
                    while i<num_gt_label_vector && val_label_vector_sorted(i) == val_label_vector_sorted(i+1)                    
                        i= i+1;
                    end
                    i= i+1;
                end

                 instance_matrix = val50.instance_matrix(:, index_in_val_selected);
                 label_vector = val50.label_vector(index_in_val_selected,1);
                 save(path_filename_val_30,'instance_matrix','label_vector','-v7.3');
            end
        case 'Caltech256'        
            for ci = 1:num_classes
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
                        error('Features of class %s not found !',class_ci);
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
                    
                    label_vector    = ones(1,num_images_train_in_class)*ci;
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
                        save(path_filename_train,'instance_matrix','label_vector','-v7.3');
                    end
                    if num_images_test_in_class >0
                        fprintf('\n\t\t\t --> Save testing data into file:%s...',filename_sbow_of_class);
                        
                        instance_matrix = test_instance_matrix;
                        label_vector = test_label_vector;
                        save(path_filename_test,'instance_matrix','label_vector','-v7.3');
                    end
                    if num_images_val_in_class >0
                        fprintf('\n\t\t\t --> Save validation data into file:%s...',filename_sbow_of_class);
                        
                        instance_matrix = val_instance_matrix;
                        label_vector = val_label_vector;

                        save(path_filename_val,'instance_matrix','label_vector','-v7.3');
                    end
            end
          
            
    end
    ready = 1;
    save(conf.IMDB.path_filename_ready,'ready','-v7.3');  
    fprintf('\n\t End of SplitTrainValTest !');
    
end
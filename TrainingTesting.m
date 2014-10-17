function conf  = TrainingTesting(conf)
%TrainingTesting Thuc hien training cho tap du lieu
% Dung pp precomputed kernel
% 
    fprintf('\n Training model of classifiers...');   
    %% Tao thu muc trong chua ket qua tung class 
    pathToIMDBDir = conf.path.pathToIMDBDir;
    pathToModelClassifer = conf.path.pathToModelClassifer;
    pathToFeaturesDirTrain = fullfile(conf.path.pathToFeaturesDir,'train');
    
    for i=1:conf.class.Num
        ClassName = conf.class.Names{i};
        pathToDirClass = fullfile(pathToModelClassifer,ClassName);
        MakeDirectory(pathToDirClass);
    end
    %% Tao tap du lieu train cho tung class    

    num_img_pos_per_class   = conf.svm.num_img_pos_per_class; 
    num_img_neg_per_class   = conf.svm.num_img_neg_per_class;    
   
    num_img_neg_per_class_selected = conf.svm.num_img_neg_per_class_selected;         
    total_img_per_class     = num_img_pos_per_class + num_img_neg_per_class;

    output_dim = conf.BOW.pooler.get_output_dim;
    assert(output_dim>0);
    
    instance_matrix = zeros(output_dim, total_img_per_class);        
    label_vector    = - ones(1, total_img_per_class);     
    label_vector(:,1:num_img_pos_per_class) = 1;  
    numClass = conf.class.Num;
    % Tao tap nagative
    
    fprintf('\n\t Creating nagative dataset...');
    filename_neg_set = conf.svm.filename_neg_set;
    path_filename_neg_set = fullfile (pathToFeaturesDirTrain,filename_neg_set);
    if exist(path_filename_neg_set,'file')
        load (path_filename_neg_set);
        fprintf('finish (ready) !');
    else
        neg_idx_matrix      = zeros(numClass,num_img_neg_per_class);
        start =1;
        if conf.svm.select_nagative_random
            
            total_images_neg    = (numClass-1)*num_img_pos_per_class;           
            for i=1:numClass
                % Chon mau am cho tung nhom
                    rand_indices = randperm(total_images_neg);    
                    neg_idx_matrix(i,:) = sort(rand_indices(1:num_img_neg_per_class));  
            end
        else            
            for i=1:numClass
                fprintf('\n\t Class %d',i);
                start =1;
                for j=1: numClass-1
                    rand_indices = randperm(num_img_pos_per_class); 
                    %index_selected = rand_indices(1:num_img_neg_per_class_selected);

                    neg_idx_matrix(i,start: start + num_img_neg_per_class_selected -1) = rand_indices(1:num_img_neg_per_class_selected);%sort(index_selected);  
                    start = start + num_img_neg_per_class_selected;
                end
            end
        end
        save(path_filename_neg_set,'neg_idx_matrix','-v7.3');
        fprintf('finish !');
    end
    
    fprintf('\n\t Creating training dataset for each class...');

    suffix_file_train=conf.svm.suffix_file_train;
    
    for i=70:numClass-200      
        
        ClassName = conf.class.Names{i};            
        pathToDirClass = fullfile(pathToModelClassifer,ClassName);
        filename_data_to_train = [ClassName,suffix_file_train];
        path_filename_data_to_train = fullfile(pathToDirClass, filename_data_to_train ); 
        
        
        if exist(path_filename_data_to_train, 'file')
          %  fprintf('finish (ready) !');
            continue;
        end
        fprintf('\n\t\t class (%3d): %s ...',i,ClassName);
        tic
        % Chon ngau nhien cac anh lam mau duong
        filename_feature = [ClassName,'.sbow.mat'];
        path_filename_feature = fullfile(pathToFeaturesDirTrain,filename_feature);
        if ~exist(path_filename_feature, 'file')
            error('Error: File %s is not found !', path_filename_feature);            
        end
        
        fprintf('\n\t\t Loading positive samples from file %s ...  ', filename_feature);
        tmp = load(path_filename_feature); % setOfFeatures = 50.000(kich thuoc feature) x (so anh)
        fprintf('finish!');
        
        % Cho cac anh dau tien
        instance_matrix(:,1:num_img_pos_per_class) = tmp.setOfFeatures(:,1:num_img_pos_per_class);  
        clear tmp;  
        
        % Chon cac anh negative 
        fprintf('\n\t\t Loading nagative samples....');        
        start = num_img_pos_per_class +1;    
        orgin_start_idx = num_img_pos_per_class ; 
        idx_neg_arr = neg_idx_matrix(i,:);
        if  conf.svm.select_nagative_random
            for j=1:i-1
                 % Chon ngau nhien cac anh lam mau negative

                ClassName_Neg = conf.class.Names{j};
                path_filename_feature_neg = fullfile(pathToFeaturesDirTrain,[ClassName_Neg,'.sbow.mat']);
                if ~exist(path_filename_feature_neg, 'file')
                    error('Error: File %s is not found !', path_filename_feature_neg);            
                end

                idx_start_j = num_img_pos_per_class*(j-1) +1;
                idx_end_j   = idx_start_j + (num_img_pos_per_class -1) ;

                idex1 = find(idx_neg_arr >=idx_start_j);
                if ~isempty(idex1)
                    idx_neg_arr2 = idx_neg_arr(idex1);
                    idex2 = find( idx_neg_arr2  <=idx_end_j);
                    if ~isempty(idex2)
                        idex2 = idex2 + idex1(1)-1;
                        index = idx_neg_arr(idex2) - idx_start_j+1;
                        n_index = length(index);
                        if n_index > 0
                            S = load(path_filename_feature_neg); % doc bag of word cua train
                            instance_matrix(:,start:start + n_index -1 ) = S.setOfFeatures(:,index);
                            start = start + n_index;
                        end
                    end
                end
            end
            for j=i+1:numClass
                ClassName_Neg = conf.class.Names{j};
                path_filename_feature_neg = fullfile(pathToFeaturesDirTrain,[ClassName_Neg,'.sbow.mat']);
                if ~exist(path_filename_feature_neg, 'file')
                    error('Error: File %s is not found !', path_filename_feature_neg);            
                end


                idx_start_j = num_img_pos_per_class*(j-2) +1;
                idx_end_j   = idx_start_j + (num_img_pos_per_class -1) ;

                idex1 = find(idx_neg_arr >=idx_start_j);
                if ~isempty(idex1)
                    idx_neg_arr2 = idx_neg_arr(idex1);
                    idex2 = find( idx_neg_arr2  <=idx_end_j);
                    if ~isempty(idex2)
                        idex2 = idex2 + idex1(1)-1;
                        index = idx_neg_arr(idex2) - idx_start_j+1;
                        n_index = length(index);
                        if n_index > 0
                            S = load(path_filename_feature_neg); % doc bag of word cua train
                            instance_matrix(:,start:start + n_index -1 ) = S.setOfFeatures(:,index);
                            start = start + n_index;
                        end
                    end
                end
            end
        else  % chon deu nhau trong tung class
           % start =num_img_pos_per_class;
            for j=1:i-1
                % Chon ngau nhien cac anh lam mau negative
                ClassName_Neg = conf.class.Names{j};
                path_filename_feature_neg = fullfile(pathToFeaturesDirTrain,[ClassName_Neg,'.sbow.mat']);
                if ~exist(path_filename_feature_neg, 'file')
                    error('Error: File %s is not found !', path_filename_feature_neg);            
                end
                S = load(path_filename_feature_neg); % doc bag of word cua train
                index = neg_idx_matrix(i,start-orgin_start_idx: start + num_img_neg_per_class_selected -1-orgin_start_idx);
                instance_matrix(:,start:start + num_img_neg_per_class_selected -1 ) = S.setOfFeatures(:,index);
                start = start + num_img_neg_per_class_selected;                   
            end
            for j=i+1:numClass
                ClassName_Neg = conf.class.Names{j};
                path_filename_feature_neg = fullfile(pathToFeaturesDirTrain,[ClassName_Neg,'.sbow.mat']);
                if ~exist(path_filename_feature_neg, 'file')
                    error('Error: File %s is not found !', path_filename_feature_neg);            
                end
                S = load(path_filename_feature_neg); % doc bag of word cua train
                index = neg_idx_matrix(i,start-orgin_start_idx: start + num_img_neg_per_class_selected -1 -orgin_start_idx);
                instance_matrix(:,start:start + num_img_neg_per_class_selected -1 ) = S.setOfFeatures(:,index);
                start = start + num_img_neg_per_class_selected;   
            end
        end
        fprintf('finish!');
        
        % save
    
        fprintf('\n\t\t Precomputing kernel ...');
        pre_matrix = instance_matrix' * instance_matrix;
        fprintf('finish !');
        fprintf('\n\t\t Saving training dataset to file...');
        save(path_filename_data_to_train,'instance_matrix','label_vector','pre_matrix','-v7.3');
        fprintf('finish !');
        clear pre_matrix;
        toc;
    end
   
    % Thuc hien training
    classifier.Training(conf);     
    precompkernel.PreComp_ValTrain(conf);
    precompkernel.PreComp_TestTrain(conf);    
    precompkernel.PreComp_TestOnTest(conf, 1,conf.class.Num, 1);
    return;
     
    precompkernel.PreComp_TestVal(conf);
    precompkernel.PreComp_ValVal(conf);
    precompkernel.PreComp_TestOnVal(conf, 1,conf.class.Num, 1);
   
   
    
end


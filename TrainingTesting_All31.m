function TrainingTesting_All3(conf, start_Idx,end_Idx, step)
%TrainingTesting Thuc hien training cho tap du lieu
% Dung pp precomputed kernel
% 
    if step < 0
		if( start_Idx < end_Idx)
			error('Parameters is invalidate !');
		end
	elseif step >0 
		if( start_Idx > end_Idx)
			error('Parameters is invalidate !');
		end	
	else 
		error('Parameters is invalidate !');
    end

    assert(start_Idx>0);
    assert(end_Idx<= conf.class.Num);
    %% ------
    fprintf('\n +----------------------------------------------------+'); 
    fprintf('\n | Training model of binary classifiers 2 2...                   |');   
    fprintf('\n +----------------------------------------------------+');
    %% Tao thu muc trong chua ket qua tung class 
 
  %  pathToBinaryClassiferModels = conf.experiment.pathToBinaryClassiferModels;
    pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ;  
    pathToBinaryClassifer       = conf.experiment.pathToBinaryClassifer;
    
 
    str_test =  conf.test.str_test;
    
    path_filename_classifier_ready  = fullfile(pathToBinaryClassiferTrains,  conf.svm.filename_classifier_ready);
    path_filename_valtrain_ready    = fullfile(pathToBinaryClassiferTrains,[ conf.svm.prefix_ready_valtrain,  conf.val.str_val,  conf.svm.suffix_ready_valtrain]);
    path_filename_testtrain_ready   = fullfile(pathToBinaryClassiferTrains,[ conf.svm.prefix_ready_testtrain, conf.test.str_test,conf.svm.suffix_ready_testtrain]);

    if  exist (path_filename_classifier_ready,'file') && ... 
        exist (path_filename_valtrain_ready,'file') &&  ...
        exist (path_filename_testtrain_ready,'file')
       fprintf('\n Finish (ready) !');
       return;
    end
    
    pathToBinaryClassiferTrainsClass = cell(conf.class.Num,1);
    % Tao thu muc chua dataset cho tung class
    for i=1:conf.class.Num
        ClassName = conf.class.Names{i};
        pathToBinaryClassiferTrainsClass{i} = fullfile(pathToBinaryClassiferTrains,ClassName);
        MakeDirectory(pathToBinaryClassiferTrainsClass{i});
    end
    %% Tao tap du lieu train cho tung class    

    num_img_pos_per_class   = conf.svm.num_img_pos_per_class; 
    num_img_neg_per_class   = conf.svm.num_img_neg_per_class;    
   
    num_img_neg_per_class_selected  = conf.svm.num_img_neg_per_class_selected;         
    total_img_per_class             = num_img_pos_per_class + num_img_neg_per_class;
    solver = conf.svm.solver;
    numClass = conf.class.Num;
    
    conf.randSeed = 1 ;
    randn('state',conf.randSeed) ;
    rand('state',conf.randSeed) ;
    vl_twister('state',conf.randSeed) ;

    
    % Tao tap nagative
    
        
    fprintf('\n\t Creating nagative dataset...');
    filename_neg_set = conf.svm.filename_neg_set;
    path_filename_neg_set = fullfile (pathToBinaryClassiferTrains,filename_neg_set);
    if exist(path_filename_neg_set,'file')
        load (path_filename_neg_set);
        fprintf('finish (ready (%s)) !',filename_neg_set);
    else
        neg_idx_matrix      = zeros(numClass,num_img_neg_per_class);       
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
        fprintf('\n\t Save file %s...', filename_neg_set);
        save(path_filename_neg_set,'neg_idx_matrix','-v7.3');
        fprintf('finish !');
    end
    
 
    
    
    filename_val   = conf.val.filename;
    path_filename_val   = fullfile(conf.experiment.pathToBinaryClassifer, filename_val);
    if ~exist (path_filename_val,'file')
             error('File %s is not found !',path_filename_val);        
    end
    
    fprintf('\n\t Loading validation dataset from file: %s ...',filename_val);
    validation = load(path_filename_val); %,'instance_matrix','label_vector','-v7.3');    
    fprintf('finish !'); 
    
     if strcmp( conf.datasetName,'Caltech256')
        filename_test  = conf.test.filename;
        path_filename_test  = fullfile(conf.experiment.pathToBinaryClassifer, filename_test); 
        % Load tap test
        if ~exist(path_filename_test,'file')
             error('Error: File %s is not found !',path_filename_test);
        end
        fprintf('\n\t Loading testing dataset from file: %s...',filename_test);        
        testing = load(path_filename_test); %,'instance_matrix',label_vector','-v7.3');   
        fprintf('finish !');
     end
        
     
    %% --------------------------------------------------------------------
    %  Thuc hien tao train data cho tung class
    fprintf('\n\t -------------------------------------------');
    fprintf('\n\t Creating training dataset for each class...');
    suffix_file_train       = conf.svm.suffix_file_train;
    suffix_file_model       = conf.svm.suffix_file_model;
    suffix_file_testtrain   = conf.svm.suffix_file_testtrain;   
    suffix_file_valtrain    = conf.svm.suffix_file_valtrain ;
    
    output_dim = conf.BOW.pooler.get_output_dim;
    assert(output_dim>0);    
        
    pathToIMDBDirTrain  = conf.path.pathToIMDBDirTrain;
    pathToIMDBDirVal    = conf.path.pathToIMDBDirVal;
    pathToIMDBDirTest   = conf.path.pathToIMDBDirTest;
    if strcmp( conf.datasetName,'ILSVRC2010')  
       pathToIMDBDirTrain    = fullfile(conf.path.pathToFeaturesDir, 'train');
       pathToIMDBDirTest  = fullfile(conf.path.pathToFeaturesDir, 'test');
       
       pathToIMDBDirVal = fullfile(conf.path.pathToFeaturesDir, 'val');
   end
    libsvmoption = conf.svm.libsvmoption;        
    preComputed_Kernel  = conf.svm.preCompKernel;
    if strcmp(conf.datasetName,'ILSVRC2010')      
        gtruth_test_file= fullfile(conf.dir.rootDir,'data/ILSVRC2010_test_ground_truth.txt');    
        gt_test_label_vector = dlmread(gtruth_test_file);
    end
       
    
 
    
    for i= start_Idx:step:end_Idx %1:numClass      
        
        ClassName = conf.class.Names{i};            
        % pathToDirTrain = fullfile(pathToBinaryClassiferTrains,ClassName);
        pathToDirTrain = pathToBinaryClassiferTrainsClass{i};
        fprintf('\n\t class (%3d): %s ...',i,ClassName);
        if conf.svm.preCompKernel
            path_filename_class_ready =  fullfile(pathToDirTrain,[ClassName,conf.svm.solver , '.pre.linear.ready.mat']);
        else
            path_filename_class_ready =  fullfile(pathToDirTrain,[ClassName,conf.svm.solver , '.ready.mat']);
        end
        if exist(path_filename_class_ready, 'file')  
            fprintf('finish (ready) !');  
            continue;
        end
        % -----------------------------------------------------------------
        % Tao tap du lieu de train
        % Chon ngau nhien cac anh lam mau duong
        filename_data_to_train = [ClassName,suffix_file_train];
        path_filename_data_to_train = fullfile(pathToDirTrain, filename_data_to_train ); 
        
        filename_model = sprintf('%s.%s%s',ClassName,solver,suffix_file_model);
        path_filename_model = fullfile(pathToDirTrain,filename_model );   
        
        fprintf('\n\t\t Creating training dataset...');
        if ~exist(path_filename_model, 'file')
%         if exist(path_filename_data_to_train, 'file')  
%             if exist(path_filename_model, 'file')
%                 fprintf('finish (ready) !');  
%                 %%%
%                 fprintf('\n\t\t Loading training data from file %s ...  ', filename_data_to_train);
%            %%%     load(path_filename_data_to_train);
%                 fprintf('finish (ready) !');  
%             else
%                 fprintf('\n\t\t Loading training data from file %s ...  ', filename_data_to_train);
%             %%    load(path_filename_data_to_train);
%                 fprintf('finish (ready) !');  
%             end
%         else
            
            filename_feature = [ClassName,'.sbow.mat'];
            path_filename_feature = fullfile(pathToIMDBDirTrain,filename_feature);
            if ~exist(path_filename_feature, 'file')
                error('Error: File %s is not found !', path_filename_feature);            
            end
            
            instance_matrix = zeros(output_dim, total_img_per_class);        
            label_vector    = - ones(1, total_img_per_class);     
            label_vector(:,1:num_img_pos_per_class) = 1;  
            tic
            
            fprintf('\n\t\t Loading positive samples from file: %s ...  ', filename_feature);
            tmp = load(path_filename_feature); % instance_matrix = 50.000(kich thuoc feature) x (so anh)
            fprintf('finish!');

            % Cho cac anh dau tien
            if strcmp(conf.datasetName,'ILSVRC2010') 
                instance_matrix(:,1:num_img_pos_per_class) = tmp.setOfFeatures(:,1:num_img_pos_per_class); 
            else
                instance_matrix(:,1:num_img_pos_per_class) = tmp.instance_matrix(:,1:num_img_pos_per_class);  
            end
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
                    path_filename_feature_neg = fullfile(pathToIMDBDirTrain,[ClassName_Neg,'.sbow.mat']);
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
                    path_filename_feature_neg = fullfile(pathToIMDBDirTrain,[ClassName_Neg,'.sbow.mat']);
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
                fprintf('.');
                for j=1:i-1
                     fprintf('.');
                    % Chon ngau nhien cac anh lam mau negative
                    ClassName_Neg = conf.class.Names{j};
                    path_filename_feature_neg = fullfile(pathToIMDBDirTrain,[ClassName_Neg,'.sbow.mat']);
                    if ~exist(path_filename_feature_neg, 'file')
                        error('Error: File %s is not found !', path_filename_feature_neg);            
                    end
                    S = load(path_filename_feature_neg); % doc bag of word cua train
                    index = neg_idx_matrix(i,start-orgin_start_idx: start + num_img_neg_per_class_selected -1-orgin_start_idx);
                    
                    if strcmp(conf.datasetName,'ILSVRC2010')                         
                        
                        instance_matrix(:,start:start + num_img_neg_per_class_selected -1 ) = S.setOfFeatures(:,index);
                    else
                        instance_matrix(:,start:start + num_img_neg_per_class_selected -1 ) = S.instance_matrix(:,index);
                    end
                    
                    start = start + num_img_neg_per_class_selected;                   
                end
                for j=i+1:numClass
                    fprintf('.');
                    ClassName_Neg = conf.class.Names{j};
                    path_filename_feature_neg = fullfile(pathToIMDBDirTrain,[ClassName_Neg,'.sbow.mat']);
                    if ~exist(path_filename_feature_neg, 'file')
                        error('Error: File %s is not found !', path_filename_feature_neg);            
                    end
                    S = load(path_filename_feature_neg); % doc bag of word cua train
                    index = neg_idx_matrix(i,start-orgin_start_idx: start + num_img_neg_per_class_selected -1 -orgin_start_idx);
                    if strcmp(conf.datasetName,'ILSVRC2010')                         
                        instance_matrix(:,start:start + num_img_neg_per_class_selected -1 ) = S.setOfFeatures(:,index);
                    else
                        instance_matrix(:,start:start + num_img_neg_per_class_selected -1 ) = S.instance_matrix(:,index);
                    end
                    
                    start = start + num_img_neg_per_class_selected;   
                end
            end
            fprintf('finish!');

            % save
            if (preComputed_Kernel)	
                fprintf('\n\t\t Precomputing kernel ...');
                pre_matrix = instance_matrix' * instance_matrix;
                fprintf('finish !');
            else 
                pre_matrix=0;
            end
            fprintf('\n\t\t Saving training dataset to file...');
         %   save(path_filename_data_to_train,'instance_matrix','label_vector','pre_matrix','-v7.3');
            fprintf('finish !');            
            toc;
        end
 
        % -----------------------------------------------------------------
        % Da tao xong ma tran 'instance_matrix','label_vector','pre_matrix'
        % Thuc hien learning classifier
        % Training
        fprintf('\n\t\t Training libsvmoption =%s...',libsvmoption);        
        % --------------------------------------------------------------------
        %                                                            Train SVM
        % --------------------------------------------------------------------
%         filename_model = sprintf('%s.%s%s',ClassName,solver,suffix_file_model);
%         path_filename_model = fullfile(pathToDirTrain,filename_model );   
        if exist(path_filename_model, 'file')
            load(path_filename_model);
            fprintf('finish (ready) !');  
        else        
            tic     
            switch conf.svm.solver
                case 'libsvm'
                    if (preComputed_Kernel)					
                        numTrain = length(label_vector);
                        K = [(1:numTrain)', pre_matrix+eye(numTrain)*realmin];    
                       % K = [(1:numTrain)', pre_matrix ]; 
                        if ~isa(K,'double');
                            K =double(K);
                        end

                       
                        model = svmtrain(label_vector', K, libsvmoption);


                        clear K;           
                    else		
%                          whos;
%                         pause;
                        model = svmtrain(label_vector', sparse(instance_matrix'), libsvmoption);                
                    end
                case 'liblinear'
                    model = train(label_vector', sparse(instance_matrix'),libsvmoption); 
                    
                case {'sgd', 'sdca'}
                    % --------------------------------------------------------------------
                    %                                                  Compute feature map
                    % --------------------------------------------------------------------
                    psix = vl_homkermap(instance_matrix, 1, 'kchi2', 'gamma', .5) ;
                    
                    lambda = 1 / (conf.svm.C *  length(label_vector)) ;  
                   
                    [model.w,model.b, model.info] = vl_svmtrain(psix , label_vector', lambda, ...
                      'Solver', conf.svm.solver, ...
                      'MaxNumIterations', 50/lambda, ...
                      'BiasMultiplier', conf.svm.biasMultiplier, ...
                      'Epsilon', 1e-3);
                  model.b = conf.svm.biasMultiplier * model.b;
                  
                   % Estimate the class of the test images
                    scores = model.w' * psix + model.b' * ones(1,size(psix,2)) ;
                    
                    
                    
                    predict_tmp_m = zeros(size(scores));
                    predict_tmp_m(find(scores>=0))= 1 ;
%                      whos;
%                      model
%                      model.info
%                      pause;
                    accuracy_m = length(find(predict_tmp_m==label_vector)) %/length(find(val_label_vector==i))
            end
            % Save mo hinh

            fprintf('\n\t\t Saving model to file ...');
            save(path_filename_model, 'model','-v7.3');			   
            fprintf('finish !');
            fprintf('\n\t\t ');                  
            toc
        end
        clear pre_matrix;
        
      
        
        % -----------------------------------------------------------------
        % Thuc hien precomputed co val_train
        % tap val chi co 1 file ?

    
        filename_valtrain       = [ClassName,  conf.svm.str_pre,  conf.val.str_val ,suffix_file_valtrain];
        path_filename_valtrain  = fullfile(pathToDirTrain, filename_valtrain);
        
        filename_libsvm_val      =     [ ClassName ,conf.val.midle_file_test,conf.val.str_val,'.mat'] ;
        path_filename_libsvm_val = fullfile(pathToDirTrain,filename_libsvm_val);
        
%         if exist( path_filename_valtrain, 'file')
%             if ~exist( path_filename_libsvm_val, 'file') 
%                 load(path_filename_valtrain);                 
%             end

        fprintf('\n\t\t Predicting on validation dataset... ');
        if exist( path_filename_libsvm_val, 'file')            
            fprintf('finish (ready) !'); 
        else
            val_label_vector = validation.label_vector;
            numTest = length(val_label_vector);
            val_label_vector_test = zeros(1,numTest);
            val_label_vector_test(find(val_label_vector==i) ) = 1;
            val_label_vector_test= val_label_vector_test';
            
            switch conf.svm.solver
                case 'libsvm'
                    if (preComputed_Kernel)	   
                        fprintf('\n\t\t Precomputing kernel between validation and training data ...');
                        % Tinh ket qua precomputed
                        % val_instance_matrix  :  32.000 x 7710
                        % instance_matrix      :  32.000 x 330
                        pre_valtrain_matrix  = validation.instance_matrix' * instance_matrix;
                        fprintf('finish !');

                        fprintf('\n\t\t Saving pre_valtrain_matrix to file ...');
            %             save(path_filename_valtrain,  'pre_valtrain_matrix','val_label_vector','-v7.3');	
                        fprintf('finish !');                        

                        if ~isa(pre_valtrain_matrix,'double')
                            pre_valtrain_matrix = double(pre_valtrain_matrix);
                        end
                        fprintf('\n\t\t Concating (1:numTest) + pre_valtrain_matrix to file ...');
                        input = [(1:numTest)', pre_valtrain_matrix];	
                        fprintf('finish !');                      
                        assert(size(val_label_vector_test,1)==size(input,1));
                        [predicted_label, accuracy, decision_values]= svmpredict(val_label_vector_test, input, model,'-b 1');
                        clear input;
                        clear pre_valtrain_matrix;
                    else
                        [predicted_label, accuracy, decision_values]= svmpredict(val_label_vector_test, validation.instance_matrix', model,'-b 1');
                    end

                case 'liblinear'
                    [predicted_label, accuracy, decision_values] = predict(val_label_vector_test, sparse(validation.instance_matrix'), model, '-b 1');   
                case {'sgd', 'sdca'}
                    % --------------------------------------------------------------------
                    %                                                  Compute feature map
                    % --------------------------------------------------------------------
                    psix = vl_homkermap(validation.instance_matrix, 1, 'kchi2', 'gamma', .5) ;
                    
                    % --------------------------------------------------------------------
                    %                                                Test SVM and evaluate
                    % --------------------------------------------------------------------

                    % Estimate the class of the test images
                    scores = model.w' * psix + model.b' * ones(1,size(psix,2)) ;
                    
                    [~,~,info] = vl_pr(validation.label_vector', scores) ;
                    ap = info.ap ;
                    ap11 = info.ap_interp_11 ;
                    fprintf(' AP %.2f; AP 11 %.2f\n', ap * 100, ap11*100) ;

                    [drop, predicted_label] = max(scores, [], 1) ;
                    decision_values = scores;
                    accuracy =1; % sum(val_label_vector_test==predicted_label)
                    
                    predict_tmp = zeros(size(scores));
                    predict_tmp(find(scores>=0))= i ;
                    accuracy = length(find(predict_tmp==val_label_vector)) %/length(find(val_label_vector==i))
            
            end

            fprintf('\n\t\t Saving result: %s...', filename_libsvm_val);
            save(path_filename_libsvm_val, 'predicted_label', 'accuracy', 'decision_values','val_label_vector','-v7.3');
            fprintf('finish !');
        end
        
        % -----------------------------------------------------------------
        % Thu hien precomputed co test_train
       
    
        fprintf('\n\n\t\t Precomputing kernel between testing and training data ...');        
        if strcmp( conf.datasetName,'Caltech256')  
            filename_libsvm_test        = [ClassName, conf.test.midle_file_test,conf.test.str_test,'.mat'] ;
            path_filename_libsvm_test 	= fullfile(pathToDirTrain, filename_libsvm_test);
       
            filename_testtrain = [ClassName,conf.svm.str_pre,  conf.test.str_test, suffix_file_testtrain];          
            path_filename_testtrain =fullfile(pathToDirTrain, filename_testtrain);
              
            %if ~exist (path_filename_testtrain, 'file')
            if ~exist (path_filename_libsvm_test, 'file')
                % test_instance_matrix :  32.000 x 5140
                % instance_matrix      :  32.000 x 330
                test_label_vector = testing.label_vector;
                numTest = length(test_label_vector);
                testing_label_vector = zeros(numTest,1); %test_label_vector;
                index_label_i = find(test_label_vector==i);
                testing_label_vector(index_label_i ) = 1;
                fprintf('\n\t\t\t Number of item in this class %d: %d',i,length(index_label_i));
                fprintf('\n\t\t\t ');
                
                if strcmp(conf.svm.solver, 'libsvm')
                    if (preComputed_Kernel)	   
                        pre_testtrain_matrix = testing.instance_matrix' * instance_matrix;   
                        
                         % Save mo hinh
%                         fprintf('\n\t\t Saving pre_testtrain_matrix to file ...');               
%                         save(path_filename_testtrain, 'pre_testtrain_matrix','test_label_vector','-v7.3');	 
%                         fprintf('finish !');
        %             else
        %                  if ~exist (path_filename_libsvm_test, 'file')
        %                     load(path_filename_testtrain);
        %                     
        %                  end
        %                  fprintf('finish (ready) !');  
        %             end
        %             % Thuc hien test
        %             if ~exist (path_filename_libsvm_test, 'file')
                        input = [(1:numTest)', pre_testtrain_matrix];
                        if ~isa(input,'double');
                            input =double(input);
                        end                       
                        [predicted_label, accuracy, decision_values]= svmpredict(testing_label_vector, input, model,'-b 1');
                        clear pre_testtrain_matrix;
                    else
                        [predicted_label, accuracy, decision_values]= svmpredict(testing_label_vector, testing.instance_matrix', model,'-b 1');
                    end
                    
                elseif strcmp(conf.svm.solver, 'liblinear')
                    [predicted_label, accuracy, decision_values] = predict_tmp(testing_label_vector, sparse(testing.instance_matrix'), model, '-b 1');            

                end            
               
                fprintf('\n\t\t Saving result: %s...', filename_libsvm_test);
                save(path_filename_libsvm_test, 'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');
                fprintf('finish !');   
                clear input;
            end
            
        elseif strcmp(conf.datasetName,'ILSVRC2010')        
            start = 1;
            
            for j=1:150 
                str_id = num2str(j,'%.4d');
                filename_test = ['test.',str_id,'.sbow.mat'] ;
                path_filename_test = fullfile(pathToIMDBDirTest, filename_test);
                
                
                filename_libsvm_test        = [ClassName, conf.svm.mid_file_test, sprintf('.test.%s.mat',str_id)] ;
                path_filename_libsvm_test 	= fullfile(pathToDirTrain, filename_libsvm_test);

                    
                fprintf('\n\t\t Test file %s ...',filename_test);
                if exist(path_filename_test,'file')
                    filename_testtrain = [ClassName,'.pre.test.',str_id,suffix_file_testtrain];
                    path_filename_testtrain = fullfile(pathToDirTrain,filename_testtrain);
                    fprintf('\n\t\t Precomputing kernel ...');

                    if ~exist(path_filename_testtrain,'file')
                        
                        load(path_filename_test); % save(filename,'setOfFeatures','index','-v7.3');

                        pre_testtrain_matrix = setOfFeatures' * instance_matrix;
                        test_label_vector   = gt_test_label_vector (start: start+1000 -1 );

                        fprintf('finish !');

                        fprintf('\n\t\t Saving pre_testval_matrix to file : %s...', filename_testtrain);
                        save(path_filename_testtrain, 'pre_testtrain_matrix','test_label_vector','-v7.3');
                        fprintf('finish !'); 
                    else
                        if ~exist (path_filename_libsvm_test, 'file')
                            load(path_filename_testtrain);
                        end
                        fprintf('finish (ready) !');
                        
                    end
                    clear setOfFeatures;
                    % Thuc hien test
                    if ~exist (path_filename_libsvm_test, 'file')
                        numTest = length(test_label_vector);
                        input = [(1:numTest)', pre_testtrain_matrix];
                        if ~isa(input,'double');
                               input =double(input);
                        end


                        testing_label_vector = -ones(numTest,1); %test_label_vector;
                        index_label_i = find(test_label_vector==i);
                        testing_label_vector(index_label_i ) = 1;
                        fprintf('\n\t\t\t Number of item in this class %d: %d',i,length(index_label_i));
                        fprintf('\n\t\t\t ');
                        [predicted_label, accuracy, decision_values]= svmpredict(testing_label_vector, input, model,'-b 1');


                        fprintf('\n\t\t Saving result: %s...', filename_libsvm_test);
                        save(path_filename_libsvm_test, 'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');
                        fprintf('finish !');   
                        clear input;
                    end                        
                    clear pre_testtrain_matrix;                    
                else
                    error('Missing test file %s !',path_filename_test);           
                end
                start = start+1000;
            end
        end
       clear instance_matrix;
       
       ready=1;
       save(path_filename_class_ready,  'ready','-v7.3');	
    end
  
    ready=1;
    save(path_filename_classifier_ready,  'ready','-v7.3');	
    ready=1;
    save(path_filename_valtrain_ready,  'ready','-v7.3');	
    ready=1;
    save(path_filename_testtrain_ready,  'ready','-v7.3');	
    
   
    return;
    % Thuc hien training
    classifier.Training(conf);     
    precompkernel.PreComp_ValTrain(conf);
    precompkernel.PreComp_TestTrain(conf);    
    precompkernel.PreComp_TestOnTest(conf, 1,conf.class.Num, 1);
    
     
    precompkernel.PreComp_TestVal(conf);
    precompkernel.PreComp_ValVal(conf);
    precompkernel.PreComp_TestOnVal(conf, 1,conf.class.Num, 1);
   
   
    
end


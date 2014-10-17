function [ conf ] = TrainOneVsAll_direct_linear( start_Idx,end_Idx, step)
%TrainingTesting Thuc hien training cho tap du lieu
% Dung pp precomputed kernel
%    

   fprintf('\n -----------------------------------------------');
   fprintf('\n TrainOneVsAll: training models ...');
  AddPathLib();
  conf.datasetName         = 'ILSVRC2010';  
   % conf.datasetName         = 'Caltech256'; 
  if strcmp( conf.datasetName,'ILSVRC2010')
    conf.dir.rootDir                = '/data/Dataset/LSVRC/2010';
    conf.path.pathToImagesDir       = '/data/Dataset/LSVRC/2010/images/train';
    path_filename_train_selected    = '/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/ILSVRC2010.train100.sbow.mat';
    path_filename_train_selected_sparse = '/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/ILSVRC2010.train100.sparse.sbow.mat';  
    path_filename_test_selected     = '/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/ILSVRC2010.val30.sbow.mat';
    pathToBinaryClassiferTrains     = '/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/train100.blaall';
    path_filename_classifier_ready  = '/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/train100.blaall/ILSVRC2010.linear.prob.classifier.ready.mat';
  elseif strcmp(conf.datasetName ,'Caltech256')
    conf.dir.rootDir              = '/data/Dataset/256_ObjectCategories';
    conf.path.pathToImagesDir     = '/data/Dataset/256_ObjectCategories/256_ObjectCategories';
    pathToBinaryClassiferTrains   = '/data/Dataset/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/train50p.blaall';
    path_filename_train_selected  = '/data/Dataset/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.train50p.sbow.mat';
    path_filename_test_selected   = '/data/Dataset/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.test25p.sbow.mat';
 
  end
  isTest = false;     
   
   conf  = LoadInforDataset( conf ); 
      
   %solver = 'sdca';
   solver = 'liblinear';
   switch solver
       case 'liblinear'
           fprintf('\n\t path_filename_train: %s',path_filename_train_selected_sparse);
           if ~exist(path_filename_train_selected_sparse,'file')
               error('training dataset not found !');    
           else
               fprintf('\n\t Loading training dataset ...');
               training = load(path_filename_train_selected_sparse);
               fprintf('finish !');
           end
   
       case 'sdca'
           fprintf('\n\t path_filename_train: %s',path_filename_train_selected);
           if ~exist(path_filename_train_selected,'file')
               error('training dataset not found !');    
           else
               fprintf('\n\t Loading training dataset ...');
               training = load(path_filename_train_selected);
               fprintf('finish !');
           end
   end
   
   
   if isTest
    fprintf('\n\t Loading testing dataset ...');
    testing = load (path_filename_test_selected);% save(path_filename_test_selected,'instance_matrix','label_vector','-v7.3');
    fprintf('finish !');
       
   end
   unique_label_vector = unique(training.label_vector);   
   num_classes = length( unique_label_vector);
   num_samples = length(training.label_vector);
  

   fprintf('\n\t conf.svm.solver: %s',solver);
   fprintf('\n\t num_classes: %d',num_classes);
   fprintf('\n\t num_samples: %d',num_samples);
   fprintf('\n\t size(training.instance_matrix)');
   size(training.instance_matrix)
  
%    whos
%    pause
%      
     
   pathToBinaryClassiferTrainsClass = cell(conf.class.Num,1);
    % Tao thu muc chua dataset va model cho tung class
   for i=1:conf.class.Num
        ClassName = conf.class.Names{i};
        pathToBinaryClassiferTrainsClass{i} = fullfile(pathToBinaryClassiferTrains,ClassName);
        MakeDirectory(pathToBinaryClassiferTrainsClass{i});
        
   end   
 
   suffix_file_model       = '.prob.model.mat';  

  
       
   
   for ci= start_Idx:step:end_Idx %1:numClass      
        
       
                  
      label_ci =  unique_label_vector(ci);      
      ClassName = conf.class.Names{label_ci};
      pathToDirTrain = pathToBinaryClassiferTrainsClass{label_ci};
 
      filename_model = sprintf('%s.%s%s',ClassName,solver,suffix_file_model);
      path_filename_model = fullfile(pathToDirTrain,filename_model );
  
      if exist(path_filename_model, 'file') 
          continue;
      end
      
      tic;
          fprintf('\n Selecting data of class %d / %d: %s...',ci,end_Idx, ClassName);
          pos_training_label_vector = find(training.label_vector==label_ci);
          neg_training_label_vector = setdiff((1:num_samples), pos_training_label_vector);

          tmpp_num_neg = length(neg_training_label_vector);
          tmpp_num_pos = length(pos_training_label_vector);
          ratio =  tmpp_num_neg/tmpp_num_pos
          libsvmoption = sprintf(' -w1 %f -w-1 1',  ratio);
          
          % Hoan vi de phan tu dau tien co nhan +1
          % size(training.instance_matrix)=[50000,300000].
          % svm_training_label_vector             300000x1  
          svm_training_label_vector = 2 * (training.label_vector==label_ci) - 1 ;      
          if size(svm_training_label_vector,1) < size(svm_training_label_vector,2) 
            svm_training_label_vector = svm_training_label_vector';
          end
          
          if svm_training_label_vector(1,1) ~=1
              tmp_pos = pos_training_label_vector(1)
%               whos
%               pause;
              tmp_instance_matrix = training.instance_matrix(:,1);
              training.instance_matrix(:,1) = training.instance_matrix(:,tmp_pos); 
              training.instance_matrix(:,tmp_pos) = tmp_instance_matrix;
             
              svm_training_label_vector(1,1) = 1;
              svm_training_label_vector(tmp_pos,1)=-1;
          end
          
          fprintf('\n Training model %d of class %s, num_pos=%d, num_neg=%d ',ci,ClassName,tmpp_num_pos,tmpp_num_neg);
          
          switch solver        
              case 'liblinear'
                  model = train(svm_training_label_vector,  training.instance_matrix,libsvmoption,'col');
                  fprintf('\n\t Saving model to file ...');
                  save(path_filename_model, 'model','-v7.3');			   
                  fprintf('finish !');

                  fprintf('\n\t Time to train: %f seconds\n', toc);
              case 'sdca'
                  weights = ones(1,num_samples);
                  weights (find(svm_training_label_vector==1)) = ratio;

                  fprintf('finish !');
                  
                 % model = train(svm_training_label_vector, svm_training_instance_matrix,libsvmoption);
                 lambda = 0.01;

                 %[model.w,model.b, model.info] = vl_svmtrain(training.instance_matrix , svm_training_label_vector, lambda,'Solver', solver)
                 [model.w,model.b, model.info] = vl_svmtrain(training.instance_matrix , svm_training_label_vector, lambda,'Solver', solver, 'Weights', weights);
        %          model.info
        %          pause
                  %[W B] = VL_SVMTRAIN(X, Y, LAMBDA) trains a linear Support Vector Machine (SVM) from the data vectors X and the labels Y. X is a D by N 
                  fprintf('\n\t Saving model to file ...');
                  save(path_filename_model, 'model','-v7.3');			   
                  fprintf('finish !');

                  fprintf('\n\t Time to train: %f seconds\n', toc);
                   if isTest
                      % thu tren tap validation
                      testing_label_vector = -ones(length(testing.label_vector),1);
                      testing_label_vector(find(testing.label_vector==label_ci))=1;
                       scores = model.w' * testing.instance_matrix + model.b' * ones(1,size(testing.instance_matrix,2)) ;
            %           [~,~,~, scores1] = vl_svmtrain(testing.instance_matrix, testing_label_vector, 0, 'model', model.w, 'bias', model.b, 'Solver', 'none') ;

                      predicted_label_idx= find(scores>0)
            %           find(scores1>=0)          
                      prob_estimates = zeros(length(testing.label_vector),2);
                      for i=1:length(testing.label_vector)
                        prob_estimates(i,1)=1.0/(1+exp(-scores(i)));
                        % for binary classification
                        prob_estimates(i,2)=1.-prob_estimates(i,1);
                      end

                    decision_values = prob_estimates;
                       predicted_label = zeros(size(scores));
                       predicted_label(predicted_label_idx)= 1 ;
                       predicted_label=predicted_label';
                       accuracy = sum(predicted_label==testing_label_vector) %/length(testing_label_vector)  
                       length(testing_label_vector)  
                       predicted_label = -ones(size(scores));
                       predicted_label(predicted_label_idx)= 1 ;

                        [~,bb] = max(prob_estimates,[],2);
                        size(bb)
                        size(testing_label_vector)
                        [Confusion,~] = confusionmat(testing_label_vector,bb);

                        num_predicted_true = sum(diag(Confusion))
                        sum(sum(Confusion))
                        Acc = num_predicted_true / sum(sum(Confusion))
                       pause;
               
                   end
                   
          end
          
   end
   
   ready=1;
   for ci= 1:conf.class.Num              
                  
      label_ci =  unique_label_vector(ci);      
      ClassName = conf.class.Names{label_ci};
      pathToDirTrain = pathToBinaryClassiferTrainsClass{label_ci};
  
      filename_model = sprintf('%s.%s%s',ClassName,solver,suffix_file_model);
      path_filename_model = fullfile(pathToDirTrain,filename_model );
      if ~exist(path_filename_model, 'file')
          ready = 0;
          break;
      end
   end
   if ready==1
        save(path_filename_classifier_ready,  'ready','-v7.3');	
   end

      
end  
  


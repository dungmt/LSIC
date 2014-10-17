function [ conf ] = TrainOneVsAll_scda( conf , start_Idx,end_Idx, step)
%TrainingTesting Thuc hien training cho tap du lieu
% Dung pp precomputed kernel
%    
   fprintf('\n -----------------------------------------------');
   fprintf('\n TrainOneVsAll: training models ...');
 
   pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ;
   path_filename_classifier_ready  = fullfile(pathToBinaryClassiferTrains,  conf.svm.filename_classifier_ready);
   if  exist (path_filename_classifier_ready,'file') && conf.isOverWriteResult==false
       fprintf(' finish (ready) !');
       return;
   end
   filename_train_selected	= conf.train.filename;
   path_filename_train_selected   = conf.train.path_filename;     
   
  % path_filename_train_selected = '/data/Dataset/LSVRC/2010/experiments/train300.val30.test150/binclassifiers/ILSVRC2010.train300.sbow.sparse.mat';
   
   filename_pre_traintrain        = conf.train.filename_pre_traintrain;
   path_filename_pre_traintrain   = conf.train.path_filename_pre_traintrain;      
   
   fprintf('\n\t path_filename_train: %s',path_filename_train_selected);
   if ~exist(path_filename_train_selected,'file')
       error('training dataset not found !');    
   else
       fprintf('\n\t Loading training dataset ...');
       training = load(path_filename_train_selected);
       fprintf('finish !');
   end
   
   unique_label_vector = unique(training.label_vector);   
   num_classes = length( unique_label_vector);
   num_samples = length(training.label_vector);
  
   fprintf('\n\t num_classes: %d',num_classes);
   fprintf('\n\t num_samples: %d',num_samples);

%   
%    
%    
%    whos
%    pause
   
   solver = conf.svm.solver;
   fprintf('\n\t conf.svm.solver: %s',conf.svm.solver);
   
   switch solver
       case 'liblinear' 
             if num_samples ~= size(training.instance_matrix,1)
                    training.instance_matrix = training.instance_matrix';
             end
             if ~issparse( training.instance_matrix)
                     fprintf('\n sparse( training.instance_matrix) ...');
                     training.instance_matrix = sparse( training.instance_matrix);
                     fprintf('finish !');
             end
%         case {'sgd', 'sdca'}
%           if ispc && isdouble(training.instance_matrix)         
%                fprintf('\n single( training.instance_matrix) ...');
%               training.instance_matrix = single(training.instance_matrix);
%               fprintf('finish !');
%           end
   end
      
  
   
   pathToBinaryClassiferTrainsClass = cell(conf.class.Num,1);
    % Tao thu muc chua dataset va model cho tung class
   for i=1:conf.class.Num
        ClassName = conf.class.Names{i};
        pathToBinaryClassiferTrainsClass{i} = fullfile(pathToBinaryClassiferTrains,ClassName);
        MakeDirectory(pathToBinaryClassiferTrainsClass{i});
   end
    
 
   suffix_file_model       = conf.svm.suffix_file_model;  
   
  filename_model_multiclass = sprintf('%s.%s.multiclass%s',conf.datasetName,solver,suffix_file_model)

  path_filename_model_multiclass = fullfile(pathToBinaryClassiferTrains,filename_model_multiclass );
  if ~exist(path_filename_model_multiclass, 'file') || conf.isOverWriteResult==true          
       
       libsvmoption='';
%        [model] = MyTrain(solver,training.label_vector, training.instance_matrix, libsvmoption);
%                 if ~issparse( training.instance_matrix)
%                      fprintf('\n sparse( training.instance_matrix) ...');
%                      training.instance_matrix = sparse( training.instance_matrix);
%                      fprintf('finish !');
%                 end
%                     model = train(training_label_vector, sparse(training_instance_matrix),libsvmoption,'col');
%                 else               
%                     model = train(training_label_vector, sparse(training_instance_matrix),libsvmoption);
%                 end
       
%     fprintf('\n Training model multi class....');        
%     model = train(training.label_vector,  training.instance_matrix);
%     fprintf('finish !');
%     
%        fprintf('\n\t\t Saving model to file ...');
%        save(path_filename_model_multiclass, 'model','-v7.3');			   
%        fprintf('finish !');
  end
   
   
   for ci= start_Idx:step:end_Idx %1:numClass      
        
                  
      label_ci =  unique_label_vector(ci);      
      ClassName = conf.class.Names{label_ci};
      pathToDirTrain = pathToBinaryClassiferTrainsClass{label_ci};
  
      filename_model = sprintf('%s.%s%s',ClassName,solver,suffix_file_model);
      path_filename_model = fullfile(pathToDirTrain,filename_model );
      if ~exist(path_filename_model, 'file') || conf.isOverWriteResult== true
          fprintf('\n Selecting data...');
          pos_training_label_vector = find(training.label_vector==label_ci);
          neg_training_label_vector = setdiff((1:num_samples), pos_training_label_vector);

          tmpp_num_neg = length(neg_training_label_vector);
          tmpp_num_pos = length(pos_training_label_vector);
          ratio =  tmpp_num_neg/tmpp_num_pos;
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
          
%                         whos
%               pause;

          
%           svm_training_label_vector       = ones(1,tmpp_num_pos);
%           labels_tmp =  -ones(1,tmpp_num_neg);
%           svm_training_label_vector       = [svm_training_label_vector,   labels_tmp   ]; 
          
       %X svm_training_instance_matrix    = training.instance_matrix(:,pos_training_label_vector);  
      %    svm_training_instance_matrix    = training.instance_matrix; %(:,1:3000);  
       %X   svm_training_instance_matrix    = [svm_training_instance_matrix, training.instance_matrix(:,neg_training_label_vector) ];    
          fprintf('finish !');
          fprintf('\n Training model %d of class %s, num_pos=%d, num_neg=%d ',ci,ClassName,tmpp_num_pos,tmpp_num_neg);
         % model = train(svm_training_label_vector, svm_training_instance_matrix,libsvmoption);

%            [model] = MyTrain(solver,svm_training_label_vector, training.instance_matrix, libsvmoption);
          lambda = 0.01;
  
          [model.w,model.b, model.info] = vl_svmtrain(training.instance_matrix , svm_training_label_vector, lambda,'Solver', solver);
         
          %[W B] = VL_SVMTRAIN(X, Y, LAMBDA) trains a linear Support Vector Machine (SVM) from the data vectors X and the labels Y. X is a D by N 
          fprintf('\n\t Saving model to file ...');
          save(path_filename_model, 'model','-v7.3');			   
          fprintf('finish !');
       
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


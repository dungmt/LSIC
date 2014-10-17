function [ conf ] = TestOnTrainOneVsAll( conf , start_Idx,end_Idx, step)
%TrainingTesting Thuc hien training cho tap du lieu
% Dung pp precomputed kernel
%     
   fprintf('\n -----------------------------------------------');
   fprintf('\n TestOnTrainOneVsAll: Testing validation OneVsAll ...');
   
   pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ;
   path_filename_test_using_onevsall_ready  = fullfile(pathToBinaryClassiferTrains,  conf.train.filename_test_using_onevsall_ready );
  if  exist (path_filename_test_using_onevsall_ready,'file') && conf.isOverWriteResult==false
      fprintf(' finish (ready) !');
      return;
  end
   filename_train_selected	= conf.train.filename;
   path_filename_train_selected   = conf.train.path_filename;     
   
  
   if ~exist(path_filename_train_selected,'file')
        error('File %s not found ',path_filename_val_selected);        
   else
       fprintf('\n\t Loading training dataset ...');
       validation = load (path_filename_train_selected);% save(path_filename_val_selected,'instance_matrix','label_vector','-v7.3');
       fprintf('finish !');
   end
  
   unique_label_vector = unique(validation.label_vector);   
   num_classes = length( unique_label_vector);
   num_samples = length(validation.label_vector);
   assert(num_samples== size(validation.instance_matrix,2));
   
   fprintf('\n\t num_classes: %d',num_classes);
   fprintf('\n\t num_samples: %d',num_samples);
   
   pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ; 
   pathToBinaryClassiferTrainsClass = cell(conf.class.Num,1);
    % Tao thu muc chua dataset va model cho tung class
   for i=1:conf.class.Num
        ClassName = conf.class.Names{i};
        pathToBinaryClassiferTrainsClass{i} = fullfile(pathToBinaryClassiferTrains,ClassName);
   end
   
   solver = conf.svm.solver;
   fprintf('\n\t conf.svm.solver: %s',conf.svm.solver);
   suffix_file_model       = conf.svm.suffix_file_model;  
   
   
    filename_model_multiclass = sprintf('%s.%s.multiclass%s',conf.datasetName,solver,suffix_file_model);
    
    path_filename_model_multiclass = fullfile(pathToBinaryClassiferTrains,filename_model_multiclass );
    if exist(path_filename_model_multiclass, 'file')          
        filename_libsvm_val_multiclass        = [conf.datasetName, '.multiclass',conf.val.midle_file_test,conf.val.str_val,'.mat'] ;
        path_filename_libsvm_val_multiclass 	= fullfile(conf.experiment.pathToBinaryClassiferTrains, filename_libsvm_val_multiclass);
      
        if ~exist(path_filename_libsvm_val_multiclass, 'file') || conf.isOverWriteResult==true
            fprintf('\n Loading model file for multi class....');
            load (path_filename_model_multiclass);
            fprintf('\n Predicting multi class....');
            [predicted_label, accuracy, decision_values] = MyPredict(conf.svm.solver,validation.label_vector, validation.instance_matrix, model);
            val_label_vector = validation.label_vector;
            fprintf('\n\t\t Saving result %s...', filename_libsvm_val_multiclass);
            save(path_filename_libsvm_val_multiclass, 'predicted_label', 'accuracy', 'decision_values','val_label_vector','-v7.3');
            fprintf('finish !'); 
        end
   
    end
   
   
   for ci= start_Idx:step:end_Idx %1:numClass      
        
                  
      label_ci =  unique_label_vector(ci);      
      ClassName = conf.class.Names{label_ci};
      pathToDirTrain = pathToBinaryClassiferTrainsClass{label_ci};
  
      filename_libsvm_val      =     [ ClassName ,conf.val.midle_file_test,conf.train.str_train,'.mat'] ;
      path_filename_libsvm_val = fullfile(pathToDirTrain,filename_libsvm_val);
      fprintf('\n\t Predicting on validation dataset %d... ',ci);
      if exist( path_filename_libsvm_val, 'file') && conf.isOverWriteResult==false           
             fprintf('finish (ready) !'); 
      else           
          filename_model = sprintf('%s.%s%s',ClassName,solver,suffix_file_model);
          path_filename_model = fullfile(pathToDirTrain,filename_model );
          fprintf('\n\t Loading model %d to file ...',ci);
          load(path_filename_model); %, 'model','-v7.3');			   
          fprintf('finish !');

          testing_label_vector = zeros(length(validation.label_vector),1);
          testing_label_vector(find(validation.label_vector==label_ci))=1;
          
          [predicted_label, accuracy, decision_values] = MyPredict(conf.svm.solver,testing_label_vector, validation.instance_matrix, model);

          val_label_vector = validation.label_vector;
          fprintf('\n\t Saving result: %s...', filename_libsvm_val);
          save(path_filename_libsvm_val, 'predicted_label', 'accuracy', 'decision_values','val_label_vector','-v7.3');
          fprintf('finish !');   
      end 
      
   end  
   ready=1;
   for ci= 1:conf.class.Num          
      ClassName = conf.class.Names{ci};
      pathToDirTrain = pathToBinaryClassiferTrainsClass{ci};
  
      filename_libsvm_val      =     [ ClassName ,conf.val.midle_file_test,conf.val.str_val,'.mat'] ;
      path_filename_libsvm_val = fullfile(pathToDirTrain,filename_libsvm_val);
      if ~exist (path_filename_libsvm_val, 'file')
          ready = 0;
          break;
      end
   end
   if ready==1
       save(path_filename_test_using_onevsall_ready,  'ready','-v7.3');	
   end
   

  
end


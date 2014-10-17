function [ conf ] = TestOneVsAll( conf , start_Idx,end_Idx, step)
%TrainingTesting Thuc hien training cho tap du lieu
% Dung pp precomputed kernel
% 
   fprintf('\n -----------------------------------------------');
   fprintf('\n TestOneVsAll: Testing  One-Vs-All ...');
  
   pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ;
   path_filename_test_using_onevsall_ready  = conf.test.path_filename_test_using_onevsall_ready;
   if  exist (path_filename_test_using_onevsall_ready,'file') && conf.isOverWriteResult==false
       fprintf(' finish (ready) !');
       return;
   end
   
   if strcmp(conf.datasetName,'ILSVRC2010')
        [ conf ] = TestOneVsAll_IL( conf , start_Idx,end_Idx);
        return;
   end

   path_filename_test_selected   = conf.test.path_filename;      
   if ~exist(path_filename_test_selected,'file')
        error('File %s not found ',path_filename_test_selected);        
   else
       fprintf('\n\t Loading testing dataset ...');
       testing = load (path_filename_test_selected);% save(path_filename_test_selected,'instance_matrix','label_vector','-v7.3');
       fprintf('finish !');
   end
  
   
   unique_label_vector = unique(testing.label_vector);   
   num_classes = length( unique_label_vector);
   num_samples = length(testing.label_vector);
   assert(num_samples== size(testing.instance_matrix,2));
   
   fprintf('\n\t num_classes: %d',num_classes);
   fprintf('\n\t num_samples: %d',num_samples);
   
   fprintf('\n\t conf.eigenclass.Rtest');
   
%    conf.eigenclass.Rtest = (testing.instance_matrix'* conf.eigenclass.UW)*conf.eigenclass.SW*conf.eigenclass.VW';

%    Rtest = (testing.instance_matrix'* conf.eigenclass.W);
%    arr_Step =conf.pseudoclas.arr_Step;
%    arr_Acc=0;
%    arr_AccR=0;
%    num_Arr_Step = length(arr_Step);
%     for i=1: num_Arr_Step %:-1:1
%         k = arr_Step(i);        
%         str_k = num2str(k,'%.3d');  
%         fprintf('\n\t -----------------------------------------------');
%         fprintf('\n\t LSIC: Composing i=%d/%d with kkk = %3d ...',i,num_Arr_Step, k);  
% 
%     
%             UU  =  conf.eigenclass.UW(:,1:k);
%             SS  = conf.eigenclass.SW(1:k,1:k);
%             VV = conf.eigenclass.VW(:,1:k);
%             VV_T = VV';
%             
%             fprintf('\n\t Composing final score matrix xxx ..');        
%             scores_matrix  = (testing.instance_matrix'* UU)*SS*VV_T; 
%             fprintf(' finish !');
%             
%             [VL_APE, M_VL_APE, error_flatE, AccE] =  Evaluate(scores_matrix , testing.label_vector );
%             arr_Acc(i)=AccE;
%             [UR,SR,VR] = svds(Rtest,k);
%             Rtest_new = UR*SR*VR';
%             [VL_APE, M_VL_APE, error_flatE, AccR] =  Evaluate(Rtest_new , testing.label_vector );
%             arr_AccR(i) = AccR;
%             
%     end
%     fprintf('\n\t Test:');
%     arr_Acc
%     fprintf('\n');
%     arr_AccR
%     return;
   
   
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
        filename_libsvm_test_multiclass        = [conf.datasetName, '.multiclass',conf.test.midle_file_test,conf.test.str_test,'.mat'] ;
        path_filename_libsvm_test_multiclass 	= fullfile(conf.experiment.pathToBinaryClassiferTrains, filename_libsvm_test_multiclass);
      
        if ~exist(path_filename_libsvm_test_multiclass, 'file')  || conf.isOverWriteResult==true
            fprintf('\n Loading model file for multi class....');
            load (path_filename_model_multiclass);
            fprintf('\n Predicting multi class....');
            [predicted_label, accuracy, decision_values] = MyPredict(conf.svm.solver,testing.label_vector, testing.instance_matrix, model);
            test_label_vector = testing.label_vector;
            fprintf('\n\t\t Saving result %s...', filename_libsvm_test_multiclass);
            save(path_filename_libsvm_test_multiclass, 'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');
            fprintf('finish !'); 
        end
   
    end
   
   
   for ci= start_Idx:step:end_Idx %1:numClass      
        
                 
      %%% label_ci =  unique_label_vector(ci);      
      label_ci = ci;
      ClassName = conf.class.Names{label_ci};
      pathToDirTrain = pathToBinaryClassiferTrainsClass{label_ci};
  
      filename_libsvm_test        = [ClassName, conf.test.midle_file_test,conf.test.str_test,'.mat'] ;
      path_filename_libsvm_test 	= fullfile(pathToDirTrain, filename_libsvm_test);
      fprintf('\n\t\t Predicting on testing dataset... ');
      if ~exist (path_filename_libsvm_test, 'file')  || conf.isOverWriteResult==true
          filename_model = sprintf('%s.%s%s',ClassName,solver,suffix_file_model);
          path_filename_model = fullfile(pathToDirTrain,filename_model );
          fprintf('\n\t\t Loading model to file ...');
          load(path_filename_model); %, 'model','-v7.3');			   
          fprintf('finish !');

          testing_label_vector = zeros(length(testing.label_vector),1);
          testing_label_vector(find(testing.label_vector==label_ci))=1;
          
          [predicted_label, accuracy, decision_values] = MyPredict(conf.svm.solver,testing_label_vector, testing.instance_matrix, model);

          test_label_vector = testing.label_vector;
          fprintf('\n\t\t Saving result: %s...', filename_libsvm_test);
          save(path_filename_libsvm_test, 'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');
          fprintf('finish !');   
      end 
      
   end  

   
   ready=1;
   for ci= 1:conf.class.Num     
     
      ClassName = conf.class.Names{ci};
      pathToDirTrain = pathToBinaryClassiferTrainsClass{ci};
  
      filename_libsvm_test        = [ClassName, conf.test.midle_file_test,conf.test.str_test,'.mat'] ;
      path_filename_libsvm_test 	= fullfile(pathToDirTrain, filename_libsvm_test);
       
      if ~exist (path_filename_libsvm_test, 'file')
          ready = 0;
          break;
      end
   end
   if ready==1
       save(path_filename_test_using_onevsall_ready,  'ready','-v7.3');	
   end
  
end


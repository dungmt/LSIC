function [ conf ] = TestOneVsAll_IL(conf,ci_start,ci_end)
    fprintf('\n+----------------------------------------------------+');
    fprintf('\n| + TestOneVsAll_IL.m                               |');
    fprintf('\n+----------------------------------------------------+');
    
   pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ;
   path_filename_test_using_onevsall_ready  = conf.test.path_filename_test_using_onevsall_ready; 
   if  exist (path_filename_test_using_onevsall_ready,'file') && conf.isOverWriteResult==false
       fprintf(' finish (ready) !');
       return;
   end  
   
    pathToIMDBDirTest =  fullfile(conf.path.pathToFeaturesDir, 'test');
    
    pathToBinaryClassiferTrainsClass = cell(conf.class.Num,1);
    % Tao thu muc chua dataset va model cho tung class
   for i=1:conf.class.Num
        ClassName = conf.class.Names{i};
        pathToBinaryClassiferTrainsClass{i} = fullfile(pathToBinaryClassiferTrains,ClassName);
   end
   
   solver = conf.svm.solver;
   fprintf('\n\t conf.svm.solver: %s',conf.svm.solver);
   suffix_file_model       = conf.svm.suffix_file_model;  
               
    num_FileTest = 150;
    mySize = 1000;        
            
    gtruth_test_file= fullfile(conf.dir.rootDir,'data/ILSVRC2010_test_ground_truth.txt');   
    label_vector = dlmread(gtruth_test_file);
         
    fprintf('\n Cap phat bo nho');
    testing_instance_matrix = zeros(mySize*num_FileTest,50000);
        
    start =1;                       
     for j=1:num_FileTest  
 %    for j=ci_start:ci_end
         % Load file test
        str_id = num2str(j,'%.4d');
        filename_test = ['test.',str_id,'.sbow.mat'] ;
        path_filename_test = fullfile(pathToIMDBDirTest, filename_test);
        if ~exist(path_filename_test,'file')  % kiem tra xem co file test                    
             error('Missing test file %s !',path_filename_test);    
        end

        fprintf('\n\t Loading data from file %s ...',filename_test);
        load(path_filename_test) % save(filename,'setOfFeatures','index','-v7.3');
%                   Name                   Size                  Bytes  Class     Attributes
% 
%                   index                  1x1000                 8000  double              
%                   setOfFeatures      50000x1000            200000000  single   

        testing_instance_matrix(start: start+mySize-1,:) =  setOfFeatures';
         
        instance_matrix = sparse(double(setOfFeatures'));
        test_label_vector = label_vector((j-1)*mySize+1: j*mySize,1);

       %for ci=ci_start:ci_end
       for ci=1:0
            label_ci  = ci;
            ClassName = conf.class.Names{label_ci};
            pathToDirTrain = pathToBinaryClassiferTrainsClass{label_ci};
      
            
            filename_model = sprintf('%s.%s%s',ClassName,solver,suffix_file_model);
            path_filename_model = fullfile(pathToDirTrain,filename_model );
            fprintf('\n\t\t Loading model to file ...');
            load(path_filename_model); %, 'model','-v7.3');			   
            fprintf('finish !');

             filename_libsvm_test        = [ClassName, conf.svm.mid_file_test, sprintf('.test.%s.mat',str_id)] ;
             path_filename_libsvm_test 	= fullfile(pathToDirTrain, filename_libsvm_test);
             if exist (path_filename_libsvm_test, 'file') % Kiem tra xem co ket qua test chua
                   fprintf(' finish (ready) !');
                   continue;
             end
                
            fprintf('\n\t Testing pseudo class: %d  and test file: test.%s ..\n',ci,str_id);                               
                
            [predicted_label, accuracy, decision_values] = MyPredict(solver,test_label_vector, instance_matrix, model);
            fprintf('\n\t\t Saving result: %s...', filename_libsvm_test);
            save(path_filename_libsvm_test, 'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');
            fprintf('finish !');                           

        end
        start = start +  mySize;
     end
     
     
    
    %%------------------------------------------------------
   ready=1;
   for ci= 1:conf.class.Num     
     
      ClassName = conf.class.Names{ci};
      pathToDirTrain = pathToBinaryClassiferTrainsClass{ci};
  
      filename_libsvm_test        = [ClassName, conf.svm.mid_file_test, sprintf('.test.%s.mat',str_id)] ;
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
    
   
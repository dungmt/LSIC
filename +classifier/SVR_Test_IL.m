function SVR_Test_IL(conf,ci_start,ci_end)
    
    arr_Step        = conf.pseudoclas.arr_Step;
    num_Arr_Step = length(arr_Step);
    assert(num_Arr_Step>0);
    num_pseudo_classes  = arr_Step(num_Arr_Step);
    assert(num_pseudo_classes>0);
   
    pathToRegressionTrains = conf.experiment.pathToRegressionTrains;
    pathToRegressionTrainsTest = conf.experiment.pathToRegressionTrainsTest;
    pathToIMDBDirTest =  fullfile(conf.path.pathToFeaturesDir, 'test');
   
    prefix_file_model = conf.svr.prefix_file_model;
    suffix_file_model = conf.svr.suffix_file_model;
    path_filename_score_matrix = conf.svr.path_filename_score_matrix;
    
    fprintf('\n+----------------------------------------------------+');
    fprintf('\n| +classifier.SVR_Test_IL                               |');
    fprintf('\n+----------------------------------------------------+');
    fprintf('\n\t num_pseudo_classes: %d',num_pseudo_classes);    
    fprintf('\n\t pathToRegressionTrains:\n\t\t %s',pathToRegressionTrains);
    fprintf('\n\t pathToRegressionTrainsTest:\n\t\t %s',pathToRegressionTrainsTest);
    fprintf('\n\t path_filename_score_matrix:\n\t\t %s',path_filename_score_matrix);
    fprintf('\n+----------------------------------------------------+');  
             
        
    
    fprintf('\n\t Predicting SVR...');
    if exist(path_filename_score_matrix, 'file') && conf.isOverWriteSVRTest==false         
        
         fprintf(' finish (ready) !');
         return;
    end
    
               
        num_FileTest = 150;
        mySize = 1000;        
        %% Bat dau xu ly tung label 
        inv_ScoreMatrix = zeros(num_pseudo_classes,num_FileTest*mySize, 'double');   
        
        gtruth_test_file= fullfile(conf.dir.rootDir,'data/ILSVRC2010_test_ground_truth.txt');   
        label_vector = dlmread(gtruth_test_file);
         
        prefix_file_model = conf.svr.prefix_file_model;
        suffix_file_model = conf.svr.suffix_file_model;
        
        ci_endd = min(ci_end,num_pseudo_classes);
        % Load tat cac modedel 
   
%     fprintf('\n Loading score matrix to file: %s ...', path_filename_score_matrix);
%     load(path_filename_score_matrix); 
%     fprintf('finish !');  
   
        for ci=ci_start:ci_endd
            str_num_ci = num2str(ci,'%.3d');          
            filename_model{ci} = [prefix_file_model, str_num_ci, suffix_file_model];
            path_filename_model_ci = fullfile(pathToRegressionTrains,filename_model{ci});

            if ~exist( path_filename_model_ci, 'file')
                 error('\n\t Model file %s is not found !',path_filename_model_ci);
            end        

            fprintf('\n\t\t Loading model from file %s ...',path_filename_model_ci);
            load (path_filename_model_ci); %,'model','-v7.3');
            allmodel{ci} = model;
            allmaxVec(ci) = maxVec;
            allminVec(ci) = minVec;
            
%             fprintf('\n\t\t  apply the calculations in reverse maxVec=%f-minVec=%f',maxVec,minVec);
            
%              vecN = inv_ScoreMatrix(ci,:);
%              %# to "de-normalize", apply the calculations in reverse
%              vecD = (vecN./2+0.5) * (maxVec-minVec) + minVec;
%              inv_ScoreMatrix(ci,:) = vecD ;                
          end
        
%     fprintf('\n Loading score matrix to file: %s ...', path_filename_score_matrix);
%     save(path_filename_score_matrix, 'inv_ScoreMatrix', 'label_vector','-v7.3');
%     fprintf('finish !');  
%     return ;
%    
        %% --------------------------------------------------------------
        
        start =1;                       
        tic        
        for j=1:num_FileTest  
            % Load file test
            str_id = num2str(j,'%.4d');
            filename_test = ['test.',str_id,'.sbow.mat'] ;
            path_filename_test = fullfile(pathToIMDBDirTest, filename_test);
            if ~exist(path_filename_test,'file')  % kiem tra xem co file test                    
                 error('Missing test file %s !',path_filename_test);    
            end
                
            fprintf('\n\t\t Loading data from file %s ...',filename_test);
            load(path_filename_test); % save(filename,'setOfFeatures','index','-v7.3');
%                   Name                   Size                  Bytes  Class     Attributes
% 
%                   index                  1x1000                 8000  double              
%                   setOfFeatures      50000x1000            200000000  single   
           
             
            instance_matrix = sparse(double(setOfFeatures'));
    
            
            
            
            
            
            
            
            
            
            test_label_vector = label_vector((j-1)*mySize+1: j*mySize,1);

            for ci=ci_start:ci_endd
            %for ci=1:0

                str_num_ci = num2str(ci,'%.3d');  
                filename_model_ci = filename_model{ci};
%                 filename_model_ci = [prefix_file_model, str_num_ci, suffix_file_model];
%                 path_filename_model_ci = fullfile(pathToRegressionTrains,filename_model_ci);
% 
%                 if ~exist( path_filename_model_ci, 'file')
%                     error('\n\t Model file %s is not found !',path_filename_model_ci);
%                 end        
% 
%                 fprintf('\n\t\t Loading model from file %s ...',path_filename_model_ci);
%                 load (path_filename_model_ci); %,'model','-v7.3');

                filename_kq = [filename_model_ci, '.test.', str_id, '.mat'];
                path_filename_kq =fullfile(pathToRegressionTrainsTest,filename_kq);

                
                if ~exist(path_filename_kq, 'file') || conf.isOverWriteSVRTest==true
%                     tic
                    fprintf('\n\t Testing pseudo class: %d  and test file: test.%s ..\n',ci,str_id);                                
                   % [predicted_label, accuracy, decision_values]= predict(test_label_vector, instance_matrix, model);    
                    [predicted_label, accuracy, decision_values]= predict(test_label_vector, instance_matrix, allmodel{ci});    
                    
                    
                    maxVec = allmaxVec(ci);
                    minVec = allminVec(ci);
                    fprintf('\n\t\t  apply the calculations in reverse maxVec=%f-minVec=%f',maxVec,minVec);
                    vecN = decision_values;
                    %# to "de-normalize", apply the calculations in reverse
                    vecD = (vecN./2+0.5) * (maxVec-minVec) + minVec;
                    
                    decision_values = vecD;     
             
                    save(path_filename_kq,'predicted_label', 'accuracy', 'decision_values','-v7.3');
%                     toc
                else
                    fprintf('\n\t Loading result of prediction class %d ...', ci)
                    load(path_filename_kq);
                
                 end
                inv_ScoreMatrix(ci, start: start+mySize-1) = decision_values';
                
            end
            start = start +  mySize;
        end

         fprintf('Thoi gian test'); 
         toc
         
        fprintf('\n Saving score matrix to file: %s ...', path_filename_score_matrix);
        save(path_filename_score_matrix, 'inv_ScoreMatrix', 'label_vector','-v7.3');
        fprintf('finish !');  
        
        
         
       
end
    
   
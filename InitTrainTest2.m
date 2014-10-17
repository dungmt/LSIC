function [ conf ] = InitTrainTest2( conf )
%InitTrainTest Thiet lap cac tham so training va testing
%   Detailed explanation goes here

    %% -------------------------------------------------------------------
    %                                               Setup SVM model
    % --------------------------------------------------------------------
    

%   conf.svm.model.classes = classes ;
    conf.svm.model.w = [] ;
    conf.svm.model.b = [] ;
    conf.svm.biasMultiplier = 1 ;
    % conf.svm.model.classify = @classify ;
    %---------------------------------------------------------------------
    % Xac dinh so luong anh pos/neg de train classifier
    %---------------------------------------------------------------------
    conf.svm.num_img_pos_per_class          = conf.IMDB.num_images_train;
    
    if strcmp( conf.datasetName,'ILSVRC2010')                 
        conf.svm.num_img_neg_per_class_selected = 10;        
    elseif strcmp(conf.datasetName ,'Caltech256')        
        conf.svm.num_img_neg_per_class_selected = 5;        
    end
    
    conf.svm.num_img_neg_per_class  = conf.svm.num_img_neg_per_class_selected*(conf.class.Num-1) ;
    conf.svm.ratio_neg_pos          = conf.svm.num_img_neg_per_class/conf.svm.num_img_pos_per_class;
    
    %---------------------------------------------------------------------
    % Xac dinh tham so svm
    %---------------------------------------------------------------------
    
%     conf.svm.solver = 'libsvm'; % 'vl_svmtrain {'sgd', 'sdca'}',  'liblinear', 'libsvm'
%    conf.svm.preCompKernel = true;
    conf.svm.preCompKernelType = 'linear';
    conf.svm.select_nagative_random = false;
   
    switch conf.svm.solver
        case 'libsvm'
            conf.svm.C = 1;            
            conf.svm.biasMultiplier = 1 ;
            if (conf.svm.preCompKernel)
                conf.svm.libsvmoption = sprintf('-t 4 -w1 %f -w-1 1 -b 1', conf.svm.ratio_neg_pos);
            else
                conf.svm.libsvmoption = sprintf('-t 0 -w1 %f -w-1 1 -b 1', conf.svm.ratio_neg_pos);
            end           
  
       % case 'pegasos'
        case {'sgd', 'sdca'}
            conf.svm.C = 10 ;
            conf.svm.biasMultiplier = 1 ;
            conf.svm.libsvmoption='';
        case 'liblinear'
            conf.svm.C = 10 ;
            conf.svm.biasMultiplier = 1 ;       
            conf.svm.libsvmoption= sprintf(' -w1 %f -w-1 1', conf.svm.ratio_neg_pos);
    end
    fprintf('\n conf.svm.libsvmoption =%s',conf.svm.libsvmoption);
            
    %---------------------------------------------------------------------
    % Xac dinh cac chuoi suffix
    %---------------------------------------------------------------------
    
    str_kernel = ['.', conf.svm.preCompKernelType];
    
    if conf.svm.preCompKernel
         str_pre = ['.pre', str_kernel];
    else
         str_pre = '';
    end
   
    conf.svm.str_pre = str_pre;
    
    if conf.svm.select_nagative_random
         str_bla = '.rand';
         
    else
         str_bla = sprintf('.bla%d',conf.svm.num_img_neg_per_class_selected); 
        
    end
    str_suffix_bla = [str_bla, '.mat'];

    
    str_train = sprintf('.train%d', conf.IMDB.num_images_train);   
    str_val =  sprintf('.val%d',    conf.IMDB.num_images_val);
    str_test = sprintf('.test%d',   conf.IMDB.num_images_test);
    
    conf.val.str_val = str_val;
    conf.test.str_test = str_test;
    
    conf.svm.suffix_file_model  = [str_pre,'.prob','.mat'];    
    conf.svm.suffix_file_train  = '.trainingset.mat';
    
    conf.svm.filename_neg_set   = 'neg_set.mat';
    
    conf.svm.mid_file_test  =  ['.',conf.svm.solver, str_pre,'.prob'];
   
    
    %---------------------------------------------------------------------
    % Xac dinh tham so validation
    %---------------------------------------------------------------------
    
   
    conf.val.filename	= [conf.datasetName,str_val,'.sbow.mat'];
    conf.val.filename_pre_valval	= [conf.datasetName,str_pre,str_val,str_val,'.mat'];
    
    conf.val.filename_evaluation    = [conf.datasetName, '.',conf.svm.solver,str_pre,'.prob', str_val,'.eval.mat'];    
    conf.val.filename_score_matrix	= [conf.datasetName, '.',conf.svm.solver,str_pre,'.prob', str_val,'.scores.mat'];
    conf.val.FileNameScoreMatrix	= [conf.datasetName, '.',conf.svm.solver,str_pre,'.prob', str_val,str_suffix_bla];
    conf.val.midle_file_test       =                   ['.',conf.svm.solver,str_pre,'.prob'];
    

    
    conf.test.filename =  [conf.datasetName,str_test,'.sbow.mat'];
    
    conf.test.filename_evaluation    = [conf.datasetName, '.',conf.svm.solver,str_pre,'.prob', str_test,'.eval.final.mat'];    
    conf.test.filename_score_matrix  = [conf.datasetName, '.',conf.svm.solver,str_pre,'.prob', str_test,'.scores.mat'];
    conf.test.midle_file_test       =                   ['.',conf.svm.solver,str_pre,'.prob'];
    
    conf.experiment.filename_combine_evaluation    = [conf.datasetName, '.',conf.svm.solver,str_pre,'.prob', '.eval.mat']; 
   
    conf.svm.filename_classifier_ready    = [conf.datasetName, '.',conf.svm.solver,str_pre,'.prob','.classifier.ready.mat']; 
    conf.svm.prefix_ready_testtrain    = [conf.datasetName, str_pre];
    conf.svm.prefix_ready_valtrain     = [conf.datasetName, str_pre];
    
    conf.svm.suffix_ready_testtrain     = '.train.ready.mat'; 
    conf.svm.suffix_ready_valtrain      = '.train.ready.mat'; 
    
    conf.svm.suffix_file_testtrain      = '.train.mat';     
    conf.svm.suffix_file_valtrain       = '.train.mat';
    
  
   
    num_images_train = conf.IMDB.num_images_train; 
    num_images_test  = conf.IMDB.num_images_test;
    num_images_val   = conf.IMDB.num_images_val;
      
    imdb_str_train_val_test = sprintf('train%d.val%d.test%d',  num_images_train,num_images_val,num_images_test);
 
    conf.path.pathToExperimentDir  = fullfile(conf.dir.experimentDir,imdb_str_train_val_test);
    
    conf.experiment.pathToRegression       = fullfile(conf.path.pathToExperimentDir,conf.experiment.dirRegression);
    conf.experiment.pathToBinaryClassifer  = fullfile(conf.path.pathToExperimentDir,conf.experiment.dirBinaryClassifer);

    MakeDirectory(conf.experiment.pathToRegression);
    MakeDirectory(conf.experiment.pathToBinaryClassifer);

    
    
    trainDir = [sprintf('train%d',conf.IMDB.num_images_train), str_bla];
    testDir =  sprintf('test%d',conf.IMDB.num_images_test);

    conf.experiment.pathToBinaryClassiferTrains  = fullfile(conf.experiment.pathToBinaryClassifer, trainDir);
    conf.experiment.pathToRegressionTrains  = fullfile(conf.experiment.pathToRegression, trainDir);
    conf.experiment.pathToRegressionTrainsTest    = fullfile(conf.experiment.pathToRegressionTrains, testDir);
    
    MakeDirectory(conf.experiment.pathToBinaryClassiferTrains);
    MakeDirectory(conf.experiment.pathToRegressionTrains);
    MakeDirectory(conf.experiment.pathToRegressionTrainsTest);
    
    
    conf.val.path_filename_pre_valval   = fullfile(conf.experiment.pathToBinaryClassifer,    conf.val.filename_pre_valval);
    conf.val.path_filename   = fullfile(conf.experiment.pathToBinaryClassifer,    conf.val.filename);
    conf.test.path_filename  = fullfile(conf.experiment.pathToBinaryClassifer,    conf.test.filename);
    conf.testval.filename  = [conf.datasetName,str_test,str_val,'.mat'];
    conf.testval.path_filename  = fullfile(conf.experiment.pathToBinaryClassifer, conf.testval.filename);
    conf.testval.path_filename_ready  = fullfile(conf.experiment.pathToBinaryClassifer, [conf.datasetName,str_test,str_val,'.ready.mat']);
   
    
    
  
end


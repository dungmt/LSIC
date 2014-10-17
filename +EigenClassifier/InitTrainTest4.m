function [ conf ] = InitTrainTest4( conf )
%InitTrainTest Thiet lap cac tham so training va testing
%   Detailed explanation goes here
    fprintf('\n -----------------------------------------------');
    fprintf('\n InitTrainTest4 ...');

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
    
    if strcmp( conf.datasetName,'ILSVRC65')                 
        conf.svm.num_img_neg_per_class_selected = 0;        
    elseif strcmp( conf.datasetName,'ILSVRC2010')                 
        conf.svm.num_img_neg_per_class_selected = 0;        
    elseif strcmp(conf.datasetName ,'Caltech256')        
        conf.svm.num_img_neg_per_class_selected = 0;        
    elseif strcmp(conf.datasetName ,'SUN397') 
        conf.svm.num_img_neg_per_class_selected = 0;   
     elseif strcmp(conf.datasetName ,'ImageCLEF2012') 
        conf.svm.num_img_neg_per_class_selected = 0;   
    end
       
   
   
    conf.svm.num_img_neg_per_class  = conf.svm.num_img_neg_per_class_selected*(conf.class.Num-1) ;
    conf.svm.ratio_neg_pos          = conf.svm.num_img_neg_per_class/conf.svm.num_img_pos_per_class;
    fprintf('\n\t conf.svm.num_img_neg_per_class: %d', conf.svm.num_img_neg_per_class);
    fprintf('\n\t conf.svm.ratio_neg_pos: %f', conf.svm.ratio_neg_pos);
    
    %---------------------------------------------------------------------
    % Xac dinh tham so svm
    %---------------------------------------------------------------------
    
    conf.svm.preCompKernelType = 'linear';
    conf.svm.select_nagative_random = false;
    
    fprintf('\n\t conf.svm.solver: %s', conf.svm.solver);
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
    fprintf('\n\t conf.svm.libsvmoption =%s',conf.svm.libsvmoption);
            
    %---------------------------------------------------------------------
    % Xac dinh cac chuoi suffix
    %---------------------------------------------------------------------
    
    str_prop = '.prob';
    
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
        if conf.svm.num_img_neg_per_class_selected==0
            str_bla = '.blaall'; 
        elseif conf.svm.num_img_neg_per_class_selected > 0
            str_bla = sprintf('.bla%d',conf.svm.num_img_neg_per_class_selected); 
        else
            error('InitTrainTest4:conf.svm.num_img_neg_per_class_selected')
        end
         
        
    end
    str_suffix_bla = [str_bla, '.mat'];
    
    num_images_train = conf.IMDB.num_images_train; 
    num_images_test  = conf.IMDB.num_images_test;
    num_images_val   = conf.IMDB.num_images_val;
    
    if num_images_train >0.0 && num_images_train < 1.0
        num_images_train_percent    = uint32(num_images_train*100);
        num_images_val_percent      = uint32(num_images_val*100);
        num_images_test_percent     = uint32(num_images_test*100);
        
        str_train = sprintf('.train%dp', num_images_train_percent);   
        str_val =  sprintf('.val%dp',    num_images_val_percent);
        str_test = sprintf('.test%dp',   num_images_test_percent);
        
        imdb_str_train_val_test = sprintf('train%dp.val%dp.test%dp',  num_images_train_percent,num_images_val_percent,num_images_test_percent);
        trainDir = [sprintf('train%dp',num_images_train_percent), str_bla];
        testDir =  sprintf('test%dp',num_images_test_percent);
        
    else
    

        str_train = sprintf('.train%d', num_images_train);   
        str_val =  sprintf('.val%d',    num_images_val);
        str_test = sprintf('.test%d',   num_images_test);
        
        
        imdb_str_train_val_test = sprintf('train%d.val%d.test%d',  num_images_train,num_images_val,num_images_test);
        trainDir = [sprintf('train%d',num_images_train), str_bla];
        testDir =  sprintf('test%d', num_images_test);
        
    end
    conf.train.trainDir = trainDir;
    conf.test.testDir = testDir;
    %---------------------------------------------------------------------
    % T?o thu muc thuc nghiem
    %---------------------------------------------------------------------
    
    conf.path.pathToExperimentDir  = fullfile(conf.dir.experimentDir,imdb_str_train_val_test);    
    fprintf('\n\t conf.path.pathToExperimentDir =%s',conf.path.pathToExperimentDir);
    
    % One-Vs-All Binary classifier
     
    conf.experiment.dirBinaryClassifer   = 'binclassifiers';
    if strcmp( conf.datasetName,'ILSVRC2010')   
        conf.experiment.pathToBinaryClassifer  = fullfile(conf.dir.experimentDir,conf.experiment.dirBinaryClassifer);
    else
        conf.experiment.pathToBinaryClassifer  = fullfile(conf.path.pathToExperimentDir,conf.experiment.dirBinaryClassifer);
    end
    utility.MakeDirectory(conf.experiment.pathToBinaryClassifer);       
    
    conf.experiment.pathToBinaryClassiferTrains     = fullfile(conf.experiment.pathToBinaryClassifer, trainDir);
    utility.MakeDirectory(conf.experiment.pathToBinaryClassiferTrains);
    
    conf.val.str_val        = str_val;
    conf.test.str_test      = str_test;
    conf.train.str_train    = str_train;
    

   
    
    %---------------------------------------------------------------------
    % Xac dinh tham so training
    %---------------------------------------------------------------------
   
    conf.train.filename	= [conf.datasetName,str_train,'.sbow.mat'];
    conf.train.filename_sparse =  [conf.datasetName,str_train,'.sparse.sbow.mat']; 
    if strcmp( conf.datasetName,'ILSVRC2010')   
        conf.train.path_filename_sparse  = fullfile(conf.path.pathToIMDBDirTrain,    conf.train.filename_sparse);
        conf.train.path_filename         = fullfile(conf.path.pathToIMDBDirTrain,    conf.train.filename);
    else
    
        conf.train.path_filename_sparse                    = fullfile(conf.experiment.pathToBinaryClassifer,    conf.train.filename_sparse);
        conf.train.path_filename                    = fullfile(conf.experiment.pathToBinaryClassifer,    conf.train.filename);
    end
    conf.train.filename_pre_traintrain	= [conf.datasetName,str_pre,str_train,str_train,'.mat'];
    conf.train.path_filename_pre_traintrain     = fullfile(conf.experiment.pathToBinaryClassifer,    conf.train.filename_pre_traintrain);
    
    conf.train.filename_evaluation      = [conf.datasetName, '.',conf.svm.solver,str_pre,str_prop, str_train,'.eval.mat'];    
    conf.train.filename_score_matrix	= [conf.datasetName, '.',conf.svm.solver,str_pre,str_prop, str_train,'.scores.mat'];
    conf.train.midle_file_test          = ['.',conf.svm.solver,str_pre,str_prop];
    conf.train.filename_test_using_onevsall_ready    = [conf.datasetName, '.',conf.svm.solver,str_pre,str_prop, str_train,'.ready.mat'];   
  
    
    
    %---------------------------------------------------------------------
    % Xac dinh tham so validation
    %---------------------------------------------------------------------
    conf.val.filename	= [conf.datasetName,str_val,'.sbow.mat'];
    conf.val.filename_pre_valval	= [conf.datasetName,str_pre,str_val,str_val,'.mat'];
    
    if strcmp( conf.datasetName,'ILSVRC2010')   
        conf.val.path_filename              = fullfile(conf.path.pathToIMDBDirVal,    conf.val.filename);
        conf.val.path_filename_pre_valval   = fullfile(conf.path.pathToIMDBDirVal,    conf.val.filename_pre_valval);
    else
        conf.val.path_filename              = fullfile(conf.experiment.pathToBinaryClassifer,    conf.val.filename);
        conf.val.path_filename_pre_valval   = fullfile(conf.experiment.pathToBinaryClassifer,    conf.val.filename_pre_valval);
    end
    
    conf.val.filename_evaluation    = [conf.datasetName, '.',conf.svm.solver,str_pre,str_prop, str_val,'.eval.mat'];    
    conf.val.path_filename_evaluation    = fullfile(conf.experiment.pathToBinaryClassiferTrains, conf.val.filename_evaluation);
    
    conf.val.filename_score_matrix	= [conf.datasetName, '.',conf.svm.solver,str_pre,str_prop, str_val,'.scores.mat'];
    conf.val.path_filename_score_matrix                 = fullfile( conf.experiment.pathToBinaryClassiferTrains, conf.val.filename_score_matrix);
    
    conf.val.FileNameScoreMatrix	= [conf.datasetName, '.',conf.svm.solver,str_pre,str_prop, str_val,str_suffix_bla];
    conf.val.midle_file_test       =                   ['.',conf.svm.solver,str_pre,str_prop];
    conf.val.filename_test_using_onevsall_ready    = [conf.datasetName, '.',conf.svm.solver,str_pre,str_prop, str_val,'.ready.mat'];   
    conf.val.path_filename_test_using_onevsall_ready    = fullfile(conf.experiment.pathToBinaryClassiferTrains,  conf.val.filename_test_using_onevsall_ready );
    %---------------------------------------------------------------------
    % Xac dinh tham so testing
    %---------------------------------------------------------------------
    
    conf.test.filename =  [conf.datasetName,str_test,'.sbow.mat'];    
    conf.test.filename_sparse =  [conf.datasetName,str_test,'.sparse.sbow.mat'];    
    
    
    if strcmp( conf.datasetName,'ILSVRC2010')         
      
        conf.test.path_filename             = fullfile(conf.path.pathToIMDBDirTest,    conf.test.filename);
        conf.test.path_filename_sparse      = fullfile(conf.path.pathToIMDBDirTest,    conf.test.filename_sparse);
    else
        conf.test.path_filename             = fullfile(conf.experiment.pathToBinaryClassifer,    conf.test.filename);
        conf.test.path_filename_sparse      = fullfile(conf.experiment.pathToBinaryClassifer,    conf.test.filename_sparse);
    end
    
    conf.test.filename_evaluation    = [conf.datasetName, '.',conf.svm.solver,str_pre,str_prop, str_test,'.eval.mat'];    
    conf.test.path_filename_evaluation    = fullfile(conf.experiment.pathToBinaryClassiferTrains, conf.test.filename_evaluation);
    
    conf.test.filename_score_matrix  = [conf.datasetName, '.',conf.svm.solver,str_pre,str_prop, str_test,'.scores.mat'];
    conf.test.midle_file_test       =                   ['.',conf.svm.solver,str_pre,str_prop];
    conf.test.filename_test_using_onevsall_ready    = [conf.datasetName, '.',conf.svm.solver,str_pre,str_prop, str_test,'.ready.mat'];   
    conf.test.path_filename_test_using_onevsall_ready  = fullfile(conf.experiment.pathToBinaryClassiferTrains,  conf.test.filename_test_using_onevsall_ready );
   
    %---------------------------------------------------------------------
    % Xac dinh tham so svm
    %---------------------------------------------------------------------
    
    conf.svm.suffix_file_model  = [str_pre,str_prop,'.model.mat'];    
    conf.svm.suffix_file_train  = '.trainingset.mat';
    
    conf.svm.filename_neg_set   = 'neg_set.mat';
    
    conf.svm.mid_file_test  =  ['.',conf.svm.solver, str_pre,str_prop];
    
    conf.svm.filename_classifier_ready    = [conf.datasetName, '.',conf.svm.solver,str_pre,str_prop,'.classifier.ready.mat']; 
    
    conf.svm.prefix_ready_testtrain    = [conf.datasetName, str_pre];
    conf.svm.prefix_ready_valtrain     = [conf.datasetName, str_pre];
    
    conf.svm.suffix_ready_testtrain     = '.train.ready.mat'; 
    conf.svm.suffix_ready_valtrain      = '.train.ready.mat'; 
    
    conf.svm.suffix_file_testtrain      = '.train.mat';     
    conf.svm.suffix_file_valtrain       = '.train.mat';
    
 
    %---------------------------------------------------------------------
    % Xac dinh tham so testing - validation
    %---------------------------------------------------------------------  
    
    conf.testval.filename               = [conf.datasetName,str_test,str_val,'.mat'];
    conf.testval.path_filename          = fullfile(conf.experiment.pathToBinaryClassifer, conf.testval.filename);
    conf.testval.path_filename_ready    = fullfile(conf.experiment.pathToBinaryClassifer, [conf.datasetName,str_test,str_val,'.ready.mat']);
    
  
    
   
  
end


function [ conf ] = SetupIMDB( conf )
%SetupIMDB Thiet lap cac tham so cua image database
%   Detailed explanation goes here
    fprintf('\n -----------------------------------------------');
    fprintf('\n Setup IMDB for datatset: %s ...',conf.datasetName);
 
     if strcmp( conf.datasetName,'ILSVRC65')  
        conf.IMDB.num_images_train  = 100; 
        conf.IMDB.num_images_test   = 150;     
        conf.IMDB.num_images_val    = 50;
        
     elseif strcmp( conf.datasetName,'ILSVRC2010')  
        % conf.IMDB.num_images_train  = 100; 
        conf.IMDB.num_images_train  = 100;
        conf.IMDB.num_images_test   = 150;     
        conf.IMDB.num_images_val    = 30;
        
        conf.IMDB.num_images_test_per_chunk_file   = 1000;  
        conf.IMDB.num_images_val_per_chunk_file    = 1000;
        
     elseif strcmp(conf.datasetName ,'ImageCLEF2012')
        conf.IMDB.num_images_train  = 75/100;        
        conf.IMDB.num_images_val    = 25/100;     
        conf.IMDB.num_images_test   = 100/100;     
    elseif strcmp(conf.datasetName ,'Caltech256') 
        conf.IMDB.num_images_train  = 40; 
        conf.IMDB.num_images_test   = 20;     
        conf.IMDB.num_images_val    = 20;       
    elseif strcmp(conf.datasetName ,'SUN397')
        conf.IMDB.num_images_train  = 50/100; 
        conf.IMDB.num_images_test   = 25/100;     
        conf.IMDB.num_images_val    = 25/100;       
    end    
    
    num_images_train = conf.IMDB.num_images_train; 
    num_images_test  = conf.IMDB.num_images_test;
    num_images_val   = conf.IMDB.num_images_val;
    if num_images_train >0.0 && num_images_train < 1.0
        num_images_train_percent    = uint32(num_images_train*100);
        num_images_val_percent      = uint32(num_images_val*100);
        num_images_test_percent     = uint32( num_images_test*100);

        FeaturesDirTrain  = sprintf('train%dp',  num_images_train_percent);   
        FeaturesDirVal    = sprintf('val%dp',    num_images_val_percent);  
        FeaturesDirTest   = sprintf('test%dp',   num_images_test_percent);  
        FeaturesDirTrainVal  = sprintf('train%dpval%dp',  num_images_train_percent,num_images_val_percent); 

        str_train_val_test = sprintf('train%dp.val%dp.test%dp',  num_images_train_percent,num_images_val_percent,num_images_test_percent);
    else
        FeaturesDirTrain  = sprintf('train%d',  num_images_train);   
        FeaturesDirVal    = sprintf('val%d',    num_images_val);  
        FeaturesDirTest   = sprintf('test%d',   num_images_test);  
        FeaturesDirTrainVal  = sprintf('train%dval%d',  num_images_train,num_images_val); 

        str_train_val_test = sprintf('train%d.val%d.test%d',  num_images_train,num_images_val,num_images_test);
    end
    
    
    
    
    conf.IMDB.filename_ready     = [conf.datasetName,'.',str_train_val_test , '.ready.mat' ];
    
    pathToIMDBDir  = conf.path.pathToIMDBDir;
    conf.IMDB.path_filename_ready = fullfile(pathToIMDBDir,conf.IMDB.filename_ready);
    
    
    
    if strcmp( conf.datasetName,'ILSVRC2010')   
        pathToIMDBDir  = conf.path.pathToIMDBDir;
    else
        pathToIMDBDir  = fullfile(conf.path.pathToIMDBDir, str_train_val_test);
    end
         
    
    utility.MakeDirectory(pathToIMDBDir);
    
    pathToIMDBDirTrain  = fullfile(pathToIMDBDir,FeaturesDirTrain);   
    pathToIMDBDirVal    = fullfile(pathToIMDBDir,FeaturesDirVal);   
    pathToIMDBDirTest   = fullfile(pathToIMDBDir,FeaturesDirTest);  
    pathToIMDBDirTrainVal  = fullfile(pathToIMDBDir,FeaturesDirTrainVal); 
    
    
    utility.MakeDirectory(pathToIMDBDirTrain);
    utility.MakeDirectory(pathToIMDBDirVal);
    utility.MakeDirectory(pathToIMDBDirTest);
    utility.MakeDirectory(pathToIMDBDirTrainVal);
    
    conf.path.pathToIMDBDirTrain   = pathToIMDBDirTrain ;
    conf.path.pathToIMDBDirVal     = pathToIMDBDirVal ;
    conf.path.pathToIMDBDirTest    = pathToIMDBDirTest ;
    conf.path.pathToIMDBDirTrainVal   = pathToIMDBDirTrainVal;
    
    
 end


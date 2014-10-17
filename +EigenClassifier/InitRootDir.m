function [ conf ] = InitRootDir( conf )
% This fuction is used for initing directoris
    fprintf('\n -----------------------------------------------');
    fprintf('\n Initializing root directories ...');
    if isunix
         if strcmp( conf.datasetName,'ILSVRC65')
            rootDir = '/data/Dataset/LSVRC/ILSVRC65';
            conf.dir.rootDir         = rootDir;
            conf.dir.rootImagesDir   = fullfile(rootDir, 'images');
            conf.dir.imagesDir       = 'ilsvrc65.train';
            conf.dir.experimentDir = fullfile(rootDir, 'experiments');
        elseif strcmp( conf.datasetName,'ILSVRC2010')
            rootDir = '/data/Dataset/LSVRC/2010';
            conf.dir.rootDir         = rootDir;
            conf.dir.rootImagesDir   = fullfile(rootDir, 'images');
            conf.dir.imagesDir       = 'train';
            conf.path.pathToModel   = '/net/per610a/export/das11f/plsang/dungmt';
            conf.path.pathToModelClassifer   = '/net/per610a/export/das11f/plsang/dungmt';
             conf.dir.experimentDir = fullfile(rootDir, 'experiments');
        elseif strcmp(conf.datasetName ,'Caltech256')
            rootDir = '/data/Dataset/256_ObjectCategories';
            conf.dir.rootDir        = rootDir;
            conf.dir.rootImagesDir 	= rootDir;
            conf.dir.imagesDir      = '256_ObjectCategories';       % Thu muc chua anh = rootDir\imagesDir
            conf.path.pathToModel    =  '/data/Dataset/256_ObjectCategories/imdb/svr';
            conf.path.pathToModelClassifer   =  '/data/Dataset/256_ObjectCategories/imdb';            
            conf.dir.experimentDir = fullfile(rootDir, 'experiments');
        elseif strcmp(conf.datasetName ,'SUN397')
            rootDir = '/data/Dataset/SUN';
            conf.dir.rootDir        = rootDir;
            conf.dir.rootImagesDir 	= rootDir;
            conf.dir.imagesDir      = 'SUN397';       % Thu muc chua anh = rootDir\imagesDir
            conf.dir.experimentDir = fullfile(rootDir, 'experiments');
         elseif strcmp(conf.datasetName ,'ImageCLEF2012')
            rootDir = '/data/Dataset/imageCLEF/imageclef2012';
            conf.dir.rootDir        = rootDir;
            conf.dir.rootImagesDir 	= rootDir;
            conf.dir.imagesDir      = 'train_images/images';       % Thu muc chua anh = rootDir\imagesDir
            conf.dir.experimentDir = fullfile(rootDir, 'experiments');
        else
            error('\nError: Dataset %s is not supported',conf.datasetName);
        end       
   elseif ispc
       if strcmp( conf.datasetName,'ILSVRC2010')
            conf.dir.rootDir         = 'D:\Dung Document\00_Nghiencuu\classification - Object detection\DataSet\LSVRC\2010\';
            conf.dir.rootImagesDir   = 'D:\Dung Document\00_Nghiencuu\classification - Object detection\DataSet\LSVRC\2010\image\';
            conf.dir.imagesDir       = 'train';
            conf.path.pathToModel    =  'D:\Dung Document\00_Nghiencuu\classification - Object detection\DataSet\LSVRC\2010\imdb';
            conf.path.pathToModelClassifer  =  'D:\Dung Document\00_Nghiencuu\classification - Object detection\DataSet\LSVRC\2010\imdb';      
            conf.dir.experimentDir          ='D:\Dung Document\00_Nghiencuu\classification - Object detection\DataSet\LSVRC\2010\experiments';     
       elseif strcmp(conf.datasetName ,'Caltech256')
            conf.dir.rootDir        = 'F:\Dataset\256_ObjectCategories';
            conf.dir.rootImagesDir 	= 'F:\Dataset\256_ObjectCategories';
            conf.dir.imagesDir      = '256_ObjectCategories';       % Thu muc chua anh = rootDir\imagesDir            
            conf.path.pathToModel    =  'F:\Dataset\256_ObjectCategories\imdb\svr';
            conf.path.pathToModelClassifer      =  'F:\Dataset\256_ObjectCategories\imdb';
            conf.dir.experimentDir              =  'F:\Dataset\256_ObjectCategories\experiments';     
       else
            error('\nError: Dataset %s is not supported',conf.datasetName);
       end
    end
    
    conf.dir.imdbDir         = 'imdb';
    fprintf(' finish !');

end


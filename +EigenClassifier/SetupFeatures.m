function [ conf ] = SetupFeatures( conf )
%SetupFeatures Thiet lap cac thong tin ve dac trung su dung
    %% -------------------------------------------------------------------
    %                                                       Setup Features
    % --------------------------------------------------------------------  
    fprintf('\n -----------------------------------------------');
    fprintf('\n Initializating features of image ...');
    conf.dir.featuresDir                 = 'features';                 % Thu muc chua features = rootDir\featuresDir 
    conf.feature.typeFeature             = 'phow'; % 'phow', 'hog','gist'...
    conf.feature.suffixFeature           = '.mat';
    conf.feature.fileNameFeatureIndex    = ['index_feature_' conf.datasetName '.mat'];        
    
    if strcmp(conf.feature.typeFeature,'hog')
        conf.feature.featextr = featpipem.features.HogExtractor();    
    elseif strcmp(conf.feature.typeFeature,'gist')
        conf.feature.featextr = featpipem.features.GistDescriptor();  
    elseif strcmp(conf.feature.typeFeature,'phow')
        conf.feature.featextr = featpipem.features.PhowExtractor();
        conf.feature.featextr.step = 3; 
        % default=2, dung luong file gap doi step = 3; da chay tren may 74
    end
    fprintf(' finish !');
    
    %% -------------------------------------------------------------------
    %                                                           Setup BOW 
    % -------------------------------------------------------------------- 
    fprintf('\n Initializating parameters of BOW model ...');
    
   
   if strcmp(conf.datasetName ,'ILSVRC65') 
        conf.BOW.ratio_images_selected_to_train_codebook=0.05; % 5%
        conf.BOW.voc_size =10000;      %So code word trong tu dien 
        conf.BOW.fileNameKeyPointsIndex  = ['index_kps_' conf.datasetName '.mat'];        
    elseif strcmp(conf.datasetName ,'ILSVRC2010') 
        conf.BOW.ratio_images_selected_to_train_codebook=0.05; % 5%
        conf.BOW.voc_size =10000;      %So code word trong tu dien 
        conf.BOW.fileNameKeyPointsIndex  = ['index_kps_' conf.datasetName '.mat'];        
    elseif strcmp(conf.datasetName ,'Caltech256') 
        conf.BOW.voc_size =4000;      %So code word trong tu dien
        conf.BOW.ratio_images_selected_to_train_codebook = 0.25; 
        conf.BOW.suffixFeatureTrainCodeBook = '_cb.mat';    
        conf.BOW.suffixKeyPoints = '.mat';  
        conf.BOW.fileNameKeyPointsTrainCodeBookIndex  = ['index_kps_cb_' conf.datasetName '.mat'];
        conf.BOW.fileNameKeyPointsIndex  = ['index_kps_' conf.datasetName '.mat'];
    elseif  strcmp(conf.datasetName ,'SUN397')
        conf.BOW.voc_size =4000;      %So code word trong tu dien
        conf.BOW.ratio_images_selected_to_train_codebook = 0.10; 
        conf.BOW.suffixFeatureTrainCodeBook = '_cb.mat';    
        conf.BOW.suffixKeyPoints = '.mat';  
        conf.BOW.fileNameKeyPointsTrainCodeBookIndex  = ['index_kps_cb_' conf.datasetName '.mat'];
        conf.BOW.fileNameKeyPointsIndex  = ['index_kps_' conf.datasetName '.mat'];
    elseif  strcmp(conf.datasetName ,'ImageCLEF2012')
        conf.BOW.voc_size =4000;      %So code word trong tu dien
        conf.BOW.ratio_images_selected_to_train_codebook = 0.10; 
        conf.BOW.suffixFeatureTrainCodeBook = '_cb.mat';    
        conf.BOW.suffixKeyPoints = '.mat';  
        conf.BOW.fileNameKeyPointsTrainCodeBookIndex  = ['index_kps_cb_' conf.datasetName '.mat'];
        conf.BOW.fileNameKeyPointsIndex  = ['index_kps_' conf.datasetName '.mat'];
    else
        error('\nError: Dataset %s is not supported',conf.datasetName);
    end 
    
    % tao cac thu muc con neu theo mo hinh BOW  
    %encoder & pooler
    conf.BOW.typeEncoder    = 'LLCEncoder' ; % cac loai 'LLCEncoder','VQEncoder','KCBEncoder'
    conf.BOW.typePooler     = 'SPMPooler'; % 'SPMPooler', ''    
    % Code Book


    suffixCodeBook = sprintf('_%d.mat', conf.BOW.voc_size);
    conf.BOW.fileNameCodeBook   =[conf.datasetName '_'  conf.BOW.typeCodebkGen suffixCodeBook];
    
    conf.BOW.dir.rootDir        = 'BOW';  % tao thu muc BOW
    conf.BOW.dir.keyPointsDir   = 'keypoints';  % tao thu muc BOW\keypoints
    conf.BOW.dir.codeBooksDir   = 'codebooks';  % tao thu muc BOW\codebooks

%     if strcmp(conf.BOW.typeCodebkGen,'kmeans')
        conf.BOW.codebkgen = featpipem.codebkgen.KmeansCodebkGen(conf.feature.featextr,conf.BOW.voc_size);
        conf.BOW.codebkgen.descount_limit = max(conf.BOW.voc_size,10e5);%  1,000,000 features will be used for training of codebook 
        %conf.codebkgen.trainimage_limit = 150; % limit number of images used to train
%     end
    
    fprintf(' finish !');

  
end


function [ conf ] = ExtractFeaturesAndSetupTrainTestValDataset( dataset, start_Idx,end_Idx, step)
%SETUPDATASET Extracting descriptors and split dataset into training, val
%and test
%   Detailed explanation goes here
    conf.stylesOrganizedImages.All          = 1; % imageclef
    conf.stylesOrganizedImages.Class        = 2; % Caltech256
    conf.stylesOrganizedImages.TrainTestVal = 3; % ILSVRC
    % Chon tap du lieu
    dataset_type = dataset;
    switch dataset_type
        case 0
            conf.datasetName         = 'ILSVRC2010';  
            conf.styleOrganizedImages = conf.stylesOrganizedImages.TrainTestVal;
        case 1
            conf.datasetName         = 'Caltech256';  
            conf.styleOrganizedImages = conf.stylesOrganizedImages.Class;
        case 2
            conf.datasetName         = 'SUN397';   
            conf.styleOrganizedImages = conf.stylesOrganizedImages.TrainTestVal;
          case 3
            conf.datasetName         = 'ILSVRC65';   
            conf.styleOrganizedImages = conf.stylesOrganizedImages.TrainTestVal;
         case 4
            conf.datasetName         = 'ImageCLEF2012';   
            conf.styleOrganizedImages = conf.stylesOrganizedImages.TrainTestVal;
    end
    
     % Khai bao cac thu vien
    utility.AddPathLib();    
    % Khoi tao cac thuc muc tuong ung
    conf = EigenClassifier.InitRootDir( conf );
    % thiet lap dac trung
    conf.BOW.typeCodebkGen = 'annkmeans';    % 'annkmeans' 'kmeans'
    conf  = EigenClassifier.SetupFeatures( conf );
    % Tao cac thu muc luu tru
    conf = EigenClassifier.MakeDirectories(conf );  
    % Load thong tin ve CSDL    
    conf  = EigenClassifier.LoadInforDataset( conf ); 
    
    % Extract Feature cho tap anh
%    matlabpool open 2;
     conf  = EigenClassifier.ExtractAndSaveFeatures(conf,start_Idx,end_Idx, step); 
%    matlabpool close;
	
    % Thiet lap cac tham so de chia tap du lieu
    % So luong anh train, test, val
    [ conf ] = EigenClassifier.SetupIMDB( conf );
    %Chia tap anh thanh train, val and test
    conf  = EigenClassifier.SplitTrainValTest( conf,start_Idx,end_Idx, step);

end


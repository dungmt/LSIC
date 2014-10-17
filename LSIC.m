% Large-Scale Image Classification
% NII
function LSIC( dataset, start_Idx,end_Idx, step)

    if nargin < 4
        fprintf('\n Syntax: LISC dataset start_Idx end_Idx  step');
        return;
    end
    dataset_type = dataset;
%     dataset_type = str2num(dataset);
%     start_Idx    = str2num(start_Idx);
%     end_Idx    = str2num(end_Idx);
%     step    = str2num(step);
    
    if step < 0
        if( start_Idx < end_Idx)
            error('Parameters is invalidate !');
        end
    elseif step >0 
        if( start_Idx > end_Idx)
            error('Parameters is invalidate !');
        end	
    else 
        error('Parameters is invalidate !');
    end

    conf.stylesOrganizedImages.All          = 1; % imageclef
    conf.stylesOrganizedImages.Class        = 2; % Caltech256
    conf.stylesOrganizedImages.TrainTestVal = 3; % ILSVRC
    % Chon tap du lieu
    if dataset_type ~=0
        conf.datasetName         = 'Caltech256';   % 'Caltech256', 'ILSVRC2010
        conf.styleOrganizedImages = conf.stylesOrganizedImages.Class;
    else
        conf.datasetName         = 'ILSVRC2010';   % 'Caltech256', 'ILSVRC2010
        conf.styleOrganizedImages = conf.stylesOrganizedImages.TrainTestVal;
    end
    
     % Khai bao cac thu vien
    AddPathLib();
    
    % Khoi tao cac thuc muc tuong ung
    conf = InitRootDir( conf );
    % thiet lap dac trung
    conf.BOW.typeCodebkGen = 'annkmeans';    % 'annkmeans' 'kmeans'
    conf  = SetupFeatures( conf );
    % Tao cac thu muc luu tru
    conf = MakeDirectories(conf );  
    % Load thong tin ve CSDL
    conf  = LoadInforDataset( conf ); 
    % Extract Feature cho tap anh
    conf  = ExtractAndSaveFeatures(conf);    
    % Thiet lap cac tham so de chia tap du lieu
    [ conf ] = SetupIMDB( conf );
    
    %Chia tap anh thanh train, val and test
    conf  = SplitTrainValTest( conf);
   
    %% ---------------------------------------------------------
    % Thiet lap cac tham so training
     conf.svm.solver = 'libsvm'; % 'pegasos',  'liblinear', 'libsvm'
    conf.svm.preCompKernel = true;
    
    conf  = InitTrainTest( conf );    
    % Thuc hien training classifier
    %conf  = TrainingTesting(conf);
    
    [ conf ] = CreateValidationSet( conf );
    [ conf ] = CreateTestingSet( conf );
%     precompkernel.PreComp_TestVal(conf);
     %classifier.Training(conf);OK
   %precompkernel.PreComp_ValTrain(conf);;OK
   %precompkernel.PreComp_TestTrain(conf); %OK
   %precompkernel.PreComp_TestOnTest(conf, 1,conf.class.Num, 1);
   
 
    TrainingTesting_All(conf, start_Idx,end_Idx, step);
  
   CombineResultTest_All( conf);
    
    Evaluate_All(conf, start_Idx,end_Idx, step);
    % Tao ma tran score tren tap Validation
    % CombineResultTestOnVal( conf);
    % CombineResultTestOnTest( conf); 
    % Thiet lap cac tham so SVD
    conf  = InitDecompose( conf );
    % Thuc hien Decomposing score_matrix
    Decomposing(conf);
  
   
   
    fprintf('\n+----------------------------------------------------+');
    fprintf('\n| Pseudo class                                       |');
    fprintf('\n+----------------------------------------------------+');
   
    pseudoClass = PseudoClass();     
    conf  = pseudoClass.Init(conf);    
  
   % Thuc hien training
    conf  = pseudoClass.Train(conf);

     % Thuc hien testing
    conf  = pseudoClass.Test(conf);     
        % Ket hop ket qua lai
    conf  = pseudoClass.Compose(conf); 
    CombineEvaluate_All(conf)  ;
    
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    
    conf = MergeTrainVal( conf );
    precompkernel.PreComp_TestVal(conf);
    TrainingTesting_All(conf, start_Idx,end_Idx, step);
    CombineResultTest_All( conf);
    
    Evaluate_All(conf, start_Idx,end_Idx, step);
    
    conf  = InitDecompose( conf );
    % Thuc hien Decomposing score_matrix
    Decomposing(conf);
  
   
   
    fprintf('\n+----------------------------------------------------+');
    fprintf('\n| Pseudo class    2                                   |');
    fprintf('\n+----------------------------------------------------+');
   
    pseudoClass = PseudoClass();     
    conf  = pseudoClass.Init(conf);    
  
   % Thuc hien training
    conf  = pseudoClass.Train(conf);

     % Thuc hien testing
    conf  = pseudoClass.Test(conf);     
        % Ket hop ket qua lai
    conf  = pseudoClass.Compose(conf); 
    CombineEvaluate_All(conf)  ;
    fprintf('\nDONE !\n')

end
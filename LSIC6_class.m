% Large-Scale Image Classification
% NII
% Update 6/6
function LSIC6_class( dataset, optionR,approach, start_Idx,end_Idx, step,ci_start,ci_end,num_Child, isAuto, K_Pseudoclass, idx_alg)
    if nargin < 4
        fprintf('\n Syntax: LISC dataset start_Idx end_Idx  step');
        return;
    end
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

%     conf.stylesOrganizedImages.All          = 1; % imageclef
%     conf.stylesOrganizedImages.Class        = 2; % Caltech256
%     conf.stylesOrganizedImages.TrainTestVal = 3; % ILSVRC
   
    [ conf ] = EigenClassifier.ExtractFeaturesAndSetupTrainTestValDataset(dataset,start_Idx,end_Idx, step);
    %% ---------------------------------------------------------
    % Thiet lap cac tham so training

    conf.svm.solver = 'liblinear'; % 'vl_svmtrain {'sgd', 'sdca'}',  'liblinear', 'libsvm'    
    conf.svm.preCompKernel = false;
    
    conf.svr.solver = 'liblinear'; % 'liblinear' 'libsvm'
    conf.svr.preCompKernel = false;
   
    conf  = InitTrainTest4( conf ); % Cap nhat so voi 3    
   
    % Thuc hien training classifier
    %conf  = TrainingTesting(conf);
    [ conf ] = CreateTrainingSet( conf );  
    [ conf ] = CreateValidationSet( conf );   
    [ conf ] = CreateTestingSet( conf );  
   
%      precompkernel.PreComp_TestVal(conf);
     %classifier.Training(conf);OK
   %precompkernel.PreComp_ValTrain(conf);;OK
   %precompkernel.PreComp_TestTrain(conf); %OK
   %precompkernel.PreComp_TestOnTest(conf, 1,conf.class.Num, 1);
   
   
    
   %% ------------------------------------------------------------
    
   conf.isOverWriteResult = false;
     [ conf ] = TrainOneVsAll( conf , start_Idx,end_Idx, step);
 
%   [ conf ] = TestOneVsAll( conf , start_Idx,end_Idx, step);
%   conf.isOverWriteResult = true;
%    [ conf ] = ValOneVsAll( conf , start_Idx,end_Idx, step);
%   CombineResultTest_All( conf);
%    Evaluate_All(conf);
   %% ------------------------------------------------------------
   
    % Thiet lap cac tham so SVD
   conf.pseudoclas.str_decompose = 'svds';
  %  conf.pseudoclas.str_decompose = 'nmf';
    
    conf  = InitDecompose( conf,K_Pseudoclass, idx_alg );
%     optionR=0;
%     approach=321;
   conf = EigenClassifier(conf, optionR, approach);
   
   return; 
   conf.isOverWriteResult= false;
  
%   [ conf ] = ValOneVsAll( conf , start_Idx,end_Idx, step);
  [ conf ] = TestOneVsAll( conf , start_Idx,end_Idx, step);

  conf.isOverWriteResult = false;   

% 
% %     [ conf ] = TrainingTesting_All4(conf, start_Idx,end_Idx, step);
% 
%    CombineResultTest_All( conf);
size(conf.eigenclass.Rval)
size(conf.eigenclass.Rtest)


   Evaluate_All(conf);

%    Q=num_Child;
  % isAuto = 0;
%     [conf] =  HC.LabelTree( conf,Q,isAuto);
  
    % Tao ma tran score tren tap Validation
    % CombineResultTestOnVal( conf);
    % CombineResultTestOnTest( conf); 

  
    % Thuc hien Decomposing score_matrix
    conf.isOverWriteResult = false;
    Decomposing(conf);
  
    
   
    fprintf('\n+----------------------------------------------------+');
    fprintf('\n| Pseudo class                                       |');
    fprintf('\n+----------------------------------------------------+');
   
    pseudoClass = PseudoClass();     
    conf  = pseudoClass.Init(conf);    
  
    conf.isOverWriteSVRTrain=false   ;
    conf.isOverWriteSVRTest=false   ;
  
 
   % Thuc hien training
      conf  = pseudoClass.Train(conf,ci_start,ci_end);
     % Thuc hien testing
     
      conf  = pseudoClass.Test(conf,ci_start,ci_end);   
        % Ket hop ket qua lai  
    conf.isOverWriteResult= true;
      conf  = pseudoClass.Compose(conf); 
     CombineEvaluate_All(conf)  ;
%     CreateHTML(conf);
    return;
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
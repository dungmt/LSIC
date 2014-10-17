% Large-Scale Image Classification
% NII
% Updated 2014-Oct-03

function MainClassify( dataset,start_Idx,end_Idx, step,optionR,approach,ci_start,ci_end,num_Child, isAuto)

    [ conf ] = EigenClassifier.ExtractFeaturesAndSetupTrainTestValDataset( dataset, start_Idx,end_Idx, step);

    [ conf ] = EigenClassifier.OVAClassify( conf , start_Idx,end_Idx, step);
  
    % ------------------------------------------------------------
   
    % Thiet lap cac tham so SVD
   conf.pseudoclas.str_decompose = 'svds'; % chi co hai truong hop: 'svds' / 'nmf'
   L_EigenClass=0;
   idx_alg=0;
  %  If 'nmf': conf.pseudoclas.str_decompose = 'nmf'; then idx_alg la index
  %  of approach 'mm', 'cjlin', 'als', 'alsobs', 'prob', 'mat_als', 'mat_mult','cjlin_tw'
  %  L_EigenClass: L-largest singular values 
     
    
    conf  = EigenClassifier.InitDecompose( conf,L_EigenClass, idx_alg );
%     optionR=0;
%     approach=321;
   conf = EigenClassifier.EigenClassifier(conf, optionR, approach);
   
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


%    Evaluate_All(conf);

%    Q=num_Child;
  % isAuto = 0;
%     [conf] =  HC.LabelTree( conf,Q,isAuto);
  
    % Tao ma tran score tren tap Validation
    % CombineResultTestOnVal( conf);
    % CombineResultTestOnTest( conf); 

  
    
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
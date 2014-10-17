% Large-Scale Image Classification
% NII
% Updated 2014-Oct-17

function MainClassify( dataset,start_Idx,end_Idx, step,optionR,approach)

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


end
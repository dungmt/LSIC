% Large-Scale Image Classification
% NII
% Updated 2014-Oct-03

function MainLabelTree( dataset,start_Idx,end_Idx, step,num_Child, isAuto)

    [ conf ] = EigenClassifier.ExtractFeaturesAndSetupTrainTestValDataset( dataset, start_Idx,end_Idx, step);

    % Thiet lap cac tham so training

    conf.svm.solver = 'liblinear'; % 'vl_svmtrain {'sgd', 'sdca'}',  'liblinear', 'libsvm'    
    conf.svm.preCompKernel = false;
    
    conf.svr.solver = 'liblinear'; % 'liblinear' 'libsvm'
    conf.svr.preCompKernel = false;
    conf  = EigenClassifier.InitTrainTest4( conf ); % Cap nhat so voi 3    
    
    
    Q=num_Child;
%     isAuto = 0;
    [conf] =  HC.LabelTree( conf,Q,isAuto); 
 
end
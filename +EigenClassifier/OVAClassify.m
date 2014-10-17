function [ conf ] = OVAClassify( conf , start_Idx,end_Idx, step)
%OVACLASSIFY Learning binary OVA classifiers and Testing
%   Detailed explanation goes here
    %% ---------------------------------------------------------
    % Thiet lap cac tham so training

    conf.svm.solver = 'liblinear'; % 'vl_svmtrain {'sgd', 'sdca'}',  'liblinear', 'libsvm'    
    conf.svm.preCompKernel = false;
    
    conf.svr.solver = 'liblinear'; % 'liblinear' 'libsvm'
    conf.svr.preCompKernel = false;
   
    conf  = EigenClassifier.InitTrainTest4( conf ); % Cap nhat so voi 3    
   
    % Thuc hien training classifier
    %conf  = TrainingTesting(conf);
    [ conf ] = EigenClassifier.CreateTrainingSet( conf );    
    [ conf ] = EigenClassifier.CreateValidationSet( conf );   
    [ conf ] = EigenClassifier.CreateTestingSet( conf );  
   
   %precompkernel.PreComp_TestVal(conf);
   %classifier.Training(conf);OK
   %precompkernel.PreComp_ValTrain(conf);;OK
   %precompkernel.PreComp_TestTrain(conf); %OK
   %precompkernel.PreComp_TestOnTest(conf, 1,conf.class.Num, 1);
   
   
    
   %% ------------------------------------------------------------
    
   conf.isOverWriteResult = false;
   [ conf ] = EigenClassifier.TrainOneVsAll( conf , start_Idx,end_Idx, step);
   [ conf ] = EigenClassifier.TestOneVsAll( conf , start_Idx,end_Idx, step);
   conf.isOverWriteResult = true;
    [ conf ] = EigenClassifier.ValOneVsAll( conf , start_Idx,end_Idx, step);
   [ conf ] = CombineResultTest_All( conf);
    Evaluate_All(conf);
   %

end


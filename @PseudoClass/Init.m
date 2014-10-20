function conf  = Init(obj,conf)
%Init Khoi tao cac tham so de training pseudoclass
%   Detailed explanation goes here
	fprintf('\n Initializing the parameters of pseudo classes ...');
    obj.solvertype  = conf.svr.solver;
    obj.isPreComp   =  conf.svr.preCompKernel;
    
    obj.kerneltype  = 'linear';
%             obj.svmtype = 'epsilon-svr';
%             obj.model = [];

	if strcmp( conf.datasetName,'ILSVRC65')         
        obj.scaleValue = 3000;  % Vi gia tri SVDs nho
        obj.cValue = 1;
    elseif strcmp( conf.datasetName,'ILSVRC2010')         
        obj.scaleValue = 1000;  % Vi gia tri SVDs nho
        obj.cValue = 1;
    elseif strcmp( conf.datasetName,'Caltech256') || strcmp( conf.datasetName,'SUN397')
        obj.scaleValue = conf.class.Num;
       % obj.scaleValue = 1000;
        obj.cValue = 1;
    end
    
   
    if obj.isPreComp
        svr_str_pre = ['.pre.', obj.kerneltype];
    else
        svr_str_pre = '';
    end
   
    %Caltech256.libsvm.pre.prob.bla5.val30.scores.svds.257.svr.libsvm.pre.linear.001.mat
        
    str_tmp1= conf.pseudoclas.filename_decomposed;
    str_tmp2 = strrep (str_tmp1, '.mat' , '');   
    conf.svr.prefix_file_model = [str_tmp2,'.svr.',obj.solvertype, svr_str_pre,'.'];
    conf.svr.suffix_file_model = '.mat';
    
    %Caltech256.libsvm.pre.prob.val30.svds.200.svr.libsvm.ontest.final
    filename_score_matrix = conf.pseudoclas.filename_score_matrix;
    filename_no_ext = strrep (filename_score_matrix, '.mat' , '');    
    
    %---------------------------------------------------------------------
    % Xac dinh tham so experiment
    %---------------------------------------------------------------------  
  
    if conf.svr.preCompKernel
        str_pre_svr = '.pre';
    else
        str_pre_svr = '';
    end
    str_prop = '.prob';
    
    if strcmp(conf.pseudoclas.str_decompose,'svds')
        conf.experiment.filename_combine_evaluation    = [conf.datasetName, '.',conf.svm.solver,conf.svm.str_pre,str_prop, '.svr.',conf.svr.solver,'.',conf.pseudoclas.str_decompose,str_pre_svr,'.eval.mat'];
        conf.experiment.path_filename_svr_ready = fullfile(conf.experiment.pathToRegressionTrains,['svr.', conf.svr.solver,'.',conf.pseudoclas.str_decompose,str_pre_svr, '.ready.mat']);
        conf.experiment.path_filename_combine_evaluation = fullfile(conf.experiment.pathToRegressionTrainsTest,conf.experiment.filename_combine_evaluation);
        
%         conf.experiment.filename_combine_evaluation    = [conf.datasetName, '.',conf.svm.solver,conf.svm.str_pre,str_prop, '.svr.',conf.svr.solver,'.',conf.pseudoclas.str_decompose,'.',conf.pseudoclas.str_k,str_pre_svr,'.eval.mat'];
%         conf.experiment.path_filename_svr_ready = fullfile(conf.experiment.pathToRegressionTrains,['svr.', conf.svr.solver,'.',conf.pseudoclas.str_decompose,'.',conf.pseudoclas.str_k,str_pre_svr, '.ready.mat']);

 
    elseif strcmp(conf.pseudoclas.str_decompose,'nmf')        

        conf.experiment.filename_combine_evaluation    = [conf.datasetName, '.',conf.svm.solver,conf.svm.str_pre,str_prop, '.svr.',conf.svr.solver,'.',conf.pseudoclas.str_decompose,'.',conf.pseudoclas.str_nmf_alg,'.',conf.pseudoclas.str_k,str_pre_svr,'.eval.mat'];
        conf.experiment.path_filename_svr_ready = fullfile(conf.experiment.pathToRegressionTrains,['svr.', conf.svr.solver,'.',conf.pseudoclas.str_decompose,'.',conf.pseudoclas.str_nmf_alg,'.',conf.pseudoclas.str_k, str_pre_svr, '.ready.mat']);
        
        
    end
    conf.experiment.path_filename_combine_evaluation = fullfile(conf.experiment.pathToRegressionTrainsTest,conf.experiment.filename_combine_evaluation);
        
    conf.svr.prefix_file_ontest = [filename_no_ext, '.',conf.pseudoclas.str_decompose, '.'];    
    conf.svr.suffix_file_ontest       = ['.svr.',obj.solvertype, svr_str_pre,'.ontest.mat'];
    conf.svr.suffix_file_ontest_final = ['.svr.',obj.solvertype, svr_str_pre,'.ontest.final.mat'];

    str_test = conf.test.str_test; 

    conf.svr.filename_score_matrix = [str_tmp2,'.svr.',obj.solvertype, svr_str_pre,str_test,'.scores.mat'];
    conf.svr.filename_compose_ready = [str_tmp2,'.svr.',obj.solvertype, svr_str_pre,str_test,'.ontest.final.ready.mat'];
    
    conf.svr.path_filename_score_matrix  = fullfile(conf.experiment.pathToRegressionTrainsTest, conf.svr.filename_score_matrix);
    conf.svr.path_filename_compose_ready = fullfile(conf.experiment.pathToRegressionTrainsTest, conf.svr.filename_compose_ready);
  
  
    
   
    fprintf(' finished !');
    
    
    

end


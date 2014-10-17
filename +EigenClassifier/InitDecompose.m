function conf  = InitDecompose(conf, L_EigenClass, idx_alg)
%UNTITLED6 Summary of this function goes here
%   L_EigenClass: L-largest singular values 
%   idx_alg: Index of  approach factorizing response matrix R

    fprintf('\n EigenClassifier:InitDecompose...');

    conf.pseudoclas.pathToDirSVD    =  conf.experiment.pathToBinaryClassiferTrains;
    
    if strcmp(conf.datasetName, 'ILSVRC2010')       
       if strcmp(conf.pseudoclas.str_decompose,'svds')      
            conf.pseudoclas.arr_Step = [24 30 64 100 200 300 400 500 600 700 800 900 1000];
       else
            conf.pseudoclas.arr_Step = L_EigenClass;
       end
    elseif strcmp(conf.datasetName, 'Caltech256')         
       if strcmp(conf.pseudoclas.str_decompose,'svds')      
            conf.pseudoclas.arr_Step = [16 20 32 50 100 150 200 256];
       else
            conf.pseudoclas.arr_Step = L_EigenClass;
       end
    elseif strcmp(conf.datasetName, 'SUN397')         
       if strcmp(conf.pseudoclas.str_decompose,'svds')      
            conf.pseudoclas.arr_Step = [20 25 40 50 100 200 300 397];
       else
           conf.pseudoclas.arr_Step = L_EigenClass;
       end
    elseif strcmp(conf.datasetName, 'ILSVRC65')         
        if strcmp(conf.pseudoclas.str_decompose,'svds')      
            conf.pseudoclas.arr_Step = [5 10 20 30 40 50 57];
        else
            conf.pseudoclas.arr_Step = L_EigenClass;
        end
    elseif strcmp(conf.datasetName, 'ImageCLEF2012')       
       if strcmp(conf.pseudoclas.str_decompose,'svds')      
            conf.pseudoclas.arr_Step = [5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 94];
       else
            conf.pseudoclas.arr_Step = L_EigenClass;
       end
    else
        error('InitDecompose:%s',conf.datasetName);
    end 

 
    k = conf.pseudoclas.arr_Step(length(conf.pseudoclas.arr_Step));        
    str_k = num2str(k,'%.3d'); 
    conf.pseudoclas.str_k = str_k;
    
    str_decompose = conf.pseudoclas.str_decompose;
    
    str_nmf_alg_arr = {'mm', 'cjlin', 'als', 'alsobs', 'prob', 'mat_als', 'mat_mult','cjlin_tw'};
    idx_alg = min(max(idx_alg,1),length(str_nmf_alg_arr));
    str_nmf_alg     = str_nmf_alg_arr{idx_alg};
    
    
  
%---------------------
    conf.pseudoclas.filename_score_matrix   = conf.val.filename_score_matrix;
    filename_score_matrix = conf.pseudoclas.filename_score_matrix;
    filename_no_ext = strrep (filename_score_matrix, '.mat' , ''); 
    
   
    if strcmp(str_decompose , 'svds')
        str_decompose_alg = 'svds';
        fprintf('\n str_decompose: %s',str_decompose);
    elseif strcmp(str_decompose , 'nmf')
        conf.pseudoclas.str_nmf_alg = str_nmf_alg;
        str_decompose_alg = [str_decompose,'.', str_nmf_alg];
        fprintf('\n str_decompose: %s',str_decompose);
        fprintf('\n str_nmf_alg: %s',str_nmf_alg);
    else
        error('str_decompose: %s', str_decompose); 
    end
    
       
    conf.pseudoclas.formatSpec_SVDS     = [filename_no_ext, '.', str_decompose_alg,'.%s.mat'];    
    conf.pseudoclas.filename_decomposed = [filename_no_ext, '.', str_decompose_alg,'.',str_k, '.mat'];
    conf.pseudoclas.path_filename_decomposed = fullfile(conf.experiment.pathToBinaryClassiferTrains, conf.pseudoclas.filename_decomposed);
    
    
    
    % Regression
        
    if strcmp(str_decompose , 'svds')
%         conf.experiment.dirRegression     = ['svr.svds.',conf.pseudoclas.str_k ];
        conf.experiment.dirRegression     = 'svr.svds';
    elseif strcmp(str_decompose , 'nmf')
        conf.experiment.dirRegression     = [ 'svr.nmf.', conf.pseudoclas.str_nmf_alg,'.',conf.pseudoclas.str_k ];
    else
        error('str_decompose: %s', str_decompose); 
    end

    trainDir    = conf.train.trainDir ;
    testDir     = conf.test.testDir ;
    
    conf.experiment.pathToRegression       = fullfile(conf.path.pathToExperimentDir,conf.experiment.dirRegression);
    utility.MakeDirectory(conf.experiment.pathToRegression);

    conf.experiment.pathToRegressionTrains          = fullfile(conf.experiment.pathToRegression, trainDir);
    conf.experiment.pathToRegressionTrainsTest      = fullfile(conf.experiment.pathToRegressionTrains, testDir);
    
    utility.MakeDirectory(conf.experiment.pathToRegressionTrains);
    utility.MakeDirectory(conf.experiment.pathToRegressionTrainsTest);
    
    % Update 07-Oct
    conf.experiment.pathToRPQ          = fullfile(conf.path.pathToExperimentDir,'RPQ');
    conf.experiment.pathToRPQTrains    = fullfile(conf.experiment.pathToRPQ,trainDir);
    
    utility.MakeDirectory(conf.experiment.pathToRPQ);
    utility.MakeDirectory(conf.experiment.pathToRPQTrains);   
    

    
end


function conf  = InitDecompose_Train(conf)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here


    conf.pseudoclas.pathToDirSVD    =  conf.experiment.pathToBinaryClassiferTrains;
    
    if strcmp(conf.datasetName, 'ILSVRC2010')       
%         conf.pseudoclas.arr_Step = [24, 30, 64, 100 200 300 400 500 600 700 800 900 1000];
         conf.pseudoclas.arr_Step = [24, 30, 64, 100, 200,300, 1000];
    elseif strcmp(conf.datasetName, 'Caltech256')         
        conf.pseudoclas.arr_Step = [16 20 32 50 100 150 200 256];
    elseif strcmp(conf.datasetName, 'SUN397')         
        conf.pseudoclas.arr_Step = [20 50 100 200 300 397];
    end 
 
    k = conf.pseudoclas.arr_Step(length(conf.pseudoclas.arr_Step));        
    str_k = num2str(k,'%.3d');  
    
    conf.pseudoclas.filename_score_matrix   = conf.train.filename_score_matrix;
    
    filename_score_matrix = conf.pseudoclas.filename_score_matrix;
    filename_no_ext = strrep (filename_score_matrix, '.mat' , '');    
    conf.pseudoclas.formatSpec_SVDS = [filename_no_ext, '.svds.%s.mat'];
    
    conf.pseudoclas.filename_decomposed = [filename_no_ext, '.svds.',str_k, '.mat'];
    conf.pseudoclas.path_filename_decomposed = fullfile(conf.experiment.pathToBinaryClassiferTrains, conf.pseudoclas.filename_decomposed);
    
end


function conf  = Train(obj,conf,ci_start,ci_end)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
	fprintf('\n Training the model of pseudo classes ...');
    
      
    isPreComp       = obj.isPreComp;
    num_pseudoClass = obj.num_pseudoClass;
    solvertype      = obj.solvertype; % obj.solvertype = 'libsvm';
    ScaleValue      = obj.scaleValue;
    C_Value         = obj.cValue;
    fprintf('\n\t Scale value: %d', ScaleValue);
    fprintf('\n\t c value: %f', C_Value);
  %  fprintf('\n\t Number of pseudo classes: %d', num_pseudoClass);
   % kerneltype = 'precomputed kernel'; %obj.kerneltype;
   % svmtype = obj.svmtype;
    fprintf('\n\t Solver type: %s', solvertype);
 %   fprintf('\n\t Kernel type: %s', kerneltype); % obj.kerneltype = 'linear';
  %  fprintf('\n\t SVM type: %s', svmtype); % obj.svmtype = 'epsilon-svr';
% libsvm   
%     -s svm_type : set type of SVM (default 0)
% 	0 -- C-SVC		(multi-class classification)
% 	1 -- nu-SVC		(multi-class classification)
% 	2 -- one-class SVM
% 	3 -- epsilon-SVR	(regression)
% 	4 -- nu-SVR		(regression)
% -t kernel_type : set type of kernel function (default 2)
% 	0 -- linear: u'*v
% 	1 -- polynomial: (gamma*u'*v + coef0)^degree
% 	2 -- radial basis function: exp(-gamma*|u-v|^2)
% 	3 -- sigmoid: tanh(gamma*u'*v + coef0)
% 	4 -- precomputed kernel (kernel values in training_instance_matrix)
%% ----liblinear
%    -s type : set type of solver (default 1)
%    0 -- L2-regularized logistic regression (primal)
% 	 6 -- L1-regularized logistic regression
% 	 7 -- L2-regularized logistic regression (dual)
% 	11 -- L2-regularized L2-loss support vector regression (primal)
% 	12 -- L2-regularized L2-loss support vector regression (dual)
% 	13 -- L2-regularized L1-loss support vector regression (dual)

	
	
   
    str_C_Value = sprintf('%f',C_Value);

    str_pre = '';
    switch solvertype
        %---------------------------------------%
        case 'liblinear'             
            libsvm_options = ['-s 11 -c ',str_C_Value];  
%           path_filename_instance_matrix = conf.val.path_filename;
            isPreComp = false;            
            path_filename_instance_matrix   = conf.val.path_filename;
        %---------------------------------------%    
        case 'libsvm'                            
            if isPreComp 
                libsvm_options = ['-s 3 -t 4 -m 20000 -c ', str_C_Value];
                str_pre = '.pre';
                path_filename_instance_matrix = conf.val.path_filename_pre_valval;
            else                            
                libsvm_options = ['-s 3 -t 0 -m 20000 -c ', str_C_Value];      
                path_filename_instance_matrix = conf.val.path_filename;
            end       
    end
    fprintf('\n\t Training SVR ...');
    path_filename_svr_ready = conf.experiment.path_filename_svr_ready;
    if ~ exist(path_filename_svr_ready,'file') || conf.isOverWriteSVRTrain==true        
        classifier.SVR_Train(conf,solvertype,path_filename_instance_matrix, libsvm_options,isPreComp,ScaleValue, conf.pseudoclas.arr_Step,ci_start,ci_end);
        fprintf(' finished !');
        ready=1;
        save(path_filename_svr_ready,'ready');
    else 
        fprintf(' finished (ready)!');
    end
    

end


classdef RegressionLibSVM < handle & featpipem.classification.svm.RegressionSvm
%LIBSVM Train an SVM classifier using the LIBSVM library
%  Input arguments
% trnY
% This is a  dimensional vector of the training data response values, 
% where  is the total number of samples.
% trnX
% This is a  dimensional training data input matrix, 
% where  is the total number of samples and  is the number of features for each sample.
% Tunable parameters
% param
% This is a string which specifies the model parameters. 
% For Regression, a typical parameter string may look like, ‘-s 3 -t 2 -c 20 -g 64 -p 1’ where
% -s svm type, 3 for epsilon-SVR
% -t kernel type, 2 for radial basis function
% -c cost parameter  of epsilon-SVR
% -g width parameter  for RBF kernel
% -p  for epsilon-SVR
    properties
        % svm parameters
        c            % SVM C parameter
        s
        t
        g
        e
        bias_mul     % SVM bias multiplier
        bCrossValSVM
    end
    
    methods
        function obj = RegressionLibSVM(varargin)
            opts.c = 1;
            opts.s = 3;
           %opts.t = 2;            % RBF kernel
            opts.t = 0;             % linear
            opts.g = 2;				% range of the gamma parameter
            opts.e = 0;				% range of the epsilon parameter
            
            opts.bias_mul = 1;
            opts.bCrossValSVM = false;
             
            [opts, varargin] =  vl_argparse(opts, varargin);
            obj.c = opts.c;
            obj.s = opts.s;
            obj.t = opts.t;
            obj.g = opts.g;
            obj.e = opts.e;
            obj.bias_mul = opts.bias_mul;
            obj.bCrossValSVM = opts.bCrossValSVM;
            
            % load in the model if provided
            modelstore.model = [];
            vl_argparse(modelstore, varargin);
            obj.model = modelstore.model;
        end
        
        train(obj, input, labels)              
        [pred_label, prob_mat] = test(obj, input)       
        WMat = getWMat(obj)
    end
    methods (Static=true)
        [ optparam ] = OptParameters(training_label_vector, training_instance_matrix )
        
        
    end
    
end


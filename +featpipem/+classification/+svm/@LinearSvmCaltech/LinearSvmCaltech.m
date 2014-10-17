classdef LinearSvmCaltech < handle & featpipem.classification.svm.LinearSvm
    %LIBSVM Train an SVM classifier using the LIBSVM library
    
    properties
        % svm parameters
        c            % SVM C parameter
        g            %  set gamma in kernel function
        bCrossValSVM
        bias_mul     % SVM bias multiplier
        isweight     % co tinh trong so khong (isweight=true/false)
        ratio_np     % neu isweight=false cho cac mau thi co chon mau neg/pos = 0,...
    end
    
    methods
        function obj = LinearSvmCaltech(varargin)
            opts.c = 1.0;
            opts.g = -1;
            opts.bCrossValSVM = false;
            opts.bias_mul = 1;
            opts.isweight = 0;
            opts.ratio_np = 0; 
            [opts, varargin] =  vl_argparse(opts, varargin);
            obj.c = opts.c;
            obj.g = opts.g;
            obj.bCrossValSVM = opts.bCrossValSVM;
            
            obj.bias_mul = opts.bias_mul;
            obj.isweight = opts.isweight;
            obj.ratio_np = opts.ratio_np; 
            
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
        [ac] = get_cv_ac(y,x,param,nr_fold)
        
    end
end


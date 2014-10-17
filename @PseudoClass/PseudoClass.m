classdef PseudoClass < handle
    %PseudoClass Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % storage for trained svm model
        isPreComp
        num_pseudoClass
%        filename_instance_matrix
        filename_label_vector
        scaleValue
        cValue
    
        model
        % algorithm % [ 'libsvm', 'liblinear' ] algorithm to use. libsvm is default
        solvertype
        kerneltype %: [ 'linear' | {'rbf'} ], SVM kernel to use. 'rbf' is default.
        svmtype %: [ {'epsilon-svr'} | 'nu-svr' ] Type of SVM to apply. The default is 'epsilon-svr' for regression.
        %probabilityestimates %: [0| {1} ], whether to train the SVR model for probability estimates, 0 or 1 (default 1)"
        %cvtimelimit: Set a time limit (seconds) on individual cross-validation sub-calculation when searching over supplied SVM parameter ranges for optimal parameters. Only relevant if parameter ranges are used for SVM parameters such as cost, epsilon, gamma or nu. Default is 10;
        %splits : Number of subsets to divide data into when applying n-fold cross validation. Default is 5.
        %gamma: Value(s) to use for LIBSVM kernel gamma parameter. Default is 15 values from 10^-6 to 10, spaced uniformly in log.
        %cost: Value(s) to use for LIBSVM 'c' parameter. Default is 11 values from 10^-3 to 100, spaced uniformly in log.
        %epsilon: Value(s) to use for LIBSVM 'p' parameter (epsilon in loss function). Default is the set of values [1.0, 0.1, 0.01].
        %nu: Value(s) to use for LIBSVM 'n' parameter (nu of nu-SVC, and nu-SVR). Default is the set of values [0.2, 0.5, 0.8].
    end
    
    methods
		% Constructor
		function obj = PseudoClass(varargin)		
            obj.solvertype = 'libsvm';
            obj.kerneltype = 'linear';
            obj.svmtype = 'epsilon-svr';
            obj.model = [];
            obj.isPreComp = true;
            obj.num_pseudoClass = 500;
         %   obj.filename_instance_matrix ='';
            obj.filename_label_vector = '';
            obj.scaleValue =1;
            obj.cValue=1;
            
        end
        
        [ conf ] = Init(obj,conf)
		%[ conf ] =  Train(obj,conf )	
        [ conf ] =  Train(obj,conf,ci_start,ci_end)
        [ conf ] =  Train_Train(obj,conf,ci_start,ci_end)        
		[ conf ] = Test(obj,conf,ci_start,ci_end)
        [ conf ] = Test2(obj,conf)
        [ conf ] = Test3(obj,conf)
        [ conf ] = Test4(obj,conf)
        [ conf ] = Test5(obj,conf)
        [ conf ] = Compose(obj, conf )
        [ conf ] = ComposeOnVal(obj, conf );
        [ conf ] = Compose_SV(obj, conf );
        [ conf ] = Compose_U(obj, conf );
    end
	methods (Static=true)

        
        
    end
    
    
end


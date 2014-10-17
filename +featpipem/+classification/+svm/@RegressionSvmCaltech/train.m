function train(obj, input, labels)
%TRAIN Testing function for LIBSVM
%   Refer to GenericSVM for interface definition

% matlab> model = svmtrain(training_label_vector, training_instance_matrix, [,'libsvm_options']);
% 
%         -training_label_vector:
%             An m by k vector of training labels.
%         -training_instance_matrix:
%             An m by n matrix of m training instances with n features.
%             It can be dense or sparse.

 
    
    num_classes =  size(labels,2);

    % ensure input is of correct form
    if ~issparse(input)
        input = sparse(double(input));
    end
    
    
    % prepare temporary output model storage variables
    libsvm = cell(num_classes,1);
     
    % train models for each class in turn
    % ‘-s 3 -t 2 -c 20 -g 64 -p 1’
     % param = sprintf(' -q -s 3 -t 0 -b 1 -c %f', obj.c);
    %param = ' -q -c 1 -g 0.2 -b 1';
    bCrossValSVM = false; %obj.bCrossValSVM;   
    training_instance_matrix = input;
    C= obj.c;
    for ci=1:num_classes     
        training_label_vector = labels(:,ci);        
            if bCrossValSVM                 
                param.s = 3; 					% epsilon SVR
                %param.C = max(trn_data.y) - min(trn_data.y);	% FIX C based on Equation 9.61
               % param.C = max(training_label_vector) - min(training_label_vector);	% FIX C based on Equation 9.61
                param.C = C;
                %param.t = 2; 					% RBF kernel
                param.t = 0;   % linear
                param.cset = -5:5;	
                param.gset = 2.^[-7:7];				% range of the gamma parameter
                param.eset = [0:5];				% range of the epsilon parameter
                param.nfold = 5;				% 5-fold CV
                numLog2c = length(param.cset);
                
                     
                Rval = zeros(length(param.gset), length(param.eset));
                 
                for i = 1:param.nfold
                    % partition the training data into the learning/validation
                    % in this example, the 5-fold data partitioning is done by the following strategy,
                    % for partition 1: Use samples 1, 6, 11, ... as validation samples and
                    %			the remaining as learning samples
                    % for partition 2: Use samples 2, 7, 12, ... as validation samples and
                    %			the remaining as learning samples
                    %   :
                    % for partition 5: Use samples 5, 10, 15, ... as validation samples and
                    %			the remaining as learning samples

                   
                    data = [ training_label_vector, training_instance_matrix];
                    [learn, val] = k_FoldCV_SPLIT(data, param.nfold, i);
                    lrndata.X = learn(:, 2:end);
                    lrndata.y = learn(:, 1);
                    valdata.X = val(:, 2:end);
                    valdata.y = val(:, 1);

            
    
   
%                     for ici = 1:numLog2c
%                         log2c = log2c_list(ici);
%                         param.C = 2^log2c;
%                         
                        for j = 1:length(param.gset)
                            param.g = param.gset(j);

                            for k = 1:length(param.eset)
                                param.e = param.eset(k);
                                param.libsvm = [' -q -s ', num2str(param.s), ' -t ', num2str(param.t), ...
                                        ' -c ', num2str(param.C), ' -g ', num2str(param.g), ...
                                        ' -p ', num2str(param.e)];

                                % build model on Learning data
                                model = svmtrain(lrndata.y, lrndata.X, param.libsvm);

                                % predict on the validation data
                                [y_hat, Acc, projection] = svmpredict(valdata.y, valdata.X, model, '-q');

                                Rval(j,k) = Rval(j,k) + mean((y_hat-valdata.y).^2);
                            end
                        end
%                     end

                end

                Rval = Rval ./ (param.nfold);
                % % Select the parameters (with minimum validation error)
                [v1, i1] = min(Rval);
                [v2, i2] = min(v1);
                optparam = param;
                optparam.g = param.gset( i1(i2) );
                optparam.e = param.eset(i2);
            
             else
                 
                optparam.s = 3; 					% epsilon SVR
                %param.C = max(trn_data.y) - min(trn_data.y);	% FIX C based on Equation 9.61
                optparam.C = C; %max(training_label_vector) - min(training_label_vector);	% FIX C based on Equation 9.61
                %optparam.t = 2; 					% RBF kernel
                optparam.t = 0;             % linear
                optparam.g = 2;				% range of the gamma parameter
                optparam.e = 0;				% range of the epsilon parameter
                
             end
             
              % Train the selected model using all training samples
              %  optparam.libsvm = [' -q -s ', num2str(optparam.s), ' -t ', num2str(optparam.t)];
                optparam.libsvm = [' -q -s ', num2str(optparam.s), ' -t ', num2str(optparam.t), ...
                        ' -c ', num2str(optparam.C), ' -g ', num2str(optparam.g), ...
                        ' -p ', num2str(optparam.e)];      
                optparam.libsvm = ' -q -s 3 -t 0 ';   
                fprintf('\nLearning model %d with option=%s',ci,optparam.libsvm);
                libsvm{ci} = svmtrain(training_label_vector, training_instance_matrix, optparam.libsvm);
                
%                 libsvmnoption = [' -q -s 3 -t 2 -c ',num2str(C) ' -g 2 '];
%                  fprintf('\noption=%s',libsvmnoption);
%                 libsvm{ci} = svmtrain(training_label_vector, training_instance_matrix, libsvmnoption);
        
    end
    
    % copy across trained model
    obj.model = struct;
    obj.model.libsvm = libsvm;
    
     fprintf('\nLearning models is finish !\n');
end


function train(obj, input, labels)
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
     
    bCrossValSVM = obj.bCrossValSVM;   
    training_instance_matrix = input;
    
   %libsvm_options_fix = [' -q -s ', num2str(obj.s), ' -t ', num2str(obj.t), ' -c ', num2str(obj.c), ' -g ', num2str(obj.g), ' -p ', num2str(obj.e)]; 
   libsvm_options_fix = [' -q -s ', num2str(obj.s), ' -t ', num2str(obj.t) ];
    parfor ci=1:num_classes      
    %for ci=1:num_classes     
            training_label_vector = labels(:,ci);        
            if bCrossValSVM                 
                optparam =  featpipem.classification.svm.RegressionLibSVM.OptParameters( training_label_vector, training_instance_matrix );
                libsvm_options = optparam.libsvm;     
            else 
                libsvm_options = libsvm_options_fix;
            end
            fprintf('\nLearning model %d with option=%s',ci,libsvm_options);
            libsvm{ci} = svmtrain(training_label_vector, training_instance_matrix, libsvm_options);                
    end
    
    % copy across trained model
    obj.model = struct;
    obj.model.libsvm = libsvm;
    
     fprintf('\nLearning models is finish !\n');
end


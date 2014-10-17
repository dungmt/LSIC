function train_fix(obj, input, labels)
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
%     bCrossValSVM = obj.bCrossValSVM;   
     training_instance_matrix = input;
%     C= obj.c;
    parfor ci=1:num_classes     
        training_label_vector = labels(:,ci);        
        optparam = ' -q -s 3 -c 3.8 -t 0 -g 0.3125 -p 0';   
        fprintf('\nLearning model %d with option=%s',ci,optparam);
        libsvm{ci} = svmtrain(training_label_vector, training_instance_matrix, optparam);
        
    end
    
    % copy across trained model
    obj.model = struct;
    obj.model.libsvm = libsvm;
    
     fprintf('\nLearning models is finish !\n');
end


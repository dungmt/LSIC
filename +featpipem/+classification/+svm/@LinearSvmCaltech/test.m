function [pred_label, prob_mat] = test(obj, input)
%TEST Training function for LIBSVM
% -testing_label_vector:
%             An m by 1 vector of prediction labels. If labels of test
%             data are unknown, simply use any random values.
%         -testing_instance_matrix:
%             An m by n matrix of m testing instances with n features.
%             It can be dense or sparse.

    % ensure a model has been trained
    if isempty(obj.model)
        error('A SVM model has yet to be trained');
    end
    
    % ensure input is of correct form
    if ~isa(input,'double')
        input = sparse(double(input));
    end
    
    % prepare output matrix
    %%% scoremat = zeros(length(obj.model.libsvm), size(input,1));
    numTest = size(input,1);
    numLabels = length(obj.model.libsvm);
    prob_mat = zeros(numTest,numLabels);
    % test models for each class in turn
    for ci = 1: numLabels
   
   % for ci = 1: numLabels
        %%% [scorevec, scorevec, scorevec] =    svmpredict(zeros(size(input,1),1), input, obj.model.libsvm{ci}); %#ok<ASGLU>
        
        % For probabilities, each row contains k values indicating the probability 
        % that the testing instance is in each class. The order of classes here is 
        % the same as 'Label' field in the model structure.
        [predicted_label, accuracy, prob_estimates]=    svmpredict(zeros(size(input,1),1), input, obj.model.libsvm{ci},'-b 1 -q'); %#ok<ASGLU>
         prob_mat(:,ci) = prob_estimates(:,obj.model.libsvm{ci}.Label==1);
         
      %%%   if obj.model.libsvm_flipscore(ci)
      %%%      scorevec = -scorevec;
      %%%   end
      %%%   scoremat(ci,:) = scorevec';
    end
    
     %%%[est_label, est_label] = max(scoremat, [], 1); %#ok<ASGLU>
    
     %# predict the class with the highest probability
    [~,pred_label] = max(prob_mat,[],2); % index of column whose value is max of each row
        
end


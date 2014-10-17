function [pred_label, prob_mat] = test(obj, input)
%TEST Training function for LIBSVM
% -testing_label_vector:
%             An m by 1 vector of prediction labels. If labels of test
%             data are unknown, simply use any random values.
%         -testing_instance_matrix:
%             An m by n matrix of m testing instances with n features.
%             It can be dense or sparse.
% Input arguments
% tstY
% This is a  dimensional vector of the test data response values, 
% where  is the total number of samples.
% tstX
% This is a  dimensional test data input matrix, 
% where  is the total number of samples and  is the number of features for each sample.
% model
% This is the trained SVM model obtained using the svmtrain interface, 
% which can be used to obtain the prediction outputs on a test data sample.
% Output
% y_hat
% This is the  dimensional predicted response value of the test data samples tstX.
% Acc
% This is the mean squared error for the test data.

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
   % parfor ci = 1: numLabels
   libsvm = obj.model.libsvm;
    parfor ci = 1: numLabels
        %%% [scorevec, scorevec, scorevec] =    svmpredict(zeros(size(input,1),1), input, obj.model.libsvm{ci}); %#ok<ASGLU>
        
        % For probabilities, each row contains k values indicating the probability 
        % that the testing instance is in each class. The order of classes here is 
        % the same as 'Label' field in the model structure.
      %%%  [predicted_label, accuracy, prob_estimates]=    svmpredict(zeros(size(input,1),1), input, obj.model.libsvm{ci},'-b 1'); %#ok<ASGLU>
         [predicted_label, accuracy, prob_estimates]=    svmpredict(zeros(size(input,1),1), input, libsvm{ci}, '-q'); %#ok<ASGLU>
         
        %%% prob_mat(:,ci) = prob_estimates(:,obj.model.libsvm{ci}.Label==1);
         prob_mat(:,ci) = prob_estimates;
         
      %%%   if obj.model.libsvm_flipscore(ci)
      %%%      scorevec = -scorevec;
      %%%   end
      %%%   scoremat(ci,:) = scorevec';
    end
    
     %%%[est_label, est_label] = max(scoremat, [], 1); %#ok<ASGLU>
    
     %# predict the class with the highest probability
    [~,pred_label] = max(prob_mat,[],2); % index of column whose value is max of each row
        
end


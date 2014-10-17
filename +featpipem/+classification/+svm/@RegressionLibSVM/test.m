function [pred_label, prob_mat] = test(obj, input)

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
    libsvm = obj.model.libsvm;
    parfor ci = 1: numLabels
         [predicted_label, accuracy, prob_estimates]=    svmpredict(zeros(size(input,1),1), input, libsvm{ci}, '-q'); %#ok<ASGLU>
         prob_mat(:,ci) = prob_estimates;
    end
     %# predict the class with the highest probability
    [~,pred_label] = max(prob_mat,[],2); % index of column whose value is max of each row        
end


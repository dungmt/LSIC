function [predicted_label, accuracy, decision_values,vote_matrix] = MyPredictOVA(solver,testing_label_vector, testing_instance_matrix, model)
% MyPredict: Predicting...
%   label_vector_test: 1x n_item
%   instance_matrix_test: n_item x demension

    if size(testing_label_vector,1) < size(testing_label_vector,2) 
        testing_label_vector = testing_label_vector';
    end
    num_samples = size(testing_label_vector,1);
    unique_label_vector = unique(testing_label_vector);   
    num_classes = length( unique_label_vector);
    
        fprintf('\n MyPredict: Predicting...');
        switch solver
            case 'libsvm' 
                if size(testing_instance_matrix,1) ~= num_samples
                    testing_instance_matrix = testing_instance_matrix';
                end
                [predicted_label, accuracy, decision_values]= svmpredict(testing_label_vector, testing_instance_matrix, model,'-b 1');
            case 'liblinear'
                if size(testing_instance_matrix,1) ~= num_samples
                    testing_instance_matrix = testing_instance_matrix';
                end
                num_model_1 =  num_classes*(num_classes-1)/2;
                num_model=length(model);
                assert(num_model==num_model_1);
                vote_matrix = zeros(num_classes,num_samples);
                 if ~issparse(testing_instance_matrix)
                    testing_instance_matrix = sparse(testing_instance_matrix);
                end
                k=1;
                for ci=1: num_classes-1
                    for cj=ci+1: num_classes    
                        model_k = model{k}; k=k+1;
                        TestLabel =  2 * (testing_label_vector==ci) - 1 ;                         
                        [predicted_label, accuracy, decision_values] = predict(TestLabel, testing_instance_matrix, model_k, '-b 1');
                        index_ci = find(predicted_label== model_k.Label(1));
                        index_cj = find(predicted_label== model_k.Label(2));
                        vote_matrix(ci,index_ci) = vote_matrix(ci,index_ci)+1;
                        vote_matrix(cj,index_cj) = vote_matrix(cj,index_cj)+1;
                    end
                end
                [~,predicted_label] = max(vote_matrix,[],1);
                
                [Confusion,~] = confusionmat(testing_label_vector,predicted_label);
                n_classes = size(Confusion,1);
                assert(num_classes==n_classes);

                num_predicted_true = sum(diag(Confusion));
                accuracy = num_predicted_true / sum(sum(Confusion));
    
              
                decision_values=0;
                
            case {'sgd', 'sdca'}
                % --------------------------------------------------------------------
                %                                                  Compute feature map
                % --------------------------------------------------------------------
             %   fprintf('\n Compute feature map');
               % psix = vl_homkermap(instance_matrix_test, 1, 'kchi2', 'gamma', .5) ;

                % --------------------------------------------------------------------
                %                                                Test SVM and evaluate
                % --------------------------------------------------------------------
                 fprintf('\n Estimate the class of the test images');
                  % Estimate the class of the test images
                  scores = model.w' * testing_instance_matrix + model.b' * ones(1,size(testing_instance_matrix,2)) ;
                  classes = unique(testing_label_vector);
                   if length(classes)>2
                        [drop, predicted_label] = max(scores, [], 1) ;
                        decision_values = scores;

                        if size(predicted_label,1) < size(predicted_label,2)
                            predicted_label = predicted_label';
                        end
        %                 predict_tmp = zeros(size(scores));
        %                 predict_tmp(find(scores>=0))= 1 ;
        %                 predict_tmp=predict_tmp';
                        accuracy = sum(predicted_label==testing_label_vector)/length(testing_label_vector)           
                   else
                        predicted_label_idx= find(scores>0);
                        prob_estimates = zeros(length(testing_label_vector),2);
                        for i=1:length(testing_label_vector)
                            prob_estimates(i,1)=1.0/(1+exp(-scores(i)));
                            % for binary classification
                            prob_estimates(i,2)=1.-prob_estimates(i,1);
                        end
                        decision_values = prob_estimates;
                        predicted_label = -ones(size(scores));
                        predicted_label(predicted_label_idx)= 1 ;
                        predicted_label=predicted_label';
                        accuracy = sum(predicted_label==testing_label_vector)/length(testing_label_vector)  
           end
        end
        fprintf('\n MyPredict: finished !');
    end


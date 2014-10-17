function [model] = MyTrainOVO(solver,training_label_vector, training_instance_matrix, libsvmoption)
% MyTrain: Traing ning classifier...
%   label_vector_test: n_itemx1
%   instance_matrix_test: n_item x demension


    if size(training_label_vector,1) < size(training_label_vector,2) 
        training_label_vector = training_label_vector';
    end
   % whos 
%pause
    fprintf('\n MyTrain:Training...');
        
           
   unique_label_vector = unique(training_label_vector);   
   num_classes = length( unique_label_vector);
   num_samples = size(training_label_vector,1);     
   
   fprintf('\n\t MyTrain: num_classes: %d',num_classes);
   fprintf('\n\t MyTrain: num_samples: %d',num_samples);
  
        switch solver
            case 'libsvm'
                if size(training_instance_matrix,1) ~= num_samples
                    training_instance_matrix = training_instance_matrix';
                end
                model = svmtrain(training_label_vector, sparse(training_instance_matrix), libsvmoption);                
                 
            case 'liblinear'                
                fprintf('\n\t Dinh dang du lieu ');
                if size(training_instance_matrix,1) ~= num_samples
%                     error('\n\tsize(training_instance_matrix,1) ~= num_samples');
                    training_instance_matrix = training_instance_matrix';
                end
%                 if ~isdouble(training_instance_matrix)
%                     training_instance_matrix = double(training_instance_matrix);
%                 end
                if ~issparse(training_instance_matrix)
                    printf('\n\t sparsing training_instance_matrix...');
                    training_instance_matrix = sparse(training_instance_matrix);
                end
%                     model = train(training_label_vector, sparse(training_instance_matrix),libsvmoption,'col');
%                 else               
%                     model = train(training_label_vector, sparse(training_instance_matrix),libsvmoption);
%                 end
                    num_model =  num_classes*(num_classes-1)/2;
                    model = cell(num_model,1);
                    k=1;
                    for ci=1: num_classes-1
                        for cj=ci+1: num_classes    
                            index_label_ci = find(training_label_vector==ci);
                            index_label_cj = find(training_label_vector==cj);
                            
                            num_item_ci = length(index_label_ci);
                            num_item_cj = length(index_label_cj);
                            
                            assert( num_item_ci>0);
                            assert( num_item_cj>0);
                           
                            trainLabel= ones(num_item_ci+num_item_cj,1);
                            trainLabel(num_item_ci+1: num_item_ci+num_item_cj,1)=-1;
                            trainData = zeros(num_item_ci+num_item_cj, size(training_instance_matrix,2));
                            trainData(1:num_item_ci,:) = training_instance_matrix(index_label_ci,:);
                            trainData(num_item_ci+1:num_item_ci+num_item_cj,:) = training_instance_matrix(index_label_cj,:);                           
                            fprintf('\n\t\t Training mode %d ci=%d cj=%d',k,ci,cj);
                            model{k} = train(trainLabel, sparse(trainData), libsvmoption);
                            k=k+1;
                        end
                    end
                    %model = train(training_label_vector, training_instance_matrix,libsvmoption);
                    
                    
            case {'sgd', 'sdca'}
                    % --------------------------------------------------------------------
                    %                                                  Compute feature map
                    % --------------------------------------------------------------------
                   % psix = vl_homkermap(instance_matrix, 1, 'kchi2', 'gamma', .5) ;
                    
%                     psix = instance_matrix ; 
%                     lambda = 1 / (conf.svm.C *  length(label_vector)) ;  
                    lambda = 0.01 ; % Regularization parameter
%                     maxIter = 50/lambda ; %1000 ; % Maximum number of iterations
%                     [model.w,model.b, model.info] = vl_svmtrain(training_instance_matrix , training_label_vector, lambda,'Solver', solver);
%                     [model.w,model.b, model.info] = vl_svmtrain(training_instance_matrix , training_label_vector, lambda, ...%                      
%                       'MaxNumIterations', maxIter, ...
%                       'Epsilon', 1e-3);
%                   model.b = conf.svm.biasMultiplier * model.b;

            
                  classes  =  unique(training_label_vector);%                   
                  n_samples = length(training_label_vector);
                  n_classes = length(classes)   ;
                  if n_classes >2
                      w = [] ;
                      classes = sort(classes);
                      parfor ci = 1:n_classes                
%                         ci = classes(i);                                         
                        fprintf('\n\t\t Training model for class %d / %d', ci,n_classes ) ;                        
%                         selTrain = find(training_label_vector==ci);   
%                         y = -ones(n_samples,1);
%                         y(selTrain,1)=1;                         
                         y = 2 * (training_label_vector==ci) - 1 ;                        
                        [w(:,ci), b(ci), info(ci)] = vl_svmtrain(training_instance_matrix, y,  lambda,'Solver', solver);
    %                       'Solver', conf.svm.solver, ...
    %                       'MaxNumIterations', 50/lambda, ...
    %                       'BiasMultiplier', conf.svm.biasMultiplier, ...
    %                       'Epsilon', 1e-3);
                      end    
                      model.b = b ;
                      model.w = w ;
                      model.info = info ;
                  else
                      [model.w,model.b, model.info] = vl_svmtrain(training_instance_matrix , training_label_vector, lambda,'Solver', solver);
                  end

                  
                   
        end
end
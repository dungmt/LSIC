function train(obj, input, labels)

    % convenience variables
    classes = unique(labels);
    num_classes = length(classes);
    %feat_dim = size(input,1);
    feat_count = size(input,1);

    % ensure input is of correct form
    if ~issparse(input)
        input = sparse(double(input));
    end
    
    % prepare temporary output model storage variables
    libsvm = cell(num_classes,1);
    libsvm_flipscore = zeros(1,num_classes);

    
    % train models for each class in turn

    if(obj.g== -1) 
      libsvm_options_fix = [' -q -b 1 -t 0 -c ', num2str(obj.c)];  
    else
      libsvm_options_fix = [' -q -b 1 -t 0 -c ', num2str(obj.c), ' -g ', num2str(obj.g)];  
    end
    
    %param = ' -q -c 1 -g 0.2 -b 1';
    isweight = obj.isweight;
    ratio_np = obj.ratio_np;
  %  training_instance_matrix = input;
  % so nhan co the khong la {1,2...} ma co the nhan mang gia tri bat ky
   
   bCrossValSVM = obj.bCrossValSVM;
   % parfor k = 1:num_classes
   
   
    parfor ci=1:num_classes
        k= classes(ci);
            fprintf('Learning model %d ....', k);            
            %options = param;
            options='';
            tic;
            % deal with unbalanced data
            num_pos = sum(labels == k);
            num_neg = sum(labels ~= k);
            ratio = num_pos / num_neg;
            
            pos_training_label_vector = find(labels==k);
            neg_training_label_vector = setdiff((1:length(labels)), pos_training_label_vector);
                
            tmpp_num_neg = length(neg_training_label_vector);
            tmpp_num_pos = length(pos_training_label_vector);
                
           % svm_training_label_vector       = training_label_vector(pos_training_label_vector);
            svm_training_label_vector       = ones(tmpp_num_pos,1);
            svm_training_instance_matrix    = input(pos_training_label_vector,:);
  
                
            
            if isweight
                % one vs all               
                % deal with unbalanced set if the ratio is larger than 2                
                % -wi weight : set the parameter C of class i to weight*C, for C-SVC (default 1)\n
                 if ratio > 2
                   options = sprintf(' -w-1 %f -w1 1',  ratio);
                 elseif 1/ratio > 2
                   options = sprintf(' -w-1 1 -w1 %f ',  1/ratio);
                 end
                %ModelSVM{k} = svmtrain(double(training_label_vector==k), double(training_instance_matrix), options);
                labels_tmp =  -1+0*labels(neg_training_label_vector,:);
                svm_training_label_vector       = cat(1,svm_training_label_vector,   labels_tmp   );              
                svm_training_instance_matrix    = cat(1,svm_training_instance_matrix, input(neg_training_label_vector,:) );
                
           % elseif strcmp(selectNegSample,'random')    
            elseif ratio_np ~=0
              
                tmpp_ratio = tmpp_num_neg/ tmpp_num_pos ;
                
                if( tmpp_ratio > ratio_np)                
                    tmpp_num_images_negative = tmpp_num_pos* ratio_np;
                    %chon ngau nhien
                    rand_indices = randperm(tmpp_num_neg); 
                    rand_indices_tmp = rand_indices(1:tmpp_num_images_negative);   
                    labels_tmp =  -1+0*labels(rand_indices_tmp,:);
                    svm_training_label_vector       = cat(1,svm_training_label_vector,   labels_tmp   );
                    svm_training_instance_matrix    = cat(1,svm_training_instance_matrix,   input(rand_indices_tmp,:) );
                    fprintf('(pos:%d - neg: %d)',tmpp_num_pos, tmpp_num_images_negative);
                    options = sprintf(' -w-1 1 -w1 %f',  ratio_np);
                else 
                    labels_tmp =  -1+0*labels(neg_training_label_vector,:);
                    svm_training_label_vector       = cat(1,svm_training_label_vector,   labels_tmp   );                    
                    
                    svm_training_instance_matrix    = cat(1,svm_training_instance_matrix,   input(neg_training_label_vector,:) );
                    
                    if ratio > 2
                        options = sprintf(' -w-1 %f -w1 1',  ratio);
                    elseif 1/ratio > 2
                        options = sprintf(' -w-1 1 -w1 %f ',  1/ratio);
                    end
                end
            else
                labels_tmp =  -1+0*labels(neg_training_label_vector,:);
                svm_training_label_vector       = cat(1,svm_training_label_vector,   labels_tmp   );
                svm_training_instance_matrix    = cat(1,svm_training_instance_matrix, input(neg_training_label_vector,:) );
            end
         
          if bCrossValSVM
               % tinh tham so toi uu cho class
               optparam  =  featpipem.classification.svm.LinearSvmCaltech.OptParameters( double(svm_training_label_vector), double(svm_training_instance_matrix) );
               libsvm_options = [' -q -t 0 -b 1', ' -c ', num2str(optparam.c), ' -g ', num2str(optparam.g)]; 
               libsvm_options = sprintf('%s%s',libsvm_options,options);
          else              
               libsvm_options = sprintf('%s%s',libsvm_options_fix,options);
          end
          
          
            fprintf('(options=%s)',libsvm_options);
            libsvm{ci} = svmtrain(double(svm_training_label_vector), double(svm_training_instance_matrix), libsvm_options);   
            fprintf(' finish (%f seconds) !\n', toc);
        
            % in single class classification, first label encountered is
            % assigned to +1, so if the opposite is true in the label set,
            % set a flag in the libsvm struct to indicate this
            libsvm_flipscore(ci) = (svm_training_label_vector(1) == -1);
    end
    
    % copy across trained model
    obj.model = struct;
    obj.model.libsvm = libsvm;
    obj.model.libsvm_flipscore = libsvm_flipscore;
    
    % apply bias multiplier if required
    if obj.bias_mul ~= 1
        for i = 1:length(obj.model.libsvm)
            obj.model.libsvm{i}.rho = ...
                obj.bias_multiplier*obj.model.libsvm{i}.rho;
        end
    end
    fprintf('Learning models is finish !\n');
end


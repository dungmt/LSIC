function [ optparam ] = OptParameters( training_label_vector, training_instance_matrix )
    if ~issparse(training_instance_matrix)
                training_instance_matrix = sparse(double(training_instance_matrix));
    end
    disp('Performing model selection....');
                param.s = 3; 					% epsilon SVR
                %param.C = max(trn_data.y) - min(trn_data.y);	% FIX C based on Equation 9.61
                param.C = max(training_label_vector) - min(training_label_vector);	% FIX C based on Equation 9.61
               % param.c = 1;
                %param.t = 2; 					% RBF kernel
                param.t = 0;                    % linear
                param.cset = -5:5;              % SVM C parameter
                param.gset = 2.^[-7:7];			% range of the gamma parameter
                param.eset = 0:5;				% range of the epsilon parameter
                param.nfold =1; % 5;				% 5-fold CV
                numLog2c = length(param.cset);
                
                     
                Rval = zeros(length(param.gset), length(param.eset));
                 
                for i = 1:param.nfold
                    fprintf('\n data = [ training_label_vector, training_instance_matrix]');
                    data = [ training_label_vector, training_instance_matrix];
                    fprintf('\n [learn, val] = k_FoldCV_SPLIT(data, param.nfold, i)=%d,%d',param.nfold, i);
                    [learn, val] = k_FoldCV_SPLIT(data, param.nfold, i);
                    lrndata.X = learn(:, 2:end);
                    lrndata.y = learn(:, 1);
                    valdata.X = val(:, 2:end);
                    valdata.y = val(:, 1);
   
%                      for ici = 1:numLog2c
%                          log2c = log2c_list(ici);
%                          param.C = 2^log2c;
                         
                        for j = 1:length(param.gset)
                            param.g = param.gset(j);

                            for k = 1:length(param.eset)
                                param.e = param.eset(k);
                                
                                param.libsvm = [' -q -s ', num2str(param.s), ' -t ', num2str(param.t), ...
                                        ' -c ', num2str(param.C), ' -g ', num2str(param.g), ...
                                        ' -p ', num2str(param.e)]
%                                 pause;
%                                 lrndata.y
%                                 pause;
                                % build model on Learning data
                                model = svmtrain(lrndata.y, lrndata.X, param.libsvm);

                                % predict on the validation data
                                [y_hat, Acc, projection] = svmpredict(valdata.y, valdata.X, model, '-q');

                                Rval(j,k) = Rval(j,k) + mean((y_hat-valdata.y).^2);
                                fprintf('.');
                            end
                        end
%                      end
                end

                Rval = Rval ./ (param.nfold);
                % % Select the parameters (with minimum validation error)
                [v1, i1] = min(Rval);
                [v2, i2] = min(v1);
                optparam = param;
                optparam.g = param.gset( i1(i2) );
                optparam.e = param.eset(i2);
                optparam.libsvm = [' -q -s ', num2str(optparam.s), ' -t ', num2str(optparam.t), ...
                                        ' -c ', num2str(optparam.C), ' -g ', num2str(optparam.g), ...
                                        ' -p ', num2str(optparam.e)]
                
    disp('finish !');
end


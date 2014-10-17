
function [ optparam ] = OptParameters( training_label_vector, training_instance_matrix )
    if ~issparse(training_instance_matrix)
                training_instance_matrix = sparse(double(training_instance_matrix));
    end
    disp('Performing model selection....');
% This function assist you to obtain the parameters C (c) and gamma (g)
% automatically.
% https://github.com/Abusamra/LIBSVM-multi-classification/blob/master/src/automaticParameterSelection.m
% INPUT:
% trainLabel: An Nx1 vector denoting the label for each observation
% trainData: An N x D matrix denoting the feature/data matrix
% Ncv: A scalar representing Ncv-fold cross validation for parameter
% selection. Note that this function does not require the user to specify
% the run number for each iteration because it automatically assigns the run
% number in the code "get_cv_ac.m" (from the svmlib).
% option: options for parameters selecting
%
% OUTPUT:
% bestc: A scalar denoting the best value for C
% bestg: A scalar denoting the best value for g
% bestcv: the best accuracy calculated from the train data set

% #######################
% Automatic Cross Validation 
% Parameter selection using n-fold cross validation
% #######################
[N, D] = size(training_instance_matrix);

if nargin>3
    stepSize = option.stepSize;
    bestLog2c = log2(option.c);
    bestLog2g = log2(option.gamma);
    epsilon = option.epsilon;
    Nlimit = option.Nlimit;
    svmCmd = option.svmCmd;
else
    stepSize = 5;
    bestLog2c = 0;
    bestLog2g = log2(1/D);
    epsilon = 0.005;
    Ncv = 3; % Ncv-fold cross validation cross validation
    Nlimit = 100;
    svmCmd = '';
end

% initial some auxiliary variables
bestcv = 0;
deltacv = 10^6;
cnt = 1;
breakLoop = 0;

while abs(deltacv) > epsilon && cnt < Nlimit
    bestcv_prev = bestcv;
    prevStepSize = stepSize;
    stepSize = prevStepSize/2;
    log2c_list = bestLog2c-prevStepSize: stepSize: bestLog2c+prevStepSize;
    log2g_list = bestLog2g-prevStepSize: stepSize: bestLog2g+prevStepSize;
    
    numLog2c = length(log2c_list);
    numLog2g = length(log2g_list);
    
    for i = 1:numLog2c
        log2c = log2c_list(i);
        for j = 1:numLog2g
            log2g = log2g_list(j);
            % With some precal kernel
            cmd = ['-q -t 0 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g),' ',svmCmd];
            cv =  featpipem.classification.svm.LinearSvmCaltech.get_cv_ac(training_label_vector, training_instance_matrix, cmd, Ncv);
            if (cv >= bestcv),
                bestcv = cv; bestLog2c = log2c; bestLog2g = log2g;
                bestc = 2^bestLog2c; bestg = 2^bestLog2g;
            end
        %    disp(['So far, cnt=',num2str(cnt),' the best parameters, yielding Accuracy=',num2str(bestcv*100),'%, are: C=',num2str(bestc),', gamma=',num2str(bestg)]);
            % Break out of the loop when the cnt is up to the condition
            if cnt >= Nlimit, breakLoop = 1; break; end
            cnt = cnt + 1;
            fprintf('.');
        end
        if breakLoop == 1, break; end
    end
    if breakLoop == 1, break; end
    deltacv = bestcv - bestcv_prev;
    
end
% disp(['The best parameters, yielding Accuracy=',num2str(bestcv*100),'%, are: C=',num2str(bestc),', gamma=',num2str(bestg)]);
optparam.c = bestc;
optparam.g = bestg;

fprintf('finish\n');
end


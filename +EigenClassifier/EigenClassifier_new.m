function conf = EigenClassifier_new(conf, start_Idx,end_Idx, step,optionR,approach, isAdd1, OptEigs)
% EigenClassifier
% switch of optionR 
%   0: R = response matrix
%   1: R = Max(response matrix)
%   2: R = ground truth label
%   3: R = merge(response matrix, ground truth)

% switch of approach 
%   31: Two step approach
%   32: Joint optimization
%   321: Joint optimization with High dimension feature vectors
%   322: Joint optimization with old V
%   33: Kernel extension
%   34: Formulation as classification problem

% isAdd1: co them 1 vao cuoi ma tran feature hay khong
% OptEigs: tinh eigs Pw = lamda Q w bang cach nao
%          1: eigs(P,Q,L)
%          2: eigs(Pk,Qk,L)
%          3: eigs(Q\P,L)
%          4: eigs(Qk\Pk,L)



   fprintf('\n -----------------------------------------------');
   fprintf('\n EigenClassifier ...');
   fprintf('\n\t datasetName = %s',conf.datasetName);
   fprintf('\n\t optionR  = %d',optionR);
   fprintf('\n\t approach = %d',approach);
   fprintf('\n\t isAdd1   = %d',isAdd1 );
   fprintf('\n\t OptEigs  = %d',OptEigs);
   fprintf('\n\t ---------------------------------------');
      
    if strcmp(conf.datasetName ,'ImageCLEF2012')
        path_filename_gt_test = '/data/Dataset/imageCLEF/imageclef2012/data/test_groundtruth.mat';
        if ~exist(path_filename_gt_test,'file')
            [ground_truth_matrix ]=  imgCLEF.groundtruth_read_2012(path_filename_data,path_to_test_concepts,path_to_test_images);
            fprintf('\n Saving ground_truth_matrix into file %s ...', path_filename_gt_test);
            save(path_filename_gt_test,'ground_truth_matrix','-v7.3');
            fprintf('done !');
        else
            fprintf('\n Loading ground_truth_matrix into file %s ...', path_filename_gt_test);
            load(path_filename_gt_test);
            fprintf('done !');    
        end
        test_ground_truth_matrix = ground_truth_matrix;
    end
   %% ---------------------------------------------------------------------
   [conf] = InitRPQ(conf, optionR, approach, isAdd1, OptEigs);
   
   if exist(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach_results, 'file')
        load(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach_results);
        fprintf('\n\t Results:\n');
        arr_Acc
        arr_AP
        return;
   end  
   
   conf = CaculatingR(conf, optionR);
   [conf] = CalculatingTrainingTestingFeatureVectors(conf);
   if approach ~=31
    conf = ComputingPQPkQk(conf);
   end
   
   %% ---------------------------------------------------------------------
   if approach==31
        conf = TwoStepApproach(conf,start_Idx,end_Idx, step);
   elseif approach==32
        conf = JointOptimizationApproach(conf);        
 %% ---------------------------------------------------------------------
    elseif approach==321 % Joint optimization with High dimension feature vectors
        conf = JointOptimizationWithHighDimensionApproach(conf);
   elseif approach==322
        conf = JointOptimizationApproachOldV(conf);    
   elseif approach==33
       conf = KernelExtensionApproach(conf);
   elseif approach==34
       conf = FormulationAsClassificationProblemApproach(conf);
   end
end
function [conf] = InitRPQ(conf, optionR, approach,isAdd1, OptEigs)

    KernelType = 'linear';
    if(approach==33)
        KernelType ='kl2'; %'kl1'; %'kjs'; % 'khell'; %'kinters'; %  'kchi2';% 
    end
    conf.experiment.RPQ.kernel = KernelType;
    opt=2;
    conf.experiment.RPQ.opt = opt;
    pathToRPQTrains = conf.experiment.pathToRPQTrains; % conf.experiment.pathToBinaryClassifer
   
    if isAdd1==1
        % co them 1 vao cuoi ma tran feature hay khong
        strIsAdd1 = 'addrow1';
    else
        strIsAdd1 = 'nonrow1';
    end

    % OptEigs: tinh eigs Pw = lamda Q w bang cach nao
    if OptEigs==1
        strEigs = 'eigsPQ';
    elseif OptEigs==2
        strEigs = 'eigsPkQk';
    elseif OptEigs==3
        strEigs = 'eigsQiP';
    else 
        strEigs = 'eigsQkiPk';
    end
    
    conf.experiment.RPQ.OptEigs = OptEigs;
    conf.experiment.RPQ.isAdd1 = isAdd1;
    

    filename_training_feature             =  sprintf('%s.%s.Strain.%s.mat',conf.datasetName,conf.experiment.RPQ.kernel,strIsAdd1);
    filename_testing_feature              =  sprintf('%s.%s.Stest.%s.mat',conf.datasetName,conf.experiment.RPQ.kernel,strIsAdd1);
    filename_QQk                            =  sprintf('%s.%s.QQk.%s.mat',conf.datasetName,conf.experiment.RPQ.kernel,strIsAdd1);
    
    filename_S_svds             =  sprintf('%s.S.svds.mat',conf.datasetName);
    filename_US                 =  sprintf('%s.US.Opt%d.mat',conf.datasetName,opt);
    filename_R                  =  sprintf('%s.R%d.mat',conf.datasetName,optionR);
    
    str_prefix = sprintf('%s.%s',conf.datasetName,KernelType);
    filename_RPPk                        =  sprintf('%s.R%dPPk.%s.mat',str_prefix,optionR,strIsAdd1);
    filename_RPQPkQk_eigen_approach         =  sprintf('%s.R%dPQPkQk.eigs.app%d.%s.%s.mat',str_prefix,optionR,approach,strIsAdd1,strEigs);
    filename_RPQPkQk_eigen_approach_results =  sprintf('%s.R%dPQPkQk.eigs.app%d.%s.%s.results.mat',str_prefix,optionR,approach,strIsAdd1,strEigs);
     
    conf.experiment.RPQ.path_filename_training_feature        = fullfile(pathToRPQTrains,   filename_training_feature)  ;
    conf.experiment.RPQ.path_filename_testing_feature        = fullfile(pathToRPQTrains,    filename_testing_feature)  ;
    conf.experiment.RPQ.path_filename_QQk             = fullfile(pathToRPQTrains,    filename_QQk)  ;
    conf.experiment.RPQ.path_filename_S_svds        = fullfile(pathToRPQTrains,    filename_S_svds)  ;
    conf.experiment.RPQ.path_filename_US            = fullfile(pathToRPQTrains,    filename_US)  ;
    conf.experiment.RPQ.path_filename_R             = fullfile(pathToRPQTrains,    filename_R)  ;
    
    conf.experiment.RPQ.path_filename_PPk       = fullfile(pathToRPQTrains,    filename_RPPk)  ;
    conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach   = fullfile(pathToRPQTrains,    filename_RPQPkQk_eigen_approach)  ;
    conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach_results   = fullfile(pathToRPQTrains,    filename_RPQPkQk_eigen_approach_results)  ;
    
     conf.val.path_filename_kernel = strrep(conf.val.path_filename,'.mat', sprintf('.%s.mat', conf.experiment.RPQ.kernel));
     conf.val.path_filename_kernel_valval = strrep(conf.val.path_filename_kernel,'.mat', sprintf('.%s.valval.mat', conf.experiment.RPQ.kernel));
     conf.test.path_filename_kernel = strrep(conf.test.path_filename,'.mat', sprintf('.%s.mat', conf.experiment.RPQ.kernel));
     conf.test.path_filename_kernel_testval = strrep(conf.test.path_filename_kernel,'.mat', sprintf('.%s.testval.mat', conf.experiment.RPQ.kernel));
    
   
end
%% --------------------------------------------------------------------
function [conf] = ComputingQQk(conf)
    fprintf('\n\t computes Q, Qk matrix ....');
    if ~exist (conf.experiment.RPQ.path_filename_QQk, 'file')
    
         fprintf('\n\t Loading S training feature vectors from %s  ....', conf.experiment.RPQ.path_filename_training_feature);
         load (conf.experiment.RPQ.path_filename_training_feature);
         fprintf('done');
        %%-------------------------------------------------------------     
         fprintf('\n\t computes Q matrix ....');
         Q = S*S';
         
         %%-------------------------------------------------------------     
          
         fprintf('\n\t computes Qk matrix ....');
         %Tinh cong duong cheo
         k=0.01;
         Qk = Q;
         n=size(Q,1);
         for i=1:n
            Qk(i,i)=Qk(i,i)+k;
         end
         
         %%-------------------------------------------------------------
         fprintf('\n\t Saving filename: %s ....',conf.experiment.RPQ.path_filename_QQk);
         save(conf.experiment.RPQ.path_filename_QQk,'Q','Qk','-v7.3');
         fprintf('done');
    end
end
function [conf] = ComputingPQPkQk(conf)
    
    if ~exist(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach,'file')            
        fprintf('\n computes R, P, Q, Pk, Qk matrix ....');
        
    
        if ~exist (conf.experiment.RPQ.path_filename_QQk, 'file')
            [conf] = ComputingQQk(conf);
        end
        fprintf('\n\t computes P, Pk matrix ....');
        if ~exist(conf.experiment.RPQ.path_filename_PPk,'file')   
            %%------------------------------------------------------------- 
            if ~exist (conf.experiment.RPQ.path_filename_training_feature,'file')
                    [conf]  = CalculatingTrainingTestingFeatureVectors(conf);
            end
            fprintf('\n\t Loading S training feature vectors from %s  ....', conf.experiment.RPQ.path_filename_training_feature);
            load (conf.experiment.RPQ.path_filename_training_feature);
            fprintf('done');
            
            %%-------------------------------------------------------------
        
            fprintf('\n\t Loading R response matrix ....');
            load(conf.experiment.RPQ.path_filename_R);
            fprintf('done');
            
            %%-------------------------------------------------------------    
            fprintf('\n\t computes P matrix ....');
            P = S*(R*R')*S';
            
            %%-------------------------------------------------------------     
            % Tinh cong ma tran: why ?
            % You can try to add an identity matrix with the same size like:
            % A = A + k*eye(size(A,1)); here k is an experimental coefficient smaller than 1. 
            % Doing this guarantees that matrix A is nonsingular

            % Qk = Q + k*eye(size(Q,1)); // slow than for loop
            % Pk = P + k*eye(size(P,1));
            %%-------------------------------------------------------------     
            k=0.01;  

            fprintf('\n\t computes Pk matrix ....');
            Pk = P;
            for i=1:size(P,1)
                Pk(i,i)=Pk(i,i)+k;
            end
           
            %%-------------------------------------------------------------
            fprintf('\n\t Saving filename: %s ....',conf.experiment.RPQ.path_filename_PPk);
            save(conf.experiment.RPQ.path_filename_PPk,'P','Pk','-v7.3');
            fprintf('done');

        end
    end
end
function [conf] = CalculatingTrainingTestingFeatureVectors(conf)

    if ~exist (conf.experiment.RPQ.path_filename_training_feature,'file')
        if strcmp(conf.experiment.RPQ.kernel,'linear')
            fprintf('\n\t Loading instance_matrix S from %s  ....', conf.val.path_filename);
            load (conf.val.path_filename);
            fprintf('done');
            S = instance_matrix;            
        else
            if ~exist (conf.val.path_filename_kernel_valval,'file')
                [conf]  = CaculatingKernel(conf);
            end
            fprintf('\n\t Loading instance_matrix_kernel S from %s ....',conf.val.path_filename_kernel_valval);
            load (conf.val.path_filename_kernel_valval);
            fprintf('done');            
            S = K;            
        end
        
        if(conf.experiment.RPQ.isAdd1==1)
            nrow = size(S,1);                
            S(nrow+1,:)=1;                
        end
            
        fprintf('\n\t Saving S training feature vectors into %s ....',conf.experiment.RPQ.path_filename_training_feature);
        save(conf.experiment.RPQ.path_filename_training_feature, 'S','-v7.3');
        fprintf('done');
    end
    %---------------------------------------------------------------------
    if ~exist (conf.experiment.RPQ.path_filename_testing_feature,'file')
        if strcmp(conf.experiment.RPQ.kernel,'linear')
            
            fprintf('\n\t Loading testing data from %s ....',conf.test.path_filename);
            test = load (conf.test.path_filename);
            fprintf('done');
            test_instance_matrix = test.instance_matrix;
            test_label_vector = test.label_vector;                
        else
            if ~exist (conf.test.path_filename_kernel_testval,'file')
                [conf]  = CaculatingKernel(conf);
            end
            fprintf('\n\t Loading testing data from %s ....',conf.test.path_filename_kernel_testval);
            load (conf.test.path_filename_kernel_testval);
            fprintf('done');
            test_instance_matrix = K_test'; %old co '
            clear  K_test;      

             fprintf('\n\t Loading testing data from %s ....',conf.test.path_filename);
            test = load (conf.test.path_filename,'label_vector');
            fprintf('done');               
            test_label_vector = test.label_vector; 
        end
        
        if(conf.experiment.RPQ.isAdd1==1)
            nrow = size(test_instance_matrix,1);                
            test_instance_matrix(nrow+1,:)=1;                
        end
            
        fprintf('\n\t Saving S testing feature vectors into %s ....',conf.experiment.RPQ.path_filename_testing_feature);
        save(conf.experiment.RPQ.path_filename_testing_feature, 'test_instance_matrix','test_label_vector','-v7.3');
        fprintf('done');
    end
end
function [conf] = CalculatingEigs(conf)
        % --------------------------------------------------------        
        %         fprintf('\n\t computes Q-P matrix ....');
        %         QP = Q\P;
        %         QP = QP + k*eye(size(QP,1));
        %         [VV,DD] = eigs(QP,[],L);
        % --------------------------------------------------------        
        %         fprintf('\n\t omputes eigs(P,Q,L) ....');
        %         tic
        %         [VV,DD] = eigs(P,Q,L);
        %         toc
        % --------------------------------------------------------       
        % Algorithm: training
        % Solve generalized eigenvalue problem
    fprintf('\n Calculating Eigs.......');
    if exist(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach,'file')
        fprintf(' done (ready)');
        return;
    end
    
    fprintf('\n\t Loading filename: %s ....',conf.experiment.RPQ.path_filename_PPk);
    load(conf.experiment.RPQ.path_filename_PPk);
    fprintf('done');
   
    fprintf('\n\t Loading filename: %s ....',conf.experiment.RPQ.path_filename_QQk);
    load(conf.experiment.RPQ.path_filename_QQk);
    fprintf('done');
    
    L=conf.class.Num;

%          1: eigs(P,Q,L)
%          2: eigs(Pk,Qk,L)
%          3: eigs(Q\P,L)
%          4: eigs(Qk\Pk,L)

    if  conf.experiment.RPQ.OptEigs ==1
        fprintf('\n\t computes eigs(P,Q,L=%d) ....',L);       
        tic        
        [VVk,DDk] = eigs(P,Q,L); % Warning: Matrix is close to singular or badly scaled. Results may be inaccurate. RCOND = 
        toc
    elseif  conf.experiment.RPQ.OptEigs ==2
        fprintf('\n\t computes eigs(Pk,Qk,L=%d) ....',L);       
        tic
        [VVk,DDk] = eigs(Pk,Qk,L);        
        toc
    elseif  conf.experiment.RPQ.OptEigs ==3
        fprintf('\n\t computes Q_iP = inv(Q)*P....');
        Q_iP = Q\P; % Qk^(-1) * Pk
        fprintf('\n\t computes eigs(Q_iP,L=%d) ....',L);       
        tic
        [VVk,DDk] = eigs(Q_iP,L);
        toc
    else
        fprintf('\n\t computes Qk_iPk = inv(Qk)*Pk....');
        Qk_iPk = Qk\Pk; % Qk^(-1) * Pk
        fprintf('\n\t computes eigs(Qk_iPk,L=%d) ....',L);       
        tic
        [VVk,DDk] = eigs(Qk_iPk,L);
        toc        
    end

    fprintf('\n\t Saving filename %s....',conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach);           
    save(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach,'VVk','DDk','-v7.3');
    fprintf('done');
end
%   31: Two step approach
function conf = TwoStepApproach(conf,start_Idx,end_Idx, step)
    fprintf('\n Two step approach');
    % Thuc hien Decomposing score_matrix
    conf.isOverWriteResult = false;
    EigenClassifier.Decomposing(conf); 
    
   
    fprintf('\n+----------------------------------------------------+');
    fprintf('\n| Pseudo class                                       |');
    fprintf('\n+----------------------------------------------------+');
   
    pseudoClass = PseudoClass();     
    conf  = pseudoClass.Init(conf);    
  
    conf.isOverWriteSVRTrain=false   ;
    conf.isOverWriteSVRTest=false   ;
  
    ci_start=start_Idx;
    ci_end = end_Idx;
    
   % Thuc hien training
    conf  = pseudoClass.Train(conf,ci_start,ci_end);
%      Thuc hien testing     
     conf  = pseudoClass.Test(conf,ci_start,ci_end);   
        % Ket hop ket qua lai  
     conf.isOverWriteResult= false;
     conf  = pseudoClass.Compose(conf); 
     EigenClassifier.CombineEvaluate_All(conf)  ;
end
%   32: Joint optimization
function conf = JointOptimizationApproachOldV(conf)
%     fprintf('\n approach=%d ....',approach);
        % --------------------------------------------------------        
        %         fprintf('\n\t computes Q-P matrix ....');
        %         QP = Q\P;
        %         QP = QP + k*eye(size(QP,1));
        %         [VV,DD] = eigs(QP,[],L);
        % --------------------------------------------------------        
        %         fprintf('\n\t omputes eigs(P,Q,L) ....');
        %         tic
        %         [VV,DD] = eigs(P,Q,L);
        %         toc
        % --------------------------------------------------------       
        % Algorithm: training
        % Solve generalized eigenvalue problem
       
        if ~exist(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach,'file')
            fprintf('\n Loading filename: %s ....',conf.experiment.RPQ.path_filename_PPk);
            load(conf.experiment.RPQ.path_filename_PPk);
            fprintf('done');
            
            L=conf.class.Num;

            fprintf('\n\t computes eigs(Pk,Qk,L=%d) ....',L);       
            tic
            [VVk,DDk] = eigs(Pk,Qk,L);
%           [VVk,DDk] = eigs(P,Q,L); % 7/27/2014
            toc
            fprintf('\n\t Saving filename %s....',conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach);           
            save(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach,'VVk','DDk','-v7.3');
            fprintf('done');
        else
           fprintf('\n\t Loading %s....',conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach);          
           load(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach);
           fprintf('done');
        end
        
        
        %% ------------------------------------------------------------------
       
       

        
        if strcmp(conf.experiment.RPQ.kernel,'linear')
                fprintf('\n\t Loading instance_matrix S from %s  ....', conf.val.path_filename);
                load (conf.val.path_filename);
                fprintf('done');
                S = instance_matrix;
                
                fprintf('\n\t Loading testing data from %s ....',conf.test.path_filename);
                test = load (conf.test.path_filename);
                fprintf('done');
                test_instance_matrix = test.instance_matrix;
                test_label_vector = test.label_vector;
                clear  test.instance_matrix;
        else
                fprintf('\n\t Loading instance_matrix_kernel S from %s ....',conf.val.path_filename_kernel_valval);
                load (conf.val.path_filename_kernel_valval);
                fprintf('done');
                S = K;
                clear K;
                
                fprintf('\n\t Loading testing data from %s ....',conf.test.path_filename_kernel_testval);
                load (conf.test.path_filename_kernel_testval);
                fprintf('done');
                test_instance_matrix = K_test';
                clear  K_test;               
                fprintf('\n\t Loading testing data from %s ....',conf.test.path_filename);
                test = load (conf.test.path_filename,'label_vector');
                fprintf('done');               
                test_label_vector = test.label_vector;
                
        end
            
                   
        
        fprintf('\n\t Loading R matrix from %s....',conf.experiment.RPQ.path_filename_PPk);
        load(conf.experiment.RPQ.path_filename_R,'R');
        fprintf(' done !');
    
         
        fprintf('\n\t Loading score matrix from %s....',conf.val.path_filename_score_matrix);
        M = load(conf.val.path_filename_score_matrix);
        fprintf(' done !');
        
        fprintf('\n\t\t Finding singular values and vectors by svds function with kk=%d...',conf.class.Num);
		[~,S_old,V_old] = svds(M.scores_matrix,conf.class.Num);
        fprintf(' done !');
        VT_old = V_old';
        
        %% ----------------------------------------------------------------             
        fprintf('\n Testing ...');

        arr_Acc=0;
        arr_AP=0;
        arr_Step =conf.pseudoclas.arr_Step;        
        num_Arr_Step = length(arr_Step);         
        

        for i=1: num_Arr_Step 
            l = arr_Step(i);        

            fprintf('\n\t -----------------------------------------------');
            fprintf('\n\t Computing i=%d/%d with kkk = %3d ...',i,num_Arr_Step, l);  

            W=VVk(:,1:l);
            Lambda=DDk(1:l,1:l);
            
            % Obtain U = ~ ST ~W .
            U=S'*W;           
            % Obtain V = ((U SS)+R )T .
%              SS=sqrt(Lambda);   
%             pinvUS=pinv(U*SS);              
%             V=pinvUS*R;   
            SS = S_old(1:l,1:l);
            V = VT_old(1:l,:);
            
            % Algorithm: classification
            % Calculate estimated response by Rtest = ~ STtest~WSS V T .
            % Rtest = test.instance_matrix'*W*SS*V; 
            Rtest = test_instance_matrix'*W*SS*V; 
            if strcmp(conf.datasetName ,'ImageCLEF2012')
                [ AP, pfirst, dPREC, dRECL, dF ] = imgCLEF.Evaluate(Rtest, test_ground_truth_matrix );
                arr_Acc(i)=AP;
                arr_AP(i)=AP;
            else
                [VL_AP, M_VL_AP, error_flat, Acc] =  Evaluate(Rtest, test.label_vector );
                arr_Acc(i)=Acc;
                arr_AP(i)=M_VL_AP;
            end            
        end
        fprintf('\n\t Saving results.....');        
        save(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach_results,'arr_Acc','arr_AP', '-v7.3');
        fprintf('done');
        
        fprintf('\n\t Results:\n');
        arr_Acc
        arr_AP
end
function conf = JointOptimizationApproach(conf)
       fprintf('\nJoint Optimization Approach...');
       [conf] = CalculatingEigs(conf);
       
    %% ------------------------------------------------------------------            
       fprintf('\n\t Loading S testing feature vectors from %s  ....', conf.experiment.RPQ.path_filename_testing_feature);
       load (conf.experiment.RPQ.path_filename_testing_feature);
       fprintf('done');
       
       ST_test = test_instance_matrix';
       clear test_instance_matrix;
       
       fprintf('\n\t Loading %s....',conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach);          
       load(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach);
       fprintf('done');
        
    
       fprintf('\n\t Loading S training feature vectors from %s  ....', conf.experiment.RPQ.path_filename_training_feature);
       load (conf.experiment.RPQ.path_filename_training_feature);
       fprintf('done');
       
        
       fprintf('\n\t Loading R matrix from %s....',conf.experiment.RPQ.path_filename_PPk);
       load(conf.experiment.RPQ.path_filename_R,'R');
       fprintf(' done !');
        
       
        %% ----------------------------------------------------------------             
        fprintf('\n Testing ...');

        arr_Acc=0;
        arr_AP=0;
        arr_Acc_V=0;
        arr_AP_V=0;
        arr_Step =conf.pseudoclas.arr_Step;        
        num_Arr_Step = length(arr_Step);         
        
       
        
        for i=1: num_Arr_Step 
            l = arr_Step(i);        

            fprintf('\n\t -----------------------------------------------');
            fprintf('\n\t Computing i=%d/%d with kkk = %3d ...',i,num_Arr_Step, l);  

            W=VVk(:,1:l);
            Lambda=DDk(1:l,1:l);
            
            % Obtain U = ~ ST ~W .
% 
%             size(S)
%             size(W)
%             pause
            U=S'*W;           
            % Obtain V = ((U SS)+R )T .
            SS=sqrt(Lambda);   
            pinvUS=pinv(U*SS);              
            VT=pinvUS*R;   
            
            % Algorithm: classification
            % Calculate estimated response by Rtest = ~ STtest~WSS V T .
            % Rtest = test.instance_matrix'*W*SS*VT; 
            Rtest =ST_test*W*SS*VT; 
            
            if strcmp(conf.datasetName ,'ImageCLEF2012')
                [ AP, pfirst, dPREC, dRECL, dF ] = imgCLEF.Evaluate(Rtest, test_ground_truth_matrix );
                arr_Acc(i)=AP;
                arr_AP(i)=AP;
            else
                [VL_AP, M_VL_AP, error_flat, Acc] =  Evaluate(Rtest, test_label_vector );
                arr_Acc(i)=Acc;
                arr_AP(i)=M_VL_AP;
            end        
                      
             
        end
        fprintf('\n\t Saving results.....');        
        save(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach_results,'arr_Acc','arr_AP','-v7.3');
        fprintf('done');
        
        fprintf('\n\t Results:\n');
        arr_Acc
       
        arr_AP
       
end
%   321: Joint optimization with High dimension feature vectors
function conf = JointOptimizationWithHighDimensionApproach(conf)
    if ~exist(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach,'file')
        %fprintf('\n computes the (algebraically) smallest eigenvalue/eigenvector of (A, B)');
        %     [VV,DD] = eig(B\A);
        %     [V,D] = eigs(A,B);
        %     V = bsxfun(@rdivide, V, sqrt(sum(V.*V)));    %# make: norm(V(:,i))==1
        %     
        %     [DDD, order] = sort(diag(D),'descend');  %# sort eigenvalues in descending order
        %     V = V(:,order);
        %     D = diag(sqrt(DDD));
        %     
        %       [DDD, order] = sort(diag(DD),'descend');  %# sort eigenvalues in descending order
        %     VV = VV(:,order);
        %     DD = diag(sqrt(DDD));
        %     
        %[lambda, x] = bleigifp(P,Q,397);
        % Tinh qua lau 
        %%-----------------------------------------------------------------   
        fprintf('\n Computing US matrix ...');
        if ~exist(conf.experiment.RPQ.path_filename_US,'file') 
            if ~exist(conf.experiment.RPQ.path_filename_S_svds,'file') 
                 numItem = conf.class.Num;
                 
                 fprintf('\n\t Loading instance_matrix S from %s ....',conf.val.path_filename);
                 load (conf.val.path_filename);
                 fprintf('done');
                 S = instance_matrix;

                 fprintf('\n\t Computing svds(%d) on S matrix...',numItem);
                 [US,SS,VS] = svds(S,numItem);
                 fprintf('done');   
             else
                fprintf('\n\t Loading US,SS,VS matrixs from filename %s....',filename_S_svds);           
                load(conf.experiment.RPQ.path_filename_S_svds); %,'US','SS','VS','-v7.3');
                fprintf('done');                
            end

            if conf.experiment.RPQ.opt==2
                fprintf('\n\t Computing US with option %d....',conf.experiment.RPQ.opt);
                US = S*VS*SS';
                fprintf('done');   
            end

            fprintf('\n\t Saving filename %s....',conf.experiment.RPQ.path_filename_US);
            save(conf.experiment.RPQ.path_filename_US,'US','SS','VS','-v7.3');
            fprintf('done');            
        else
            fprintf('\n\t Loading US from filename %s....',conf.experiment.RPQ.path_filename_US);
            load(conf.experiment.RPQ.path_filename_US); %,'US','SS','VS','-v7.3');
            fprintf('done');   
        end

        %%-----------------------------------------------------------------  

        fprintf('\n Loading RPQ from filename: %s ....',conf.experiment.RPQ.path_filename_PPk);
        load(conf.experiment.RPQ.path_filename_PPk);
        fprintf('done');
            
         
       fprintf('\n\t Computing PP,QQ.....');
       PP = US'*Pk*US;
       QQ = US'*Qk*US;

       fprintf('\n computes the (algebraically) smallest eigenvalue/eigenvector of (PP, QQ)');
%         [Phi,Lambda] = eigs(PP,QQ, L); % Warning: For nonsymmetric and complex problems,must have number of eigenvalues k < n-1.
       tic
       [Phi,Lambda] = eig(PP,QQ);
       toc
       [LambdaS, order] = sort(diag(Lambda),'descend');  %# sort eigenvalues in descending order
       Phi = Phi(:,order);
       Sigma = diag(sqrt(LambdaS));
       W=US*Phi;

       fprintf('\n\t Saving filename %s....',conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach);           
       save(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach,'Phi','Lambda','Sigma','W','-v7.3');
       fprintf('done');      
    else
       fprintf('\n\t Loading %s....',conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach);          
       load(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach);
       fprintf('done');
    end

    %% ------------------------------------------------------------------
       
    fprintf('\n\t Loading instance_matrix S from %s ....',conf.val.path_filename);
    load (conf.val.path_filename);
    fprintf('done');
    S = instance_matrix;

    fprintf('\n\t Loading testing data from %s ....',conf.test.path_filename);
    test = load (conf.test.path_filename);
    fprintf('done');

    fprintf('\n\t Loading R matrix from %s....',conf.experiment.RPQ.path_filename_R);
    load(conf.experiment.RPQ.path_filename_R,'R');
    fprintf(' done !');
        

    %%-----------------------------------------------------------------             
    fprintf('\n Testing ...');
    arr_Acc=0;
    arr_AP=0;
    arr_Step =conf.pseudoclas.arr_Step;   
    num_Arr_Step = length(arr_Step);

    for i=1: num_Arr_Step 
        l = arr_Step(i);        

        fprintf('\n\t ---------------------------------------');
        fprintf('\n\t Computing i=%d/%d with kkk = %3d ...',i,num_Arr_Step, l);  

        U=S'*W(:,1:l);
        V = pinv(U*Sigma(1:l,1:l))*R;        

        Stest = test.instance_matrix;
        Rtest = Stest'*W*Sigma(:,1:l)*V;

        if strcmp(conf.datasetName ,'ImageCLEF2012')
            [ AP, pfirst, dPREC, dRECL, dF ] = imgCLEF.Evaluate(Rtest, test_ground_truth_matrix );
            arr_Acc(i)=AP;
            arr_AP(i)=AP;
        else
            [VL_AP, M_VL_AP, ~, Acc] =  Evaluate(Rtest, test.label_vector );
            arr_Acc(i)=Acc;
            arr_AP(i)=M_VL_AP;
        end


    end

    fprintf('\n\t Saving results.....');        
    save(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach_results,'arr_Acc','arr_AP', '-v7.3');
    fprintf('done');

    arr_Acc
    arr_AP
end
%   33: Kernel extension
function conf = KernelExtensionApproach(conf)
    fprintf('\n Kernel Extension Approach  ');
    fprintf('\n\t Kernel function: %s  ',conf.experiment.RPQ.kernel);
    [conf]  = CaculatingKernel(conf);
    conf = JointOptimizationApproach(conf);
    
    
end
%   34: Formulation as classification problem
function conf = FormulationAsClassificationProblemApproach(conf)

    
       pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ;
       path_filename_svds = fullfile(pathToBinaryClassiferTrains,  'svds.mat');
       if  exist (path_filename_svds,'file')   

          fprintf('\n Loading svds...');  
          load(path_filename_svds) ;
           fprintf('done !');
       else   

          fprintf('\n Calculating svds...');  
          conf.eigenclass.L = conf.class.Num;
          fprintf('\n\t conf.eigenclass.L=%d...',conf.eigenclass.L);
          [UW,SW,VW] = svds(conf.eigenclass.W,conf.eigenclass.L);  
          fprintf('done !');
          fprintf('\n Saving svds...');  
          save(path_filename_svds,'UW','SW','VW', '-v7.3');
           fprintf('done !');
       end

       conf.eigenclass.UW = UW;
       conf.eigenclass.SW = SW;
       conf.eigenclass.VW = VW;
        
     %%================================================================
     
    fprintf('\n\t Loading testing data from %s ....',conf.test.path_filename);
    test = load (conf.test.path_filename);
    fprintf('done');
%      testing_instance_matrix = test.instance_matrix';
%     size(conf.eigenclass.W)
%     size(test.instance_matrix)
   fprintf('\n\t conf.eigenclass.Rtest');
%     Rtest = (testing_instance_matrix* conf.eigenclass.W);
    Rtest = (test.instance_matrix'* conf.eigenclass.W);
%    conf.eigenclass.Rtest = (testing.instance_matrix'* conf.eigenclass.UW)*conf.eigenclass.SW*conf.eigenclass.VW';
   arr_Step =conf.pseudoclas.arr_Step;
   arr_Acc=0;
    arr_AccR=0;
    arr_AP=0;
    arr_APR=0;
   num_Arr_Step = length(arr_Step);
    for i=1: num_Arr_Step %:-1:1
        k = arr_Step(i);        
        str_k = num2str(k,'%.3d');  
        fprintf('\n\t -----------------------------------------------');
        fprintf('\n\t LSIC: Composing i=%d/%d with kkk = %3d ...',i,num_Arr_Step, k);  

    
            UU  =  conf.eigenclass.UW(:,1:k);
            SS  = conf.eigenclass.SW(1:k,1:k);
            VV = conf.eigenclass.VW(:,1:k);
            VV_T = VV';
            
            fprintf('\n\t Composing final score matrix xxx ..');        
%             scores_matrix  = (testing_instance_matrix* UU)*SS*VV_T; 
             scores_matrix  = (test.instance_matrix'* UU)*SS*VV_T; 
            
            fprintf(' finish !');
            
            [VL_APE, M_VL_APE, error_flatE, AccE] =  Evaluate(scores_matrix , test.label_vector );            
            arr_Acc(i)=AccE;
            arr_AP(i)=M_VL_APE;
            fprintf('\n Calculating svds....');  
            [UR,SR,VR] = svds(Rtest,k);
            Rtest_new = UR*SR*VR';
            [VL_APE, M_VL_APE, error_flatE, AccR] =  Evaluate(Rtest_new , test.label_vector );
            arr_AccR(i) = AccR;
            arr_APR(i) = M_VL_APE;
            
    end
    
    
    fprintf('\n\t Saving results.....');        
        save(conf.experiment.RPQ.path_filename_RPQPkQk_eigen_approach_results,'arr_Acc','arr_AP','arr_AccR','arr_APR', '-v7.3');
        fprintf('done');
        
        fprintf('\n\t Results:\n');
        arr_Acc      
        arr_AccR
    
    
    
    
    
end
function conf = CaculatingR(conf, optionR)
    
    fprintf('\n\t computes R response matrix ....');
    if ~exist(conf.experiment.RPQ.path_filename_R,'file')
        fprintf('\n\t\t Loading scores matrix ....');
        path_filename_response  = conf.val.path_filename_score_matrix ;
        load (path_filename_response);  % scores_matrix
        fprintf('done');            
        if optionR==1
            R = zeros(size(scores_matrix));
            for i=1:length(val_label_vector)
                R(i,val_label_vector(i))=1;        
            end
        else
            R = scores_matrix; %default: optionR=0
            if optionR==2                 
                 for i=1:length(val_label_vector)
                    R(i,val_label_vector(i)) = max(R(:,val_label_vector(i)))+0.01;        
                 end   
            elseif optionR==3
                for i=1:length(val_label_vector)
                    R(i,val_label_vector(i))=1;        
                end
            end           
        end
        fprintf('\n\t\t Saving R response matrix ....');
        save(conf.experiment.RPQ.path_filename_R, 'R','-v7.3');
        fprintf('done');           
    else
        fprintf('done (ready)');
    end
end
function [conf]  = CaculatingKernel(conf)
    if exist(conf.val.path_filename_kernel_valval,'file') && exist(conf.test.path_filename_kernel_testval,'file')
        fprintf('\n\t Calculating kernel space is done !');
        return;
    end
   
    
   kernel = conf.experiment.RPQ.kernel;
   fprintf('\n Calculating kernel space: %s....',kernel);
    
%    if ~exist(conf.val.path_filename_kernel, 'file')
%         fprintf('\n\t Loading instance_matrix S from %s ....',conf.val.path_filename);
%         load (conf.val.path_filename);
%         fprintf('\n\t Calculating vl_homkermap(%s) on training.....',kernel);
%         instance_matrix_kernel = vl_homkermap(instance_matrix, 1, kernel); % , 'gamma', .5) ;
%         fprintf('done');     
% 
%         fprintf('\n\t Saving kernel instance_matrix into %s ....',conf.val.path_filename_kernel);
%         save(conf.val.path_filename_kernel,'instance_matrix_kernel','-v7.3');
%         fprintf('done');
%         val.instance_matrix_kernel = instance_matrix_kernel;
%         clear instance_matrix_kernel;
%     else
%         fprintf('\n\t Loading instance_matrix_kernel from %s ....',conf.val.path_filename_kernel);
%         val = load (conf.val.path_filename_kernel);
%         fprintf('done');
%         
%     end
%     % ---------------------------------------------------------------------
%     
%     if ~exist(conf.test.path_filename_kernel, 'file')
%         fprintf('\n\t Loading instance_matrix from %s ....',conf.test.path_filename);
%         load (conf.test.path_filename);
%         fprintf('\n\t Calculating vl_homkermap(%s) on test.....',kernel);
%         instance_matrix_kernel = vl_homkermap(instance_matrix, 1, kernel); % , 'gamma', .5) ;
%         fprintf('done');     
% 
%         fprintf('\n\t Saving kernel instance_matrix into %s ....',conf.test.path_filename_kernel);
%         save(conf.test.path_filename_kernel,'instance_matrix_kernel','-v7.3');
%         fprintf('done');
%         test.instance_matrix_kernel = instance_matrix_kernel;
%         clear instance_matrix_kernel;
%     else
%         fprintf('\n\t Loading instance_matrix_kernel from %s ....',conf.test.path_filename_kernel);
%         test = load (conf.test.path_filename_kernel);
%         fprintf('done');
%         
%     end
%     
 
    val = load (conf.val.path_filename);
    test = load (conf.test.path_filename);
    if ~exist(conf.val.path_filename_kernel_valval,'file')
        fprintf('\n\t Calculating vl_alldist(train,train,%s).....',kernel);
        tic
        K = vl_alldist(val.instance_matrix,val.instance_matrix, kernel) ; 
       % K = vl_alldist(val.instance_matrix_kernel,val.instance_matrix_kernel, kernel) ;        % compute the Chi2 kernel
       % K = val.instance_matrix_kernel' * val.instance_matrix_kernel;
        toc
        fprintf('done');
        
        fprintf('\n\t Saving kernel K = vl_alldist into %s ....',conf.val.path_filename_kernel_valval);
        save(conf.val.path_filename_kernel_valval,'K','-v7.3');
        fprintf('done');
        
    end
    
    
    if ~exist(conf.test.path_filename_kernel_testval,'file')

        fprintf('\n\t Calculating vl_alldist(test,train,%s).....',kernel);
        tic
         K_test = vl_alldist(test.instance_matrix,val.instance_matrix, kernel) ;    
       % K_test = vl_alldist(test.instance_matrix_kernel,val.instance_matrix_kernel, kernel) ;       
       % K_test = test.instance_matrix_kernel' * val.instance_matrix_kernel;  
        toc
        fprintf('done');
        
        fprintf('\n\t Saving kernel K_test = vl_alldist into %s ....',conf.test.path_filename_kernel_testval);
        save(conf.test.path_filename_kernel_testval,'K_test','-v7.3');
        fprintf('done');
    end
    
     
%
%    ki = vl_homkermap(vi, 1, 'kchi2'); % , 'gamma', .5) ;
%   vi = n x dim
%   ki = m x dim, m = 2*n + 1
%   V = VL_HOMKERMAP(X, N) computes a 2*N+1 dimensional approximated
%   kernel map for the Chi2 kernel. X is an array of data points. Each
%   point is expanded into a vector of dimension 2*N+1 and saved to
%   the output V. 
%   y = rand(10,100) ; y = 10 x 100
%   psiy = vl_homkermap(y, 3) ; psiy = 70 x 100
%    Kernel:: KCHI2
%     One of KCHI2 (Chi2 kernel), KINTERS (intersection kernel), KJS
%     (Jensen-Shannon kernel). The 'Kernel' option name can be omitted,
%     i.e. VL_HOMKERMAP(..., 'kernel', 'kchi2') has the same effect of
%     VL_HOMKERMAP(..., 'kchi2').

% The homogeneous kernel map can be best introduced by an example. Let x be a data matrix. The VLFeat vl_homkermap function can be used to obtain the linear representation of a Chi2 kernel as follows:
% 
%   K = vl_alldist(x, 'kchi2') ;        % compute the Chi2 kernel
%   psix = vl_homkermap(x, .6, 1) ;     % compute the homogeneous kernel map
%   K_ = psix' * psix ;                 % compute the Chi2 kernel approximation
% The matrices K and K_ are very similar, meaning that psix is a linear approximation of the Chi2 kernel. psix can then be used to train a Chi2-kernel SVM, for instance by using the linear SVM solver PEGASOS also bundled in VLFeat:
% 
%   w = vl_pegasos(psix, y, lambda) ;   % train the Chi2-SVM using a linear SVM solver
%   
end

%% ---------------------------------------------------------------------
% Notes:
% 1. You can try to add an identity matrix with the same size like:
   % A = A + k*eye(size(A,1)); here k is an experimental coefficient smaller than 1. 
   % Doing this guarantees that matrix A is nonsingular
% 2. Size of matrix
    %  scores_matrix          7483x256
    %  instance_matrix       32000x7483

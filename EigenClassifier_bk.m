function conf = EigenClassifier(conf, optionR, approach)
% EigenClassifier
% switch of optionR 
%   0: R = response matrix
%   1: R = Max(response matrix)
%   2: R = ground truth label
%   3: R = Max(response matrix, ground truth)

% switch of approach 
%   0: R = response matrix
%   1: R = Max(response matrix)
%   2: R = ground truth label
%   3: R = Max(response matrix, ground truth)

   fprintf('\n -----------------------------------------------');
   fprintf('\n EigenClassifier ...');
   fprintf('\n\t datasetName = %s',conf.datasetName);
   fprintf('\n\t optionR = %d',optionR);
   fprintf('\n\t approach = %d',approach);

    pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ; 
    filename_score_matrix= conf.val.filename_score_matrix;   
    path_filename_score_matrix 		= fullfile(pathToBinaryClassiferTrains,filename_score_matrix);
   
    filename_val_selected	= conf.val.filename;
    path_filename_val_selected   = fullfile(conf.experiment.pathToBinaryClassifer,    filename_val_selected)  ;
    
    filename_test_selected	= conf.test.filename;
    path_filename_test_selected   = fullfile(conf.experiment.pathToBinaryClassifer,    filename_test_selected);       
   
    %% --------------------------------------------------------------------
    path_filename_response  = path_filename_score_matrix;
    path_filename_feat      = path_filename_val_selected;
    path_filename_test      = path_filename_test_selected;
    
    opt=2;
    filename_QP                 =  sprintf('%s.QP.mat',conf.datasetName);
    filename_PkQk_eigen         =  sprintf('%s.PkQk.R%d.eigen.mat',conf.datasetName,optionR);
    filename_S_svds             =  sprintf('%s.S.svds.mat',conf.datasetName);
    filename_US                 =  sprintf('%s.US.Opt%d.mat',conf.datasetName,opt);
    filename_RPQPkQk            =  sprintf('%s.R%dPQPkQk.mat',conf.datasetName,optionR);
    filename_RPQPkQk_eigen_approach      =  sprintf('%s.R%dPQPkQk.eigs.app%d.mat',conf.datasetName,optionR,approach);
     
    path_filename_QP            = fullfile(conf.experiment.pathToBinaryClassifer,    filename_QP)  ;
    path_filename_PkQk_eigen    = fullfile(conf.experiment.pathToBinaryClassifer,    filename_PkQk_eigen)  ;
    path_filename_S_svds        = fullfile(conf.experiment.pathToBinaryClassifer,    filename_S_svds)  ;
    path_filename_US            = fullfile(conf.experiment.pathToBinaryClassifer,    filename_US)  ;
    path_filename_RPQPkQk       = fullfile(conf.experiment.pathToBinaryClassifer,    filename_RPQPkQk)  ;
    path_filename_RPQPkQk_eigen_approach   = fullfile(conf.experiment.pathToBinaryClassifer,    filename_RPQPkQk_eigen_approach)  ;
     

    L=conf.class.Num;
      
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
   
    %% --------------------------------------------------------------------
    if ~exist(path_filename_RPQPkQk,'file')   
       
        %%-----------------------------------------------------------------
        fprintf('\n computes S matrix ....');
        fprintf('\n\t Loading instance_matrix  ....');
        load (path_filename_feat);
        fprintf('done');
        S = instance_matrix;
        %%-----------------------------------------------------------------
        fprintf('\n computes R matrix ....');
        fprintf('\n\t Loading response matrix ....');
        load (path_filename_response);
        fprintf('done');            
        if optionR==1
            R = zeros(size(scores_matrix));
            for i=1:length(val_label_vector)
                R(i,val_label_vector(i))=1;        
            end
        else
            
            R = scores_matrix;
            if optionR==2
                 fprintf('\n\t computes R matrix ....');
                 for i=1:length(val_label_vector)
                    R(i,val_label_vector(i)) = max(R(:,val_label_vector(i)))+0.01;        
                 end   
            elseif optionR==3
                for i=1:length(val_label_vector)
                    R(i,val_label_vector(i))=1;        
                end
            end           
        end
        %%-----------------------------------------------------------------     
        fprintf('\n computes P matrix ....');
        P = S*(R*R')*S';
        %%-----------------------------------------------------------------     
        fprintf('\n computes Q matrix ....');
        Q = S*S';
        % Tinh cong ma tran
%         Qk = Q + k*eye(size(Q,1));
%         Pk = P + k*eye(size(P,1));
        %%-----------------------------------------------------------------     
        fprintf('\n computes Qk matrix ....');
        %Tinh cong duong cheo
        k=0.01;  
        Qk = Q;
        n=size(Q,1);
        for i=1:n
            Qk(i,i)=Qk(i,i)+k;
        end
        %%-----------------------------------------------------------------     
        fprintf('\n computes Pk matrix ....');
        Pk = P;
        for i=1:size(P,1)
            Pk(i,i)=Pk(i,i)+k;
        end
        fprintf('\n Saving filename: %s ....',filename_RPQPkQk);
        save(path_filename_RPQPkQk,'R','P','Q','Pk','Qk','-v7.3');
        fprintf('done');
    else
        fprintf('\n Loading filename: %s ....',filename_RPQPkQk);
        load(path_filename_RPQPkQk);
        fprintf('done');
    end
        
   %% ---------------------------------------------------------------------
   fprintf('\n Loading instance_matrix  ....');
   load (path_filename_feat);
   fprintf('done');
   S = instance_matrix;
        
   fprintf('\n Loading testing data  ....');
   test = load (path_filename_test);
   fprintf('done');
   
   %% ---------------------------------------------------------------------
   if approach==32
        fprintf('\n approach=%d ....',approach);
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

        %%-----------------------------------------------------------------             
        if ~exist(path_filename_RPQPkQk_eigen_approach,'file')
            fprintf('\n\t computes eigs(Pk,Qk,L=%d) ....',L);
            %%% begin 7/27 
%             k=0.04;  
%         
%              
%         n=size(Q,1);
%         for i=1:n
%             Qk(i,i)=Qk(i,i)+k;
%         end
%         %%-----------------------------------------------------------------     
%         fprintf('\n computes Pk matrix ....');
% 
%         for i=1:size(Pk,1)
%             Pk(i,i)=Pk(i,i)+k;
%         end
        %%% end 7/27
        
            tic
             [VVk,DDk] = eigs(Pk,Qk,L);
%            [VVk,DDk] = eigs(P,Q,L); % 7/27/2014
            toc
            fprintf('\n\t Saving filename %s....',filename_RPQPkQk_eigen_approach);           
            save(path_filename_RPQPkQk_eigen_approach,'VVk','DDk','-v7.3');
            fprintf('done');
        else
           fprintf('\n Loading %s....',filename_RPQPkQk_eigen_approach);          
           load(path_filename_RPQPkQk_eigen_approach);
           fprintf('done');
        end
        

        %%-----------------------------------------------------------------             
        fprintf('\n Testing ...');
                
        arr_Step =conf.pseudoclas.arr_Step;
        arr_Acc=0;

        arr_AP=0;
        num_Arr_Step = length(arr_Step);
         
        
        for i=1: num_Arr_Step %:-1:1
            l = arr_Step(i);        

            fprintf('\n\t -----------------------------------------------');
            fprintf('\n\t Computing i=%d/%d with kkk = %3d ...',i,num_Arr_Step, l);  

            W=VVk(:,1:l);
            Lambda=DDk(1:l,1:l);
            
            U=S'*W;              
            SS=sqrt(Lambda);   
            pinvUS=pinv(U*SS);   
        %12:26-6    V=pinvUS*scores_matrix;   
            V=pinvUS*R;   
            Rtest = test.instance_matrix'*W*SS*V; 
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
        arr_Acc
        arr_AP
 %% ---------------------------------------------------------------------
   elseif approach==321
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
        if ~exist(path_filename_US,'file') 
            if ~exist(path_filename_S_svds,'file') 
                 numItem = conf.class.Num;
                    fprintf('\n\t Computing svds(%d)...',numItem);
                    [US,SS,VS] = svds(S,numItem);
             else
                fprintf('\n\t Loading filename %s....',filename_S_svds);           
                load(path_filename_S_svds); %,'US','SS','VS','-v7.3');
                fprintf('done');                
            end
            
            if opt==2
                fprintf('\n\t Computing UStest, Ptest, Qtest....');
                US = S*VS*SS';
            end
            
            fprintf('\n\t Saving filename %s....',filename_US);
            save(path_filename_US,'US','SS','VS','-v7.3');
            fprintf('done');            
        else
            fprintf('\n\t Loading filename %s....',filename_US);
            load(path_filename_US); %,'US','SS','VS','-v7.3');
            fprintf('done');    
        end
        
        %%-----------------------------------------------------------------  
        
        fprintf('\n\t Computing PP,QQ.....');
        if ~exist(path_filename_RPQPkQk_eigen_approach,'file')
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
        
            fprintf('\n\t Saving filename %s....',filename_RPQPkQk_eigen_approach);           
            save(path_filename_RPQPkQk_eigen_approach,'Phi','Lambda','Sigma','W','-v7.3');
            fprintf('done');
        else
           fprintf('\n Loading %s....',filename_RPQPkQk_eigen_approach);          
           load(path_filename_RPQPkQk_eigen_approach);
           fprintf('done');
        end
        
        
        %%-----------------------------------------------------------------             
        fprintf('\n Testing ...');
        
        arr_Step =conf.pseudoclas.arr_Step;
        arr_Acc=0;
arr_AP=0;

        num_Arr_Step = length(arr_Step);
        
%         whos
%         pause

        for i=1: num_Arr_Step %:-1:1
            l = arr_Step(i);        

            fprintf('\n\t -----------------------------------------------');
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
        arr_Acc
        arr_AP
   elseif approach==34
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

   end
end

%% ---------------------------------------------------------------------
% Notes:
% 1. You can try to add an identity matrix with the same size like:
   % A = A + k*eye(size(A,1)); here k is an experimental coefficient smaller than 1. 
   % Doing this guarantees that matrix A is nonsingular
% 2. Size of matrix
    %  scores_matrix          7483x256
    %  instance_matrix       32000x7483

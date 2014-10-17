Dataset=3;

if Dataset==0
    filename_response   = '/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/train100.blaall/ILSVRC2010.liblinear.prob.val30.scores.mat';
    filename_feat       = '/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/ILSVRC2010.val30.sbow.mat';
    filename_test       = '/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/ILSVRC2010.test150.sbow.mat';
    filename_QP         = '/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/ILSVRC2010.QP.mat';
    filename_QP_eigen   = '/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/ILSVRC2010.QP.eigen.mat';
    filename_PkQk_eigen   = '/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/ILSVRC2010.PkQk.eigen.mat';
    L = 1000;
elseif Dataset==1
    filename_response   = '/data/Dataset/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/train50p.blaall/Caltech256.liblinear.prob.val25p.scores.mat';
    filename_feat       = '/data/Dataset/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.val25p.sbow.mat';
    filename_test       = '/data/Dataset/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.test25p.sbow.mat';
    filename_QP         = '/data/Dataset/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.QP.mat';
    filename_QP_eigen   = '/data/Dataset/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.QP.eigen.mat';
    filename_PkQk_eigen   = '/data/Dataset/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.PkQk.eigen.mat';
    L = 256;
elseif Dataset==2
    filename_response   = '/data/Dataset/SUN/experiments/train50p.val25p.test25p/binclassifiers/train50p.blaall/SUN397.liblinear.prob.val25p.scores.mat';
    filename_feat       = '/data/Dataset/SUN/experiments/train50p.val25p.test25p/binclassifiers/SUN397.val25p.sbow.mat';
    filename_test       = '/data/Dataset/SUN/experiments/train50p.val25p.test25p/binclassifiers/SUN397.test25p.sbow.mat';
    filename_QP         = '/data/Dataset/SUN/experiments/train50p.val25p.test25p/binclassifiers/SUN397.QP.mat';
    filename_QP_eigen   = '/data/Dataset/SUN/experiments/train50p.val25p.test25p/binclassifiers/SUN397.QP.eigen.mat';
    filename_PkQk_eigen   = '/data/Dataset/SUN/experiments/train50p.val25p.test25p/binclassifiers/SUN397.PkQk.eigen.mat';
    
    L = 397;
elseif Dataset==3
    filename_response   = '/data/Dataset/LSVRC/ILSVRC65/experiments/train100.val50.test150/binclassifiers/train100.blaall/ILSVRC65.liblinear.prob.val50.scores.mat';
    filename_feat       = '/data/Dataset/LSVRC/ILSVRC65/experiments/train100.val50.test150/binclassifiers/ILSVRC65.val50.sbow.mat';
    filename_test       = '/data/Dataset/LSVRC/ILSVRC65/experiments/train100.val50.test150/binclassifiers/ILSVRC65.test150.sbow.mat';
    filename_QP         = '/data/Dataset/LSVRC/ILSVRC65/experiments/train100.val50.test150/binclassifiers/ILSVRC65.QP.mat';
    filename_QP_eigen   = '/data/Dataset/LSVRC/ILSVRC65/experiments/train100.val50.test150/binclassifiers/ILSVRC65.QP.eigen.mat';
    filename_PkQk_eigen   = '/data/Dataset/LSVRC/ILSVRC65/experiments/train100.val50.test150/binclassifiers/ILSVRC65.PkQk.eigen.mat';
    L = 57;
end

k=0.01;    
%%-----------------------------------------------------------------------
    if exist (filename_QP, 'file')
        fprintf('\n Loading data from file %s....',filename_QP);
        load(filename_QP);
    else
        fprintf('\n Loading data ....');
        load (filename_feat);
        load (filename_response);
        test = load(filename_test);

        fprintf('done');
        %  scores_matrix          7483x256
        %  instance_matrix       32000x7483
        fprintf('\n computes matrix ....');

        R = scores_matrix;
        S = instance_matrix;

        fprintf('\n\t computes P matrix ....');
        P = S*(R*R')*S';
        fprintf('\n\t computes Q matrix ....');
        Q = S*S';
        fprintf('\n\t computes Q-P matrix ....');
        QP = Q\P;

        
        QP = QP + k*eye(size(QP,1));
    
   
        size(P)
        size(Q)
        size(QP)
        %You can try to add an identity matrix with the same size like:
        % A = A + k*eye(size(A,1)); here k is an experimental coefficient smaller than 1. 
        % Doing this guarantees that matrix A is nonsingular

         save(filename_QP,'P','Q','QP','-v7.3');
    end
    
    %%-------------------------------------------------------------------
    Qk = Q + k*eye(size(Q,1));
    Pk = P + k*eye(size(P,1));

    if ~exist(filename_QP_eigen,'file')
        tic
        fprintf('\n computes eig(QP)...');
        
        [VV,DD] = eigs(QP,[],L);
        fprintf('done');
        
        toc
        save(filename_QP_eigen,'P','Q','W','Lambda','-v7.3');
    else
        load(filename_QP_eigen);
    end
    save(filename_PkQk_eigen,'Pk','Qk','W','Lambda','-v7.3');
      save(filename_PkQk_eigen,'Pk','Qk','VVk','DDk','-v7.3');
  
      AddPathLib()  ;   
    for l=100:100:1000 
        l=64;
        W=VVk(:,1:l);
        Lambda=DDk(1:l,1:l);
        U=S'*W;              
        SS=sqrt(Lambda);   
        pinvUS=pinv(U*SS);   
        V=pinvUS*scores_matrix;   
        Rtest = test.instance_matrix'*W*SS*V; 
        [~, ~, ~, Acc] =  Evaluate(Rtest, test.label_vector )
        pause;
    end
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

    opt=1;
    
    if opt==1
        numItem=size(S,2);
        fprintf('\n\t Computing svds(%d)...',numItem);
        [US,SS,VS] = svds(S,numItem);
    else
        N=size(S,2);
        fprintf('\n\t Computing svds(%d)...',N);
        [US,SS,VS] = svds(S,N);
        fprintf('\n\t Computing UStest, Ptest, Qtest....');
        US = S*VS*SS';
       
    
    end
    fprintf('\n\t Computing PP,QQ.....');
    PP = US'*P*US;
    QQ = US'*Q*US;

    fprintf('\n computes the (algebraically) smallest eigenvalue/eigenvector of (PP, QQ)');
    [Phi,Lambda] = eig(PP,QQ);
        
    [LambdaS, order] = sort(diag(Lambda),'descend');  %# sort eigenvalues in descending order
    Phi = Phi(:,order);
    Sigma = diag(sqrt(LambdaS));
    W=US*Phi;

    U=S'*W;
    V = pinv(U*Sigma)*R;
    V=V';

    Stest = test.instance_matrix;
    Rtest = Stest'*W*Sigma*V';

    [VL_AP, M_VL_AP, error_flat, Acc] =  Evaluate(Rtest, test.label_vector )


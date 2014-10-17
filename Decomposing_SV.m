function Decomposing(conf)
%Decomposing Thuc hien phan ra ma tran score
%   Tinh bang ham sdvs
% Date update: 10 - 08 -2013
    % File chua score matrix
    fprintf('\n Decomposing score matrix .... ');
   

    filename_decomposed = conf.pseudoclas.filename_decomposed ;        
    path_filename_decomposed  = conf.pseudoclas.path_filename_decomposed
    if exist(path_filename_decomposed,'file') && conf.isOverWriteResult==false
       fprintf('finish (ready) !');
       return;
    end
    
    pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ;
    filename_score_matrix       = conf.pseudoclas.filename_score_matrix;      
    path_filename_score_matrix = fullfile(pathToBinaryClassiferTrains,filename_score_matrix)
    
    if ~exist(path_filename_score_matrix,'file')
        error('Error: File %s is not found !',path_filename_score_matrix);
    end
    fprintf('\n\t Loading score matrix ... ');
    load (path_filename_score_matrix);
    % save(path_filename_score_matrix, 'scores_matrix','val_label_vector','Accuracy','-v7.3');
    fprintf('finish !');
     
%         [VL_AP, M_VL_AP, error_flat, Acc] =  Evaluate(scores_matrix, val_label_vector );
%         fprintf('finish !');
%         
%        
%         fprintf('\n\t\t Acc = %f', Acc);
%         fprintf('\n\t\t M_VL_AP = %f', M_VL_AP);
%     
    
    num_classes = size(scores_matrix,1)
    num_images  = size(scores_matrix,2)

    if num_images < num_classes
        scores_matrix = scores_matrix';
        num_classes = size(scores_matrix,1);
        num_images  = size(scores_matrix,2);
    end
%     pause
    k = conf.pseudoclas.arr_Step(length(conf.pseudoclas.arr_Step));
    fprintf('\n\t\t Number of classes: %d', num_classes);
    fprintf('\n\t\t Number of images: %d', num_images);
    fprintf('\n\t\t Number of k: %d', k);    
    fprintf('\n\t Decomposing score matrix  .... ');
      
    tic
	if strcmp(conf.pseudoclas.str_decompose,'svds')
		fprintf('\n\t\t Finding singular values and vectors by svds function with kk=%d...',k);
		[U,S,V] = svds(scores_matrix,k);
		size(U)
		size(S)
		size(V)
        
        SV = S*V';
        V=SV';
        fprintf('\n\t\t Groundtruth: Finding singular values and vectors by svds function with kk=%d...',k);
        size(scores_matrix)
        scores_matrix_gt = zeros(num_classes,length(val_label_vector));
        for i=1:length(val_label_vector)
            scores_matrix_gt(val_label_vector(i),i)=1;        
        end

        [UGT,SGT,VGT] = svds(scores_matrix_gt,k);
        U=UGT;
        S=SGT;
        V=VGT;
        % flip
      %  fprintf('\n\t\t Using sign_flip...');
    %    loads{1} = U*S;
      %  loads{2} = V;
      %  [sgns,newmodel,SS] = sign_flip(loads,scores_matrix);
     %   US = newmodel{1,1}; 
    %    VV=newmodel{1,2};

        fprintf('finish !');
        fprintf('\n\t\t ');
        toc

        fprintf('\t Saving result: %s...', filename_decomposed);
      %  save(path_filename_decomposed, 'U', 'S','V','US','VV','-v7.3');
        save(path_filename_decomposed, 'U', 'S','V','UGT','SGT','VGT','scores_matrix','scores_matrix_gt','-v7.3');
        fprintf('finish !');
    %     pause;
	elseif strcmp(conf.pseudoclas.str_decompose,'nmf')
		
	% W,H: output solution
	% Winit,Hinit: initial solution
	% tol: tolerance for a relative stopping condition
	% timelimit, maxiter: limit of time and iterations
	% [W,H] = nmf(V,Winit,Hinit,tol,timelimit,maxiter)
		tol = 0.000000001;
		maxiter = 1000;
		timelimit = 10000;
		r=k;
		
% 		Winit = abs(randn(size(scores_matrix,1),r));
% 		Hinit = abs(randn(r,size(scores_matrix,2)));
% 		[W,H] = nmf(scores_matrix,Winit,Hinit,tol,timelimit,maxiter);
        
        [W,H] = nmf(scores_matrix,k,conf.pseudoclas.str_nmf_alg,maxiter,1);
        
        V = H';
        
        fprintf('\t Saving result: %s...', filename_decomposed);
      %  save(path_filename_decomposed, 'U', 'S','V','US','VV','-v7.3');
        save(path_filename_decomposed, 'W','V','-v7.3');
        fprintf('finish !');
	end
    
    
   
end


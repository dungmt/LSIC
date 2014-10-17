% Muc dích kiem tra xem SVD tao ra U,S,V co giong nhau khi thay doi K khong
% Neu co thi ta chi thuc hien cho SVD voi K lon nhat
clear all;
%pathToDirSVDS  = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb';
pathToDirSVDS  = 'D:\';

formatSpec_SVDS = 'ILSVRC2010.libsvm.pre.prob.val30.svds.%s.mat';
arr_Step = [100 200 300 400 500 600 700 800 900 1000];
   % for i=10:10
   i=5;
        k = arr_Step(i);        
        str_k = num2str(k,'%.3d');  
        fprintf('\n\t\t Iter k= %3d -------------------', k);         
        filename_svds_k = sprintf(formatSpec_SVDS,str_k);
        path_filename_svds_k = fullfile(pathToDirSVDS,filename_svds_k);
        fprintf('\n\t\t Filename: %s', filename_svds_k);
        
        if exist(path_filename_svds_k,'file')
            fprintf('\n\t\t Loading result of k=%d...',k);
            Pre = load(path_filename_svds_k);
            fprintf('finish (ready) !');
            
        end
 %  end
    epsilon=0.000001;
    for i=4:-1:1
        k = arr_Step(i);        
        str_k = num2str(k,'%.3d');  
        fprintf('\n\t\t Iter k= %3d -------------------', k);         
        filename_svds_k = sprintf(formatSpec_SVDS,str_k);
        path_filename_svds_k = fullfile(pathToDirSVDS,filename_svds_k);
        fprintf('\n\t\t Filename: %s', filename_svds_k);
        
        if exist(path_filename_svds_k,'file')
            fprintf('\n\t\t Loading result of k=%d...',k);
            Cur = load(path_filename_svds_k);
            fprintf('finish (ready) !');            
        end
        
        % Kiem tra S
        n_d = size(Cur.S,1);
        assert(n_d ==k);
        
        for j=1:n_d
            if Cur.S(j,j) - Pre.S(j,j) > epsilon
                fprintf('\n Cur.S(%d,%d)=%f ~= Pre.S(%d,%d)=%f at j=%d',j,j,Cur.S(j,j),j,j,Pre.S(j,j),j);
                break;
            end
        end
        if j==k
            fprintf('\n Cur.S== Pre.S at i=%d',i);
        end
        % Kiem tra U
        n_row = size(Cur.U,1);
        n_col = size(Cur.U,2);
        assert(n_col == k);
        flag_U = false;
        for row=1:n_row
            for col=1:n_col
                if abs(Cur.U(row,col)) - abs(Pre.U(row,col)) >epsilon
                    fprintf('\n abs(Cur.U(%d,%d))=%f ~= abs(Pre.U(%d,%d))=%f ',row,col,abs(Cur.U(row,col)),row,col,abs(Pre.U(row,col)) );
                    flag_U =true;
                    break;
                end
            end
            if flag_U == true
                break;
            end
            
        end
        if flag_U == false
            fprintf('\n Cur.U== Pre.U at i=%d',i);
        end
        
         % Kiem tra V
        flag_V = false;
        for row_v=1:30000
            for col_v=1:k
                if abs(Cur.V(row_v,col_v)) - abs(Pre.V(row_v,col_v))> epsilon
                    fprintf('\n abs(Cur.V(%d,%d))=%f ~= abs(Pre.V(%d,%d))=%f',row_v,col_v,abs(Cur.V(row_v,col_v)),row_v,col_v,abs(Pre.V(row_v,col_v)) );
                    flag_V = true;
                    break;
                end
            end
            if flag_V == true;
                break;
            end
        end
        if flag_V == false
            fprintf('\n Cur.V== Pre.V at i=%d',i);
        end
        Pre = Cur;
        
    end


fprintf('\n DONE !!');


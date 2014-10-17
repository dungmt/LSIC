filename_Data= '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb/ILSVRC2010.pre.val.val.d.mat';
filename_Out = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb/ILSVRC2010.pre.val.val.d.txt';
fprintf('Load data...');
load(filename_Data);

fprintf('\n Loading V matrix');
load('/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb/ILSVRC2010.libsvm.pre.prob.val.svds.500.mat');

ScaleValue =50000;
ci=1;   
training_label_vector = V(:,ci)*ScaleValue;  

fid = fopen(filename_Out,'w');

for i=1:50000
    fprintf('\n Writing data %d ...', i);
    % New training instance for xi:
    % <label> 0:i 1:K(xi,x1) ... L:K(xi,xL) 
    fprintf( fid,'%f 0:%d', training_label_vector(i), i);
    for j=2:50001
			%fprintf( fid,'%d %d %f\n', data_dump );
            fprintf( fid,' %d:%.6f',j, pre_valval_matrix(i,i) );
    end
    fprintf( fid,'\n');
end
fclose(fid);
clear all;
filename_Data= '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb/ILSVRC2010.libsvm.pre.prob.val.mat';
filename_Data2= '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb/ILSVRC2010.libsvm.pre.prob.val30.mat';
fprintf('\n Loading data...');
S = load(filename_Data);

scores_matrix = zeros(1000, 30000,'double');
i=1;
row =1;

while i<=1000
    fprintf('\n Reading data i: %d...',i);
    
    col = 1;
    col_run=1;
    while col_run < 50000
        for k=1:30
            
            scores_matrix(i,col) = S.scores_matrix(i,col_run);
            col_run = col_run + 1;
            col = col+1; 
        end
        col_run=col_run+20;
    end
    
    i=i+1;
    
end
fprintf('\n Saving new data...');
save(filename_Data2, 'scores_matrix','-v7.3');

fprintf('\n DONE !!');


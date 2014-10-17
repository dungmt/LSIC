clear all;
filename_Data= '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb/ILSVRC2010.val.mat';
pathToFile_Val = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb/ILSVRC2010.val30.mat';
fprintf('\n Loading data...');
S = load(filename_Data);

val_instance_matrix = zeros(30000, 50000,'double');
val_label_vector = zeros(30000,1);

i=1;
row =1;

while i<50000
    fprintf('\n Reading data i: %d...',i);
    for j=1:30
        val_instance_matrix(row,:) = S.val_instance_matrix(i,:);
        val_label_vector(row) = S.val_label_vector(i);
        row = row + 1;
        i = i+1;        
    end
    i=i+20;
end
fprintf('\n Saving new data...');
save(pathToFile_Val, 'val_instance_matrix','val_label_vector' ,'-v7.3');

fprintf('\n DONE !!');


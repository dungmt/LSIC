function [ listFeatures ] = ReadLowLevelFeatures( path_filename_features, n_dimension, m_items )
%READCONCEPTS Summary of this function goes here
%   Detailed explanation goes here
     fid = fopen(path_filename_features, 'rt');
    
    listFeatures= fscanf(fid,'%f',  [n_dimension,m_items]);
    listFeatures  = listFeatures';
%     tline = fgets(fid);
%     listFeatures=tline;
%while ischar(tline)
%     disp(tline)
%     cell2mat(tline)
  %  tline = fgets(fid);
%end
% 
%     lines = textscan(fid, '%s','endofline');
%     listFeatures = lines{1};
    fclose(fid);
     fprintf(' finish !');
    fprintf('\n\t Number of feature vectors: %d\n', size(listFeatures,1));
	fprintf('\n\t Dimension of feature vectors: %d\n', size(listFeatures,2));
end


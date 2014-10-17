function [ listConcepts ] = ReadConcepts( path_filename_listConcepts )
%READCONCEPTS Summary of this function goes here
%   Detailed explanation goes here
    fprintf('\n Reading list concepts');
   
    % listConcepts = dlmread(path_filename_listConcepts);
    fid = fopen(path_filename_listConcepts, 'rt');
    lines = textscan(fid, '%s');
    listConcepts = lines{1};
    fclose(fid);
    fprintf('\n\t Number of concepts: %d', length(listConcepts));
end


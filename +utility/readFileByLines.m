function [ listLines ] = readFileByLines( path_filename )
%READFILEBYLINES Summary of this function goes here
%   Detailed explanation goes here
   
    % listConcepts = dlmread(path_filename_listConcepts);
    fid = fopen(path_filename, 'rt');
    lines = textscan(fid, '%s');
    listLines = lines{1};
    fclose(fid);
%     fprintf('\n\t Number of lines: %d', length(listLines));
end


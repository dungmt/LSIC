function [ ] = AddPathLib(  )
%AddPathLib Khai bao va them cac thu vien
%   Thu vien libsvm, vlfeat,...
    if isunix
       % pathToLib = '/net/per610a/export/das09f/satoh-lab/dungmt/lib/';
        pathToLib = '/home/mmlab2/Dropbox/lib';
        addpath(fullfile(pathToLib, 'libsvm-3.17/matlab'));
        addpath(fullfile(pathToLib, 'liblinear-1.94/matlab'));            
       % run(    fullfile(pathToLib, 'vlfeat/toolbox/vl_setup')); 
        run(    fullfile(pathToLib, 'vlfeat-0.9.17/toolbox/vl_setup')); 
    
    elseif ispc 
        username=getenv('USERNAME');
        pathToLib = ['C:\Users\', username, '\Dropbox\lib\'];
        addpath(fullfile(pathToLib, 'libsvm-3.17\matlab'));
        addpath(fullfile(pathToLib, 'liblinear-1.94\matlab'));            
        %run(    fullfile(pathToLib, 'vlfeat\toolbox\vl_setup')); 
        run(    fullfile(pathToLib, 'vlfeat-0.9.17\toolbox\vl_setup')); 

    else
    % do a third thing
        error('Error: This program can not run in this os !!!');
    end
    
    

end


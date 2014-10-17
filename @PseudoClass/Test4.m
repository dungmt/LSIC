function conf  = Test4(obj,conf)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
	fprintf('\n Testing pseudo classes on Testing dataset...');
	
    isPreComp=obj.isPreComp;
    solvertype = obj.solvertype; % obj.solvertype = 'libsvm';
    pathToModel = conf.path.pathToModel ;    
    classifier.SVR_Test4(solvertype, isPreComp, conf.pseudoclas.arr_Step,pathToModel);   

end


function conf  = Test(obj,conf,ci_start,ci_end)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
	fprintf('\n Testing pseudo classes on Testing dataset...');
	
    isPreComp=obj.isPreComp;
    solvertype = obj.solvertype; % obj.solvertype = 'libsvm';
       
   %  
    if strcmp(conf.datasetName, 'ILSVRC2010')    
        classifier.SVR_Test_IL(conf,ci_start,ci_end);
    else
        classifier.SVR_Test(conf,solvertype, isPreComp,ci_start,ci_end);
    end
end


function synsets = BuildMetaData(conf, Q, isAuto)
   fprintf('\n\t -----------------------------------');
   fprintf('\n\t LabelTree:BuildMetaData: Building metata ...'); 
   
   if isAuto==0 
        if strcmp( conf.datasetName,'Caltech256')  
            synsets = HC.BuildMetaData_Manually_Caltech256(conf);
            pause
        elseif strcmp( conf.datasetName,'ILSVRC2010') 
            synsets = HC.BuildMetaData_Manually_ILSVRC2010(conf);
%             error('BuildMetaData: %s --> Chua xu ly',conf.datasetName);
        elseif strcmp( conf.datasetName,'ILSVRC65') 
            synsets = HC.BuildMetaData_Manually_ILSVRC65(conf);
        elseif strcmp( conf.datasetName,'SUN397') 
            synsets = HC.BuildMetaData_Manually_SUN397(conf);
        else
            error('BuildMetaData: %s',conf.datasetName);
        end
   elseif isAuto==1
        synsets = HC.BuildMetaData_Auto(conf,Q);
   elseif isAuto==2
        synsets = HC.BuildMetaData_SVMTree(conf);
   end
    
end


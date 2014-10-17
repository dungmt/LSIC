function label = genLB(imdb)
NUM_Con = 81;
 NUM_TrainIm = 161789;
 NUM_TestIm = 107859;
%NUM_TrainIm = 1000;
%NUM_TestIm = 1000;
NUM_Val = 10000;
    
    label = cell(NUM_Con,1);
    for i =1:NUM_Con
        label{i}=[];
        for j = 1:NUM_TrainIm-NUM_Val;
            if imdb.classes.trainGT(i,j)>0
                label{i}=[label{i} j];
            end
        end
    end
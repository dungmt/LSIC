function baseline = genBase(scoremat)

NUM_Con = 81;
 NUM_TrainIm = 161789;
 NUM_TestIm = 107859;
%NUM_TrainIm = 1000;
%NUM_TestIm = 1000;
NUM_Val = 10000;
    load('data/imdb.mat');
	GTMAT = imdb.classes.trainGT;
    GTMAT =GTMAT(:,NUM_TrainIm-NUM_Val:NUM_TrainIm);

   anno = lib.baseline.Annotation(scoremat,10,0);	
   %anno = demo.Annotation(scoremat,0,0);
   DEC=lib.baseline.genDEC(anno,scoremat);	
	
	%gen baseline
	%baseline.c = c(maxci);
    [ baseline.AP, baseline.pfirst, baseline.dPREC, baseline.dRECL, baseline.dF ] = lib.baseline.evalannotat( GTMAT', scoremat', DEC');
	[ baseline.mAP, baseline.mpfirst, baseline.mdPREC, baseline.mdRECL, baseline.mdF ] = lib.baseline.evalannotat( GTMAT', scoremat', DEC', 'mean');

end
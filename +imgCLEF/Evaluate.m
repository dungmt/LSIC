  function [ AP, pfirst, dPREC, dRECL, dF ] = Evaluate(scores_matrix, ground_truth_matrix )
  
    topn = 5;
    [annotation_dec_matrix ]=  imgCLEF.annotation_dec_2012(scores_matrix, topn);
    GTMAT = ground_truth_matrix'; 
    SCO = scores_matrix';
    DEC = annotation_dec_matrix'; 

    [ AP, pfirst, dPREC, dRECL, dF ] = imgCLEF.evalannotat_2012( GTMAT, SCO, DEC,'mean');
  end
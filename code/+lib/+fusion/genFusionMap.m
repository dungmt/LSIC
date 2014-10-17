function genFusionMap(input)

	sc =[];
	map = [];
    scoremat={};
    AP = {};
    scoremat{1} = input{1}.results.scoremat;
    scoremat{2} = input{2}.results.scoremat;

    sc = com(scoremat);    
end

function sc = com(scoremat)
    sc = [];
    ap = cell(1,numel(scoremat));
    for i =1:numel(scoremat)
        base = lib.fusion.genBase(scoremat{i});
        ap{i}=base.AP;
    end
    
    map = [];
    for i=1:size(scoremat{1},1) %concepts
        %t = test(GTMAT, scoremat, DEC,i);
        t = lib.fusion.maxF(ap,i);
        map = [map t];
        for j=1:size(scoremat{1},2) % images
            sc(i,j)=scoremat{t}(i,j);
        end
    end 
     save('data/FusionMap.mat','map');
end



function sc = CC(input)

	sc =[];
	map = [];
    scoremat={};
    AP = {};
    scoremat{1} = input{1}.results.scoremat;
    scoremat{2} = input{2}.results.scoremat;

    sc = com(scoremat);    
end

function sc = com(scoremat)

    load('data/FusionMap.mat');
    for i=1:size(scoremat{1},1) %concepts
        for j=1:size(scoremat{1},2) % images
            sc(i,j)=scoremat{map(i)}(i,j);
        end
    end 
     save('data/FusionMap.mat','map');
end



function synsets = BuildMetaData_Manually_SUN397(conf)
  fprintf('\n\t --> LabelTree:BuildMetaData: BuildMetaData_Manually_SUN397 .... '); 
for i=1:256
    ClassName = conf.class.Names{i};
    synsets(i).SYNSET_ID=i;
    synsets(i).WNID = ClassName;
    synsets(i).words = ClassName;
    synsets(i).gloss = ClassName;
    synsets(i).num_children=0;
    synsets(i).children =[];
    synsets(i).wordnet_height=0;
    synsets(i).num_train_images=0;
    synsets(i).leaf_indx=[i];
    synsets(i).parent_indx=[];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% -
i=398;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'Root';
synsets(i).words = 'Root';
synsets(i).num_children=3;
synsets(i).children =[399,400,401];

%% --
i=399;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'indoor';
synsets(i).words = 'indoor';
synsets(i).num_children=6;
synsets(i).children =[402,403,404,405,406,407];    
i=400;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'outdoor_natural';
synsets(i).words = 'outdoor natural';
synsets(i).num_children=4;
synsets(i).children =[408,409,410,411];    

i=401;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'outdoor_man_made';
synsets(i).words = 'outdoor man-made';
synsets(i).num_children=6;
synsets(i).children =[412,413,414,415,416,417];    
%---------------------------------------------------------- level 2:indoor
i=402;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'shopping_and_dining';
synsets(i).words = 'shopping and dining';
synsets(i).num_children=40;
synsets(i).children =[28,34,35,45,48,52,56,69,72,77,102,105,125,129,135,141,147,151,158,159,172,174,196,209,234,249,274,290,301,302,318,320,339,340,354,356,360,375,393,394;];   

i=403;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'workplace';
synsets(i).words = 'workplace (office building, factory, lab, etc.)';
synsets(i).num_children=38;
synsets(i).children =[8,19,21,24,51,57,63,90,91,92,98,106,108,110,114,123,126,143,144,145,146,149,176,189,211,220,229,256,260,267,276,298,316,331,335,373,381,382;];   

i=404;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'home_or_hotel';
synsets(i).words = 'home or hotel';
synsets(i).num_children=27;
synsets(i).children =[22,39,42,49,59,94,101,131,134,138,167,168,187,193,214,215,228,252,265,270,281,287,299,321,368,389,397;];   

i=405;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'transportation';
synsets(i).words = 'transportation (vehicle interiors, stations, etc.)';
synsets(i).num_children=19;
synsets(i).children =[2,3,27,50,68,79,80,104,132,133,166,179,227,278,289,337,338,363,370;];   

i=406;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'sports_and_leisure';
synsets(i).words = 'sports and leisure';
synsets(i).num_children=21;
synsets(i).children =[6,26,31,32,61,62,82,156,178,199,206,231,237,286,305,313,330,342,349,379,395;];  

i=407;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'cultural';
synsets(i).words = 'cultural (art, education, religion, etc.)';
synsets(i).num_children=32;
synsets(i).children =[10,11,14,16,17,18,23,67,84,85,95,97,100,107,117,207,208,213,221,222,242,247,248,250,283,291,334,344,346,352,353,355;];  
					
%------------------------------------------------- level 2:outdoor natural
i=408;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'water_ice_snow';
synsets(i).words = 'water, ice, snow';
synsets(i).num_children=35;
synsets(i).children =[44,47,53,55,75,103,120,121,124,136,157,190,197,198,201,202,205,217,236,246,255,285,295,306,311,315,325,329,341,367,384,385,386,387,388;];   

i=409;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'mountains_hills_desert_sky';
synsets(i).words = 'mountains, hills, desert, sky';
synsets(i).num_children=13;
synsets(i).children =[25,70,78,87,99,127,128,186,245,307,326,369,378;];   

i=410;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'forest_field_jungle';
synsets(i).words = 'forest, field, jungle';
synsets(i).num_children=34;
synsets(i).children =[33,36,58,112,113,115,150,152,153,160,161,162,163,164,175,182,184,261,262,266,271,277,280,292,297,304,358,364,365,371,377,390,391,396;];   

i=411;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'man_made_elements';
synsets(i).words = 'man-made elements';
synsets(i).num_children=7;
synsets(i).children =[12,185,308,309,351,366,374;];   

%------------------------------------------------- level 2:outdoor man-made
i=412;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'transportation';
synsets(i).words = 'transportation (roads, parking, bridges, boats, airports, etc.)';
synsets(i).num_children=21;
synsets(i).children =[15,54,64,76,111,119,122,170,180,181,183,219,224,225,230,268,269,296,310,357,362;];   
	 			

i=413;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'cultural_or_historical_building_place';
synsets(i).words = 'cultural or historical building/place';
synsets(i).num_children=34;
synsets(i).children =[1,5,13,40,46,74,83,86,88,96,116,118,165,210,216,223,226,238,239,240,241,243,253,254,263,264,279,282,284,345,347,348,359,392;];   

i=414;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'sports_fields_parks_leisure_spaces';
synsets(i).words = 'sports fields, parks, leisure spaces';
synsets(i).num_children=23;
synsets(i).children =[7,20,38,41,43,66,73,81,140,171,191,200,273,293,294,312,322,332,333,343,350,361,380;];   

i=415;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'industrial_and_construction';
synsets(i).words = 'industrial and construction';
synsets(i).num_children=11;
synsets(i).children =[109,142,148,169,203,218,251,258,259,288,383;];   

i=416;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'houses_cabins_gardens_and_farms';
synsets(i).words = 'houses, cabins, gardens, and farms';
synsets(i).num_children=21;
synsets(i).children =[29,30,37,60,71,89,93,137,139,177,194,195,212,232,233,272,300,317,323,324,372;];   

i=417;
synsets(i).SYNSET_ID=i;
synsets(i).WNID = 'commercial_buildings';
synsets(i).words = 'commercial buildings, shops, markets, cities, and towns';
synsets(i).num_children=21;
synsets(i).children =[4,9,65,130,154,155,173,188,192,204,235,244,257,275,303,314,319,327,328,336,376;];   


for i=398: length(synsets)
	synsets(i).gloss = synsets(i).WNID;
	synsets(i).wordnet_height=0;
	synsets(i).num_train_images=0;
end
fprintf('done !');
end


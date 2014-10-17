function synsets = BuildMetaData_Manually_Caltech256(conf)
  fprintf('\n\t --> LabelTree:BuildMetaData: BuildMetaData_Manually_Caltech256 .... '); 
for i=1:256
    ClassName = conf.class.Names{i};
    synsets(i).CALTECH256_ID=i;
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
i=257;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'Root';
synsets(i).num_children=2;
synsets(i).children =[258,306];
%% --
i=258;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'Inanimate';
synsets(i).num_children=14;
synsets(i).children =[259,260,266,270,273, 274, 275,279,282,283,289,293,297,305];                         %%%%%---------------------------------
%% ---
i=259;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'apparel';
synsets(i).num_children=10;
synsets(i).children =[3,51,67,54,149,191,194,232,255,223];
i=260;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'electronics';
synsets(i).num_children=5;
synsets(i).children =[261,262,263,264,265];

i=261;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'entertainment';
synsets(i).num_children=6;
synsets(i).children =[16,33,101,117,237,238];

i=262;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'computing';
synsets(i).num_children=9;
synsets(i).children =[45,46,47,27,75,127,153,120,157];

i=263;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'home';
synsets(i).num_children=6;
synsets(i).children =[21,171,142,239,174,220];

i=264;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'office';
synsets(i).num_children=2;
synsets(i).children =[161,156];

i=265;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'other';
synsets(i).num_children=3;
synsets(i).children =[74,131,139];
%% ---
i=266;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'food';
synsets(i).num_children=3;
synsets(i).children =[267,268,269];

i=267;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'containers';
synsets(i).num_children=7;
synsets(i).children =[10,35,41,66,195,246,212];

i=268;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'utensiles';
synsets(i).num_children=4;
synsets(i).children =[39,59,199,81];

i=269;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'edibles';					
synsets(i).num_children=7;
synsets(i).children =[26,115,78,95,108,196,206];
%% ---
i=270;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'fun';
synsets(i).num_children=2;
synsets(i).children =[271,272];

i=271;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'cartoon';
synsets(i).num_children=3;
synsets(i).children =[32,104,205];

i=272;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'toys';
synsets(i).num_children=4;
synsets(i).children =[160,79,213,249];

i=273;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'games';				
synsets(i).num_children=4;
synsets(i).children = [37,55,163,175];
%% ---
i=274;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'household and everyday';			
synsets(i).num_children=19;
synsets(i).children =[2,8,13,36,43,53,58,70,96,109,135,138,162,165,182,231,240,244,235];

%% ---
i=275;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'music';			
synsets(i).num_children=4;
synsets(i).children =[276,184,277,278];

i=276;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID = 'percussion';
synsets(i).num_children=3;
synsets(i).children =[211,233,247];

% i=277;
% synsets(i).CALTECH256_ID=i;
% synsets(i).WNID = 'sheet-music';
% synsets(i).num_children=5;
% synsets(i).children =[258,258];

i=277;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='stringed';
synsets(i).num_children=6;
synsets(i).children =[63,91,94,98,99,136];

i=278;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='wind';
synsets(i).num_children=2;
synsets(i).children =[77,97];
%% ---
i=279;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='natural';
synsets(i).num_children=2;
synsets(i).children =[280,281];

i=280;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='astronomical';
synsets(i).num_children=4;
synsets(i).children =[44,82,137,177];

i=281;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='terrestrial';
synsets(i).num_children=3;
synsets(i).children =[133,170,241];
%% ---
i=282;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='religious';
synsets(i).num_children=8;
synsets(i).children = [22,42,119,140,143,200,222,248];
%% ---
i=283;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='sports';
synsets(i).num_children=5;
synsets(i).children =[284,285,286,287,288];

i=i+1;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='baseball';
synsets(i).num_children=2;
synsets(i).children =[4,5];

i=i+1;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='bowling';
synsets(i).num_children=3;
synsets(i).children =[17,18,19];

i=i+1;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='exercise';				
synsets(i).num_children=2;
synsets(i).children =[61,227];

i=i+1;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='other';
synsets(i).num_children=7;
synsets(i).children =[11,6,76,88,176,193,203];

i=i+1;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='tennis';				
synsets(i).num_children=3;
synsets(i).children =[216,217,218];
%% ---
i=289;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='structures';
synsets(i).num_children=3;
synsets(i).children =[290,291,292];

i=i+1;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='public';
synsets(i).num_children=2;
synsets(i).children =[71,215];

i=i+1;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='building';
synsets(i).num_children=6;
synsets(i).children =[132,167,188,187,245,214];

i=i+1;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='famous';
synsets(i).num_children=3;
synsets(i).children =[62,86,225];
%% ---
i=293;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='tools';
synsets(i).num_children=3;
synsets(i).children =[294,295,296];

i=i+1;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='measurement';
synsets(i).num_children=6;
synsets(i).children =[12,110,141,169,183,219];

i=i+1;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='shop';
synsets(i).num_children=3;
synsets(i).children = [128,126,243];

i=i+1;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='small';
synsets(i).num_children=6;
synsets(i).children =[125,155,180,208,210,234];
%% ---
i=297;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='transportation';
synsets(i).num_children=4;
synsets(i).children =[298,299,303,304];

i=i+1;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='air';
synsets(i).num_children=5;
synsets(i).children =[251,14,107,102,69];

i=i+1; %299
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='ground';
synsets(i).num_children=2;
synsets(i).children =[300,301];

i=i+1; %300
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='motorized';
synsets(i).num_children=8;
synsets(i).children =[178,23,252,31,72,145,181,192];

i=i+1; %301
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='unmotorized';
synsets(i).num_children=3;
synsets(i).children =[302,50,185];
i=i+1; %302
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='bicycles';
synsets(i).num_children=3;
synsets(i).children =[146,229,224];

i=i+1; %303
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='related';
synsets(i).num_children=4;
synsets(i).children =[83,130,202,226];

i=i+1; %304
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='water';
synsets(i).num_children=4;
synsets(i).children =[30,122,123,197];

%% ---
i=305;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='weapons explosives';
synsets(i).num_children=6;
synsets(i).children =[1,29,73,172,173,209];
%% ------------------------------------------------------------------------
%% --
i=306;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='Animate';
synsets(i).num_children=6;
synsets(i).children =[307,311,312,313,314,315];
%% ---
i=i+1; %307
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='animal';
synsets(i).num_children=3;
synsets(i).children =[308,309,310];

i=i+1; %308
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='air';
synsets(i).num_children=11;
synsets(i).children =[114,100,113,49,60,89,118,151,152,158,207];

i=i+1; %309
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='land';
synsets(i).num_children=24;
synsets(i).children =[7,9,28,38,56,64,65,80,84,85,90,254,105,116,121,134,129,164,168,186,190,189,256,250];

i=i+1; %310
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='water';
synsets(i).num_children=9;
synsets(i).children =[106,52,48,57,87,124,148,150,201];
%% ---
i=311;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='extinct';
synsets(i).num_children=2;
synsets(i).children =[230,228];

%% ---
i=312;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='human';
synsets(i).num_children=4;
synsets(i).children =[20,253,112,159];

%% ---
i=313;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='insects';
synsets(i).num_children=8;
synsets(i).children =[24,34,40,93,111,166,179,198];

%% ---
i=314;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='mythological';			
synsets(i).num_children=2;
synsets(i).children =[144,236];

%% ---
i=315;
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='plant';			
synsets(i).num_children=4;
synsets(i).children =[316,317,318,319];

i=i+1; %316
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='trees';			
synsets(i).num_children=1;
synsets(i).children =[154];

i=i+1; %317
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='plants';			
synsets(i).num_children=3;
synsets(i).children =[15,25,68];

i=i+1; %318
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='flowers';
synsets(i).num_children=2;
synsets(i).children =[103,204];

i=i+1; %319
synsets(i).CALTECH256_ID=i;
synsets(i).WNID='fruits and vegetables';
synsets(i).num_children=4;
synsets(i).children =[92,147,221,242];

for i=257: length(synsets)
	synsets(i).words = synsets(i).WNID;
	synsets(i).gloss = synsets(i).WNID;
	synsets(i).wordnet_height=0;
	synsets(i).num_train_images=0;
end
fprintf('done !');
end


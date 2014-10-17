function Vebieudo( iData, iType)

        if iData==0
            pathToFileSaveData  ='D:\Acc_ILSVRC2010.mat';
            pathToFileSaveChart_Acc ='D:\Acc_ILSVRC2010_Acc.bmp';
            pathToFileSaveChart_Time ='D:\Acc_ILSVRC2010_Time.bmp';
            pathToFileSaveChart_Acc_PL='D:\Acc_ILSVRC2010_Acc_PL.bmp';
            
            pathToFileSaveChart_Acc_Eigencalss ='D:\Eigencalss_Acc_ILSVRC2010_Acc.bmp';
        elseif iData==1
            pathToFileSaveData  ='D:\Acc_Caltech256.mat';
            pathToFileSaveChart_Acc     ='D:\Acc_Caltech256_Acc.bmp';
            pathToFileSaveChart_Time    ='D:\Acc_Caltech256_Time.bmp';
            pathToFileSaveChart_Acc_PL     ='D:\Acc_Caltech256_Acc_PL.bmp';
            pathToFileSaveChart_Acc_Eigencalss ='D:\Eigencalss_Acc_Caltech256_Acc.bmp';
            %                 XLabel = [16 20	32	50	100	150	200	256];

        elseif iData==2  % SUN
            pathToFileSaveData  ='D:\Acc_SUN397.mat';
            pathToFileSaveChart_Acc     ='D:\Acc_SUN397_Acc.bmp';
            pathToFileSaveChart_Acc_PL     ='D:\Acc_SUN397_Acc_PL.bmp';
            pathToFileSaveChart_Time    ='D:\Acc_SUN397_Time.bmp';
            pathToFileSaveChart_Acc_Eigencalss ='D:\Eigencalss_Acc_SUN397_Acc.bmp';
%             XLabel = [20 25	40	50	100	200	300	397];
        elseif iData==3
            pathToFileSaveData  ='D:\Acc_ILSVRC65.mat';
            pathToFileSaveChart_Acc     ='D:\Acc_ILSVRC65_Acc.bmp';
             pathToFileSaveChart_Acc_PL     ='D:\Acc_ILSVRC65_Acc_PL.bmp';
            pathToFileSaveChart_Time    ='D:\Acc_ILSVRC65_Time.bmp';
            pathToFileSaveChart_Acc_Eigencalss ='D:\Eigencalss_Acc_ILSVRC65_Acc.bmp';
        end
        
        if exist(pathToFileSaveData,'file')                
            load(pathToFileSaveData); 
        else
            error('Can tao data truoc: %s', pathToFileSaveData);
%                  save(pathToFileSaveData, 'Acc_Arr', 'XLabel','RegressingTime_SVDS','Time_Arr','XLabel_Time_Arr','Acc_PL','Eigenclass_Acc_Arr');
        end
        Data = Acc_Arr';
        if( max(max(Data)) <1)
            Data = Data*100;
        end

        fig = figure();        
        if(iType==1)
            pl = plot(Data);
            set(gca, 'XTickLabel',XLabel, 'XTick',1:numel(XLabel))
            title('Accuracy vs # Pseudo class')
            xlabel('# Pseudo class')
            ylabel('Accuracy(%)')
            Legend={'svds','NMF-cjlin.tw','NMF-mm','NMF-cjlin','NMF-als','NMF-alsobs'};
            legend(pl,Legend,'Location','NorthWest')
            saveas(fig,pathToFileSaveChart_Acc);
        elseif(iType==2)       
            Time_Arr = Time_Arr';
            pl = bar(Time_Arr);
            set(gca, 'XTickLabel',XLabel_Time_Arr, 'XTick',1:numel(XLabel_Time_Arr))
            title('Testing time vs # activated classifier')
            xlabel('# activated classifier')
            ylabel('Testing time(s)')
            Legend={'Our Method','Label Tree'};
            legend(pl,Legend,'Location','NorthWest')
            saveas(fig,pathToFileSaveChart_Time);
         elseif(iType==3)
       
            Acc_PL = Acc_PL';
            if( max(max(Acc_PL)) <1)
                Acc_PL = Acc_PL*100;
            end
            pl = bar(Acc_PL);
            set(gca, 'XTickLabel',XLabel_Time_Arr, 'XTick',1:numel(XLabel_Time_Arr))
            title('Accuracy vs # activated classifier')
            xlabel('# activated classifier')
             ylabel('Accuracy(%)')
            Legend={'Our Method','Label Tree'};
            legend(pl,Legend,'Location','NorthWest')
            saveas(fig,pathToFileSaveChart_Acc_PL);
            
        elseif(iType==21)
            EigenclassData = Eigenclass_Acc_Arr';
            pl = plot(EigenclassData);
            set(gca, 'XTickLabel',XLabel, 'XTick',1:numel(XLabel))
            title('Accuracy vs # L classifiers')
            xlabel('# L classifiers ~ L-largest singular values')
            ylabel('Accuracy(%)')
            Legend={'Two-step approach (page 1)', ...
                    'JO(page 2) with R=response matrix', ...
                    'JO(page 2) with R=Max(response matrix)', ...
                    'JO(page 2) with R=ground truth label', ...
                    'JO(page 2) with R=Max(response matrix, ground truth label)', ...
                    'JO_HD(page 3) with R=response matrix', ...
                    'JOO_HD(page 3) with R=Max(response matrix)', ...
                    'JOO_HD(page 3) with R=ground truth label', ...
                    'JOO_HD(page 3) with R=Max(response matrix, ground truth label)', ...
                    'Algorithm (linear SVM):page 4'};
%             legend(pl,Legend,'Location','NorthWest')
            saveas(fig,pathToFileSaveChart_Acc_Eigencalss); 
        end
        


        %          pl = bar(Data);
%         hold on;
%         x=397;
%         y=45;
%          plot(x,y,'c*');
%           plot(x,y,'r.','MarkerSize',20)
%         
%          hold off
        
%        
        
end
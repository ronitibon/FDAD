function stats = FDAD_stats(Def)
        
    clear MCI CTRL AD
    load(Def.fileall);
    figure
    
    for f=1:length(Def.fdfiles) 
        
        fd_data = fdsubs.(Def.fdfiles(f));
        
        ind  = fd_data(:,3)==1;
        CTRL = [fd_data(fd_data(:,3)==1,1:3),mean(fd_data(fd_data(:,3)==1,4:end),2)]; % 1: CTRL
        MCI  = [fd_data(fd_data(:,3)==2,1:3),mean(fd_data(fd_data(:,3)==2,4:end),2)]; % 2: MCI
        
        if strcmp(Def.ds,'ADNI'); AD = [fd_data(fd_data(:,3)==3,1:3),mean(fd_data(fd_data(:,3)==3,4:end),2)]; end % 3: AD (only for ADNI)
        
        if Def.rmoutliers
            CTRL    = rmoutliers(CTRL);
            MCI     = rmoutliers(MCI);
            if strcmp(Def.ds,'ADNI'); rmoutliers(AD); end
        end
        
        subplot(1,length(Def.fdfiles),f)
        
        switch Def.ds
            case 'BioFIND'
                [stats.(Def.fdfiles(f)).h,stats.(Def.fdfiles(f)).p,stats.(Def.fdfiles(f)).ci,stats.(Def.fdfiles(f)).t] = ttest2(CTRL(:,4),MCI(:,4));
                ttlstr = {sprintf('%s',Def.aparc(f)),sprintf('t(%d)=%s, p=%s',stats.(Def.fdfiles(f)).t.df,num2str(round(stats.(Def.fdfiles(f)).t.tstat,2)),num2str(round(stats.(Def.fdfiles(f)).p,3)))};       
            case 'ADNI'
                [stats.(Def.fdfiles(f)).p , stats.(Def.fdfiles(f)).tbl, stats.(Def.fdfiles(f)).stats] = anova1([AD(:,4); MCI(:,4); CTRL(:,4)],[repmat({'AD'},size(AD,1),1); repmat({'MCI'},size(MCI,1),1); repmat({'CTRL'},size(CTRL,1),1)],'off');        
                stats.(Def.fdfiles(f)).F  = stats.(Def.fdfiles(f)).tbl{2,5};
                stats.(Def.fdfiles(f)).df = round([stats.(Def.fdfiles(f)).tbl{2,3}, stats.(Def.fdfiles(f)).tbl{3,3}]);
                ttlstr = {sprintf('%s',Def.aparc(f)),sprintf('F(%d,%d)=%s, p=%s',stats.(Def.fdfiles(f)).df(1),stats.(Def.fdfiles(f)).df(2),num2str(round(stats.(Def.fdfiles(f)).F,2)),num2str(round(stats.(Def.fdfiles(f)).p,3)))};        
        end        
        
        switch Def.plottype
            case 'box'
                switch Def.ds
                    case 'BioFIND'
                        
                        catOrder = ["CTRL","MCI"];
                        fd       = [CTRL(:,4);MCI(:,4)];
                        meanfd   = [mean(CTRL(:,4)),mean(MCI(:,4))];
                        namedCat = categorical([repmat({'CTRL'},size(CTRL,1),1); repmat({'MCI'},size(MCI,1),1)],catOrder);

                    case 'ADNI'
                  
                        catOrder = ["CTRL","MCI","AD"];
                        fd       = [CTRL(:,4);MCI(:,4);AD(:,4)];
                        meanfd   = [mean(CTRL(:,4)),mean(MCI(:,4)),mean(AD(:,4))];
                        namedCat = categorical([repmat({'CTRL'},size(CTRL,1),1); repmat({'MCI'},size(MCI,1),1); repmat({'AD'},size(AD,1),1)],catOrder);                   
                    otherwise
                end
                boxchart(namedCat,fd);
                hold on
                plot(meanfd,'-o')
                hold off
            case 'hist' 
                h1 = histogram(CTRL(:,4));
                hold on
                h2 = histogram(MCI(:,4));
                if strcmp(Def.ds,'ADNI'); h3 = histogram(AD(:,4)); end
                h1.Normalization = 'probability';
                h1.BinWidth = 0.01;
               
                h2.Normalization = 'probability';
                h2.BinWidth = 0.01;
                
                if strcmp(Def.ds,'ADNI'); h3.Normalization = 'probability'; h3.BinWidth = 0.01; end
                
                if strcmp(Def.ds,'bioFIND'); legend('CTRL','MCI','Location','northwest'); end
                if strcmp(Def.ds,'ADNI'); legend('CTRL','MCI','AD','Location','northwest'); end
                hold off
            otherwise
        end
        
        title(ttlstr)
        
    %     mdl = fitglm(subs(:,4:end),subs(:,3)-1,'Distribution','binomial')
    
    end
    
end
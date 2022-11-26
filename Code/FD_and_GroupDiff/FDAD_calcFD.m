function x = FDAD_calcFD(Def)

    % calculate fractal dimentionality using multiple parcellation schemes

    sample              = 'IXI';    
    subjectpath         = Def.subpath;
    outpath             = Def.outpath;
    subjects            = Def.subs;
    options.alg         = 'dilate';
    options.countFilled = 1;

    if find(Def.aparc=='Ribbon') 
        
        options.aparc       = 'Ribbon';
        options.labelfile   = 'none'  ;
        options.output      = sprintf('calcFD_%s_%s_%g_%s.txt',sample,options.aparc,options.countFilled,options.alg);
        tic;[fd,subjects]   = calcFD(subjects,subjectpath,options);toc
        save(sprintf('%s/fdRibbon_%s.mat',Def.outpath,Def.ds),'subjects','fd');
        
    end

    if find(Def.aparc=='Lobe') 
        
        options.aparc       = 'Dest_aparc';
        options.input       = 'lobe';
        options.labelfile   = 'lobes_legend.txt'; % 20180503 SK: provide legend text file for lobes 
        options.output      = sprintf('calcFD_Lobe_%s_%s_%g_%s.txt',sample,options.aparc,options.countFilled,options.alg);
        tic;[fd,subjects]   = calcFD(subjects,subjectpath,options);toc
        save(sprintf('%s/fdLobe_%s.mat',Def.outpath,Def.ds),'subjects','fd');
        
    end
    
    if find(Def.aparc=='DKT') 
        
        options.aparc       = 'DKT';
        options.labelfile   = 'none'; 
        options.output      = sprintf('calcFD_DKT_%s_%s_%g_%s.txt',sample,options.aparc,options.countFilled,options.alg);
        tic;[fd,subjects]   = calcFD(subjects,subjectpath,options);toc
        save(sprintf('%s/fdDKT_%s.mat',Def.outpath,Def.ds),'subjects','fd');
        
    end

    if find(Def.aparc=='Destrieux') 
        
        options.aparc       = 'Dest_aparc';
        options.input       = 'destrieux';
        options.labelfile   = 'none';
        options.output      = sprintf('calcFD_Destrieux_%s_%s_%g_%s.txt',sample,options.aparc,options.countFilled,options.alg);
        tic;[fd,subjects]   = calcFD(subjects,subjectpath,options);toc
        save(sprintf('%s/fdDestrieux_%s.mat',Def.outpath,Def.ds),'subjects','fd');
        
    end
    
    if find(Def.aparc=='Subcort') 
        
        options.aparc       = 'Dest_select';
        options.input       = 'subcort';
        options.labelfile   = 'select_subcort_legend.txt'; % 20180503 SK: provide label file for subcortical structures
        options.output      = sprintf('calcFD_%s_%s_%s_%g_%s.txt',sample,options.aparc,options.input,options.countFilled,options.alg);
        tic;[fd,subjects]   = calcFD(subjects,subjectpath,options);toc
        save(sprintf('%s/fdSubcort_%s.mat',Def.outpath,Def.ds),'subjects','fd');
        
    end
    
    x = 1;

end
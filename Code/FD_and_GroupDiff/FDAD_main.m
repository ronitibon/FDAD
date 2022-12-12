%% MAIN SCRIPT: FDAD
% created by Roni Tibon roni.tibon@city.ac.uk 
% available on https://github.com/ronitibon/FDAD

% Matlab version: R2020a

clear

addpath(genpath('/imaging/henson/users/rt01/toolboxes/calcFD-master'))
addpath(genpath('/imaging/henson/users/rt01/MSc_Project/Code'))
addpath(genpath('/imaging/henson/users/rt01/MSc_Project/GroupData'))


%% BioFIND

% Calculate DF

Def.subpath = '/imaging/henson/users/rt01/MSc_Project/BioFIND';     % path for inputs
Def.outpath = '/imaging/henson/users/rt01/MSc_Project/GroupData';   % path for outputs
Def.subs    = {'.'};                                                % subjects
Def.aparc   = ["Ribbon";"Lobes";"DKT";"Destrieux";"Subcort"];       % parcellation schemes
Def.ds      = 'BioFIND';                                            % dataset

FDAD_calcFD(Def);


% Arrange data

Def.subfile = sprintf('%s/participants.tsv',Def.subpath);
Def.fdfiles = ["fdRibbon";"fdLobes";"fdDKT";"fdDestrieux";"fdSubcort"];

fdsubs = FDAD_arrangeData(Def);

save(sprintf('%s/fdsubs_BioFIND.mat',Def.outpath),'fdsubs');


% Stats and plots

Def.fileall     = 'fdsubs_BioFIND';
Def.rmoutliers  = 1;        % 0: keep outliers; 1: remove outliers
Def.plottype    = 'box';    % 'hist' or 'box'

stats = FDAD_stats(Def);

save fdstats_BioFIND stats

%% ADNI

% Calculate FD

Def.subpath = '/imaging/henson/users/rt01/MSc_Project/ADNI';        % path for inputs
Def.outpath = '/imaging/henson/users/rt01/MSc_Project/GroupData';   % path for outputs
Def.subs    = {'.'};                                                % subjects
Def.aparc   = ["Ribbon";"Lobe";"DKT";"Destrieux";"Subcort"];                  % parcellation schemes
Def.ds      = 'ADNI';                                               % dataset

fd = FDAD_calcFD(Def);


% Arrange data

Def.subfile = sprintf('%s/ADNIparticipant.csv',Def.subpath);
Def.fdfiles = ["fdRibbon";"fdLobes";"fdDKT";"fdDestrieux";"fdSubcort"];

fdsubs = FDAD_arrangeData(Def);

save(sprintf('%s/fdsubs_ADNI.mat',Def.outpath),'fdsubs');


% Stats and plots

Def.ds          = 'ADNI';
Def.fileall     = 'fdsubs_ADNI';
Def.rmoutliers  = 1;        % 0: keep outliers; 1: remove outliers
Def.plottype    = 'box';    % 'hist' or 'box'
Def.fdfiles     = ["fdRibbon";"fdLobes";"fdDKT";"fdDestrieux";"fdSubcort"];

stats = FDAD_stats(Def);


%% GLM and Correlated datasets

clear

Def.allds       = {'fdsubs_BioFIND','fdsubs_ADNI'};
Def.grouping    = 1; % 0: remove AD from ADNI; 1: group MCI and AD together for ADNI; 
Def.fdfiles = ["fdRibbon";"fdLobes";"fdDKT";"fdDestrieux";"fdSubcort"];

% Compute GLMs and extract Rs

fdGLM = FDAD_glm(Def);
save fdGLM fdGLM

% Correlate Rs across datasets

Rs_BioFIND = [fdGLM.fdsubs_BioFIND.fdRibbon.Rs fdGLM.fdsubs_BioFIND.fdLobes.Rs fdGLM.fdsubs_BioFIND.fdDKT.Rs fdGLM.fdsubs_BioFIND.fdDestrieux.Rs fdGLM.fdsubs_BioFIND.fdSubcort.Rs];
Rs_ADNI = [fdGLM.fdsubs_ADNI.fdRibbon.Rs fdGLM.fdsubs_ADNI.fdLobes.Rs fdGLM.fdsubs_ADNI.fdDKT.Rs fdGLM.fdsubs_ADNI.fdDestrieux.Rs fdGLM.fdsubs_ADNI.fdSubcort.Rs];

[r p] = corrcoef(Rs_BioFIND,Rs_ADNI); % pearson correlation
[h_BioFIND,pkw_BioFIND] = kstest(Rs_BioFIND); [h_ADNI,pkw_ADNI] = kstest(Rs_ADNI); % check for normality
[rho,prho] = corr(Rs_BioFIND',Rs_ADNI', 'Type','Spearman'); % spearman correlation

mdl_corr = fitlm(zscore(Rs_BioFIND),zscore(Rs_ADNI), 'VarNames',{'BioFIND (z-scores)','ADNI (z-scores)'});
figure,
plot(mdl_corr)

% Classify ADNI with model trained on BioFIND

load('fdsubs_ADNI.mat')

figure
for f = 1:length(Def.fdfiles)
    mdl = fdGLM.fdsubs_BioFIND.(Def.fdfiles(f)).mdl;    % model from BioFIND
    
    switch Def.grouping 
                case 0    % exclude AD    
                    X = fdsubs.(Def.fdfiles(f))(fdsubs.(Def.fdfiles(f))(:,3)<3,4:end);
                    y = fdsubs.(Def.fdfiles(f))(fdsubs.(Def.fdfiles(f))(:,3)<3,3);
                case 1    % group patients (MCI+AD)    
                    X = fdsubs.(Def.fdfiles(f))(:,4:end); % predictors from ADNI
                    y = fdsubs.(Def.fdfiles(f))(:,3);     % outcome from ADNI
                    y(y==3)=2; 
                
    end
            
    y = y-1;

    yhat  = predict(mdl,X);
    yb    = discretize(yhat,0:0.5:1)-1;

    subplot(1,5,f)
    cm = confusionchart(confusionmat(y,yb),{'CTRL','PATIENTS'},'normalization','total-normalized');
    cm.Title = Def.fdfiles(f);
    
end


%% Plot Rs values on MRI image

Def.aparc       = 'Subcort';
Def.subjectpath = '/imaging/henson/users/rt01/freesurfer-7.3/freesurfer/subjects/';
Def.subject     = 'bert'; % template subject

addpath(genpath('/imaging/henson/users/rt01/toolboxes/NIfTI'))

switch Def.aparc 
    case 'Subcort';     mgzfile = 'aseg.mgz';          
    case 'Destrieux';   mgzfile = 'aparc.a2009s+aseg.mgz';
    case 'DKT';         mgzfile = 'aparc.DKTatlas+aseg.mgz';
end


% Get volume from exemplar subject ('Bert')

cd(sprintf('%s/%s/mri',Def.subjectpath,Def.subject))

vol_fname = fullfile(Def.subjectpath,Def.subject,'mri',mgzfile); % DKT: 'aparc.DKTatlas+aseg.mgz'; Destrieux: 'aparc.a2009s+aseg.mgz'
vol = load_mgh(vol_fname);

% Get Rs for selected parcellation

load('/imaging/henson/users/rt01/MSc_Project/GroupData/fdGLM')
Rs = fdGLM.fdsubs_BioFIND.(['fd',Def.aparc]).Rs;

switch Def.aparc 
    case 'Subcort'    

        % Labels for subcortical regions
        % ROI           L   R
        % thalamus      10	49
        % caudate		11	50
        % putamen		12	51
        % pallidum      13	52
        % hippocampus 	17	53
        % amygdala      18	54
        % accumbens     26	58

        lL = [10,11,12,13,17,18,26];
        lR = [49,50,51,52,53,54,58];

        Rs = [Rs,Rs];

        vol(~ismember(vol,[lL,lR])) = 0;
        u = unique(vol(:));   
        
    otherwise
        
        vol(vol<=999) = 0;
        u = unique(vol(:));
                
end
    
% Overlay Rs values on volume

for i = 2:length(u)
    
    vol(vol==u(i)) = Rs(i-1);
    
end

% Save as NIFTI file 

img = load_untouch_nii('anat.nii');
img.img = vol.*1000;
save_untouch_nii(img,sprintf('anat_Rs_%s.nii',Def.aparc));


%% Select best features and generate datasets for ML with Python

clear

Def.cort       = 'Destrieux'; % cortical parcellation scheme to include (only choose 1 to avoid double dipping 
Def.subcort    = 'Subcort'; % subcortical parcellation scheme to include
Def.grouping   = 1; % 0: remove AD from ADNI; 1: group MCI and AD together for ADNI;
Def.path       = '/imaging/henson/users/rt01/MSc_Project/GroupData';   % path for outputs

cd(Def.path)

load('fdGLM.mat')
BioFIND         = load('fdsubs_BioFIND.mat');
ADNI            = load('fdsubs_ADNI.mat');
BioFIND_cort    = load(sprintf('fd%s_BioFIND.mat',Def.cort));
BioFIND_subcort = load(sprintf('fd%s_BioFIND.mat',Def.subcort));
ADNI_cort       = load(sprintf('fd%s_ADNI.mat',Def.cort));
ADNI_subcort    = load(sprintf('fd%s_ADNI.mat',Def.subcort));
Labels_cort     = load(sprintf('%s_labels.mat',Def.cort));      Labels_cort     = Labels_cort.([Def.cort,'_labels']);
Labels_subcort  = load(sprintf('%s_labels.mat',Def.subcort));   Labels_subcort  = Labels_subcort.([Def.subcort,'_labels']);

% Get selected features from cortical and subcortical parcellations
%   Only select those for which Rs were significant in BioFIND
%   Bonferroni correction is applied across overall number of ROIs (e.g.,155 when Destrieux and Subcort are used)

bcorr = size(BioFIND_cort.fd,2)+size(BioFIND_subcort.fd,2); % value for Bonferroni correction


% Labels for selected cortical and subcortical features

Labels_cort     = Labels_cort(fdGLM.fdsubs_BioFIND.(sprintf('fd%s',Def.cort)).P<0.05/bcorr)'; % labeles for selected cortical features
Labels_subcort  = Labels_subcort(fdGLM.fdsubs_BioFIND.(sprintf('fd%s',Def.subcort)).P<0.05/bcorr)'; % labels for selected subcortical features


% Select features from BioFIND and generate dataset

BioFIND_sdata = BioFIND_cort.fd(:,fdGLM.fdsubs_BioFIND.(sprintf('fd%s',Def.cort)).P<0.05/bcorr); 
BioFIND_sdata = [BioFIND_sdata BioFIND_subcort.fd(:,fdGLM.fdsubs_BioFIND.(sprintf('fd%s',Def.subcort)).P<0.05/bcorr)];
BioFIND_y     = BioFIND.fdsubs.fdRibbon(:,3)-1;   % outcome - used 'Ribbon' here but it doesn't matter because outcomes are the same for all schemes

BioFIND_table = array2table([BioFIND_sdata BioFIND_y],'VariableNames',[Labels_cort Labels_subcort 'Class']); % create table

save BioFIND_table BioFIND_table % save table as mat
writetable(BioFIND_table,'BioFIND_table.csv') % save table as csv


% Select features from ADNI (based on BioFIND) and generate dataset

ADNI_sdata = ADNI_cort.fd(:,fdGLM.fdsubs_BioFIND.(sprintf('fd%s',Def.cort)).P<0.05/bcorr); % ADNI features are selected based on BioFIND 
ADNI_sdata = [ADNI_sdata ADNI_subcort.fd(:,fdGLM.fdsubs_BioFIND.(sprintf('fd%s',Def.subcort)).P<0.05/bcorr)];
ADNI_y     = ADNI.fdsubs.fdRibbon(:,3)-1;   % outcome - used 'Ribbon' here but it doesn't matter because outcomes are the same for all schemes

switch Def.grouping 
    case 0    % exclude AD  
        ADNI_sdata = ADNI_sdata(ADNI.fdsubs.fdRibbon(:,3)<3,:); 
        ADNI_y = ADNI.fdsubs.fdRibbon(ADNI.fdsubs.fdRibbon(:,3)<3,3)-1;        
    case 1    % group patients (MCI+AD)   
        ADNI_sdata = ADNI_sdata;                % predictors
        ADNI_y = ADNI.fdsubs.fdRibbon(:,3);     % outcome
        ADNI_y(ADNI_y==3)=2; ADNI_y = ADNI_y-1;
end

ADNI_table = array2table([ADNI_sdata ADNI_y],'VariableNames',[Labels_cort Labels_subcort 'Class']); % create table

save ADNI_table ADNI_table % save table as mat
writetable(ADNI_table,'ADNI_table.csv') % save table as csv


%% Basic ML
% This is just to get some general overview. Other ML analyses are done
% with Python (see notebook)

% Compute model for BioFIND using selected features

X = BioFIND_sdata;                    % predictors
y = BioFIND.fdsubs.fdRibbon(:,3)-1;   % outcome - used 'Ribbon' here but it doesn't matter because outcomes are the same for all schemes

mdl  = fitglm(X,y,'Distribution','binomial'); % compute model

switch Def.grouping 
    case 0    % exclude AD  
        X = ADNI_sdata(ADNI.fdsubs.fdRibbon(:,3)<3,:); 
        y = ADNI.fdsubs.fdRibbon(ADNI.fdsubs.fdRibbon(:,3)<3,3)-1;        
    case 1    % group patients (MCI+AD)   
        X = ADNI_sdata;                    % predictors
        y = ADNI.fdsubs.fdRibbon(:,3);     % outcome
        y(y==3)=2; y = y-1;
end

yhat  = predict(mdl,X); % make prediction in ADNI based on BioFIND model
yb    = discretize(yhat,0:0.5:1)-1;

% Plot confusion matrix

figure 
cm = confusionchart(confusionmat(y,yb),{'CTRL','PATIENTS'},'normalization','total-normalized');
cm.Title = sprintf('%s + %s',Def.cort,Def.subcort);


% model-free data analysis for the task
clear all;close all;clc;

%%
dataDir = './TMSVWMDATA';

subj = {'CH', 'CY', 'HK', 'HX', 'JZ', 'KD', 'LH', 'NB', 'PL', 'SW','TX', 'WX', 'XC', 'XF', 'XH','yc','YS','YW','YXC', 'ZC', 'ZL'};
brainSite = {'sham', 'V1','IPS', 'DLPFC'};
setSize = [2, 4, 6];

nSubj = numel(subj);

%% read data
allData = cell(numel(setSize), numel(brainSite));
for iSet = 1: numel(setSize)
    for iSite = 1:numel(brainSite)
        allData{iSet, iSite} = matchfiles(sprintf( '%s/*set%d*%s*.mat', dataDir, setSize(iSet),brainSite{iSite})); 
    end
end

%% read error data and calculate CSD
CSD = zeros(numel(setSize), numel(brainSite), numel(subj));

for iSet = 1:numel(setSize) % loop set size
    for iSite = 1:numel(brainSite) % loop brainSite
        files = allData{iSet, iSite};
        for  iSubj = 1:numel(subj) % loop subjects
            tmp = load(files{iSubj});
            error = tmp.results.error ;
            CSD(iSet, iSite, iSubj) = sqrt(sum(error.^2)/(numel(error)-1));            
        end
    end
end

meanCSD = mean(CSD,3);
seCSD = se(CSD,3);
%% draw figure
close all;
figure;
c0 = mycolororder([],4);
[Hb, He, xloc] = mybar3([], meanCSD', seCSD');
set(Hb,'FaceColor','none', 'LineWidth',4);
set(gca,'XTickLabels', {'2','4','6'});
xlabel('Set size');
ylabel('CSD(deg)');
for i=1:4, set(Hb(i),'EdgeColor',c0(i,:)); end
ylim([30 60]);

% plot individual subject
for iSet = 1:numel(setSize) % loop set size
    for iSite = 1:numel(brainSite) % loop brainSite
        lh=myplot(xloc(iSite,iSet), squeeze(CSD(iSet, iSite,:)),[],'ko');
        uistack(lh,'bottom');
    end
end
legend(Hb, brainSite);


%% save data table for anova
datasave = CSD;
datasave = permute(datasave, [3,1,2]);
datasave = reshape(datasave, [nSubj, numel(brainSite)*numel(setSize)]);

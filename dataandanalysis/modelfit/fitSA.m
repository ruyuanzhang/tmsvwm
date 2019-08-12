% model-free data analysis for the task
clear all;close all;clc;

%%
modelName = 'SA';
modelDir = './allmodels/SA';

dataDir = '.././TMSVWMDATA';
badsDir = '~/Documents/Code_git/bads';
addpath(genpath(modelDir));
addpath(genpath(badsDir));


%subj = {'HX','KD','LH','TX','WX','XF','XH','YS'};
subj = {'HX'};
brainSite = {'sham', 'V1','IPS', 'DLPFC'};
setSize = [2 4 6];
nSubj = numel(subj);

%% read data files
allData = cell(numel(brainSite), nSubj);
for iSite = 1:numel(brainSite) % loop brain site
    for iSubj = 1:nSubj % loop subjects       
        tmp = matchfiles(sprintf( '%s/%s*set2*%s*.mat', dataDir, subj{iSubj}, brainSite{iSite}));
        set2 = load(tmp{1});
        tmp = matchfiles(sprintf( '%s/%s*set4*%s*.mat', dataDir, subj{iSubj}, brainSite{iSite}));
        set4 = load(tmp{1});
        tmp = matchfiles(sprintf( '%s/%s*set6*%s*.mat', dataDir, subj{iSubj}, brainSite{iSite}));
        set6 = load(tmp{1});
        
        result.probe = [set2.results.probe set4.results.probe set6.results.probe];
        result.resp = [set2.results.resp set4.results.resp set6.results.resp];
        result.N = [2*ones(1,numel(set2.results.resp)) 4*ones(1,numel(set4.results.resp)) 6*ones(1,numel(set6.results.resp))];
        allData{iSite, iSubj} = result;
    end
end

%% model fitting setup
nFit = 20;  % how many random seeds and how many times to fit on subject data

% note below part should be copied to model function, just a hack for
% stupid parallel running
opt.PLB = [0, 0, 0];
opt.PUB = [500, 8, 500];
opt.LB = [0, 0, 0];
opt.UB = [500, 8, 500];
opt.options = bads('defaults');
opt.options.MaxIter = '500*nvars';

x0 = [opt.PLB(1):(opt.PUB(1)-opt.PLB(1))/(nFit-1):opt.PUB(1);
    opt.PLB(2):(opt.PUB(2)-opt.PLB(2))/(nFit-1):opt.PUB(2);
    opt.PLB(3):(opt.PUB(3)-opt.PLB(3))/(nFit-1):opt.PUB(3)];

x0=x0';  %x0,  nFit x 3 params


%% fit
fitResult = zeros(numel(brainSite), nSubj, nFit, 6); % two parameter + maxlh, AIC,BIC
for iSubj = 1:nSubj  % loop subject
    for iSite = 1:numel(brainSite) % 
        for iFit = 1:nFit %loop fit
            fprintf('Subj: %d; site: %d; Fit: %d \n',iSubj,iSite,iFit);
            
            N = allData{iSite, iSubj}.N;
            probe = allData{iSite, iSubj}.probe;
            resp = allData{iSite, iSubj}.resp;
            
            x0_tmp=x0(iFit,:);            
            [fitparams,maxlh,AIC,BIC] = fit_SA_model(N, probe, resp, x0_tmp);
            fitResult(iSite, iSubj, iFit,:) =[fitparams maxlh AIC BIC];
            disp(fitResult(iSite, iSubj, iFit))
        end
    end
end

%% clean up
rmpath(genpath(modelDir));
rmpath(genpath(badsDir));
%%
savefilename = sprintf('%s_fit%dsubj_%s.mat',modelName, nSubj, datestr(now,'yyyymmddHHMM'));
save(savefilename);
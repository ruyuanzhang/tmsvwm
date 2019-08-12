function [fitpars, max_lh, AIC, BIC] = fit_VP_model_rz(N,probe,resp,x0)

%%
data.N = N;
error = circulardiff(probe,resp,180);
error = error * pi/180;

%% discretization of the error space

error_range = linspace(0,pi/2,91); % ori exp, error_range [0, pi/2]
% input error range [-2/pi,pi/]
gvar.error_range = error_range(1:end-1)+diff(error_range(1:2))/2;

% mapping between J and kappa
gvar.kappa_max      = 700;
gvar.kappa_map      = linspace(0,gvar.kappa_max,1e5);
gvar.J_map          = gvar.kappa_map.*besseli(1,gvar.kappa_map,1)./besseli(0,gvar.kappa_map,1);

% 
gvar.nMCSamples     = 10000;                 % number of MC samples to draw when computing model predictions (Paper: 1000)
gvar.n_par          = 4;                     % number of parameters (J1bar, power, tau, kappa_r)


% get indices of errors
unique_N = unique(data.N);
for ii=1:length(unique_N)
    trial_idx = find(data.N==unique_N(ii));
    data.error_idx{ii} = interp1(gvar.error_range,1:length(gvar.error_range),abs(error(trial_idx)),'nearest','extrap');
end

%% ========= use bads to optimization ========
PLB = [0, 0, 0, 0];
PUB = [500, 10, 500, 500];
LB = [0, 0, 0, 0];
UB = [500, 20, 500, 500];
options = bads('defaults');
options.MaxIter = '500*nvars';
% do it
% compute_LLH should return the postive loglikelihood
[x,fval,exitflag,output,optimState,gpstruct] = bads(@(params) compute_LLH_VP(params, data, gvar),x0,LB,UB,PLB,PUB);


%% find ML parameter estimates
max_lh = fval; % here max_lh is a positive value, a real likelihood value should be -max_lh
%fitpars = X_mat(LLH==max_lh,:);
fitpars = x;
% compute AIC and BIC
n_free_pars = gvar.n_par - (numel(unique_N)==1);   % Jbar, tau, power, kappa_r  (3 if we have only 1 set size)
BIC = -2*-max_lh + n_free_pars*log(numel(data.N));
AIC = -2*-max_lh + 2*n_free_pars;

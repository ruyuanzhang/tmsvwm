function [fitpars, max_lh, AIC, BIC] = fit_MIX_model(N, probe,resp,x0)



%%
error = circulardiff(probe,resp,180);
error = error*pi/180;
data.N = N;

%% discretization of the error space
%error_range = linspace(0,pi,91); % color exp, error_range [0, pi], input error
%range is [-pi, pi]
error_range = linspace(0,pi/2,91); % ori exp, error_range [0, pi/2]
% input error range [-2/pi,pi/]
gvar.error_range = error_range(1:end-1)+diff(error_range(1:2))/2;
gvar.n_par       = 3;                     % number of parameters (kr_leve1,kr_level2, capacity)

% get indices of errors
unique_N = unique(data.N);
for ii=1:length(unique_N)
    trial_idx = find(data.N==unique_N(ii));
    data.error_idx{ii} = interp1(gvar.error_range,1:length(gvar.error_range),abs(error(trial_idx)),'nearest','extrap');
end


%% ========= use bads to optimization ========
PLB = [0, 0, 0];
PUB = [500, 500, 8];
LB = [0, 0, 0];
UB = [500, 500, 8];
options = bads('defaults');
options.MaxIter = '500*nvars';
% do it
% compute_LLH should return the postive loglikelihood
[x,fval,exitflag, output, optimState, gpstruct] = bads(@(params) compute_LLH_MIX(params, data, gvar),x0,LB,UB,PLB,PUB);

% find ML parameter estimates
max_lh = fval; % here max_lh is a positive value, a real likelihood value should be -max_lh
%fitpars = X_mat(LLH==max_lh,:);
fitpars = x;
% compute AIC and BIC
n_free_pars = gvar.n_par;   %
BIC = -2*-max_lh + n_free_pars*log(numel(data.N));
AIC = -2*-max_lh + 2*n_free_pars;

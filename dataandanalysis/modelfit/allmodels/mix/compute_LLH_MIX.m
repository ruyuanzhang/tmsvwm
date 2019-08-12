function LLH = compute_LLH_MIX(pars, data, gvar)
kappa_r1 = pars(1); % motor noise 1
kappa_r2 = pars(2); % motor noise 2
K = pars(3); % capacity

N_vec = unique(data.N);
K = floor(K); % K should be a discrete value;

%compute model predictions and log likelihood
LLH = 0;
for ii=1:length(N_vec)
    N = N_vec(ii); % memory load
    kappa_r = choose(N==1, kappa_r1, kappa_r2);
    p_error = zeros(length(gvar.error_range),1);
    for jj=1:length(gvar.error_range)
        if N <= K % load smaller than capacity
            p_error(jj) = 1/(2*pi*besseli0_fast(kappa_r,1)) * exp(kappa_r*cos(gvar.error_range(jj)));
        else % load exceed capacity
            p_error(jj) = (K/N)*1/(2*pi*besseli0_fast(kappa_r,1)*exp(kappa_r)) * exp(kappa_r*cos(gvar.error_range(jj))) + (1-K/N)*(0.5/90);
        end
    end
    
    % because we only consider [0,90],full distribution should be 0.5
    p_error = p_error/sum(p_error) / 2;
    %compute probabilities of reponses, take log, and sum
    p_resp = p_error(data.error_idx{ii});
    
    % calc loglikeli
    LLH = LLH + sum(log(p_resp));  % note that this LLH is a negative value
    
end

% We output postive likelihood, maximizing negative likelihood is equivalent to
% miniziming postive likelihood.
LLH = -LLH;

% This should never happen
if isnan(LLH)
    LLH = Inf;
end
end
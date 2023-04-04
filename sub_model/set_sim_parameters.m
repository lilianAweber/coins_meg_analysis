function c = set_sim_parameters( u )
% Choose parameters for simulating the eHGF_jget model

% PLACEHOLDER VALUES
% It is often convenient to set some priors to values
% derived from the inputs. This can be achieved by
% using placeholder values. The available placeholders
% are:
%
% 99991   Value of the first input
%         Usually a good choice for mux_0mu(1)
% 99992   Variance of the first 20 inputs
%         Usually a good choice for mux_0sa(1)
% 99993   Log-variance of the first 20 inputs
%         Usually a good choice for logsax_0mu(1) and mua_0mu(1)
% 99994   Log-variance of the first 20 inputs minus two
%         Usually a good choice for omxmu(1)

% Initial mus and sigmas
% Format: row vectors of length n_levels
% For all but the first level, this is usually best
% kept fixed to 1 (determines origin on x_i-scale).
c.mux_0mu = [u(1), 1];

c.logsax_0mu = [log(50), 1];%[log(var(u(1:20))), 20];

c.mua_0mu = [-1.5, 1]; % instead of 1.5, make this depend on initial diff to avg noise

c.logsaa_0mu = [3, 1];

% Kappas
% Format: row vector of length n_levels-1 (except kappa_u: scalar)
% This should be fixed (preferably to 1) if the observation model
% does not use mu_i+1 (kappa then determines the scaling of x_i+1).
c.logkaumu = 1;

c.logkaxmu = 0;

c.logkaamu = 0;
% Omegas
% Format: row vector of length n_levels (except omega_u: scalar)
%c.omumu = log(452.7);%log(375);%log(10^2);
%c.omumu = log(337.79);
c.omumu = log(375); % mean([100 100 400 900]), avg noise overall

c.omxmu = [4,   1]; % 7.5 for stable, 9 for volatile

c.omamu = [-5,   1];

% Gather prior settings in vectors
c.priormus = [
    c.mux_0mu,...
    c.logsax_0mu,...
    c.mua_0mu,...
    c.logsaa_0mu,...
    c.logkaumu,...
    c.logkaxmu,...
    c.logkaamu,...
    c.omumu,...
    c.omxmu,...
    c.omamu,...
         ];  
end
function plot_ehgf_jget_traj(r)
% Plots the estimated trajectories for the HGF perceptual model for
% the JGET project
% Usage example:  est = tapas_fitModel(responses, inputs); tapas_ehgf_plotTraj(est);
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2013-2020 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% Optional plotting of standard deviations (true or false)
plotsd = true;

% Set up display
scrsz = get(0,'screenSize');
outerpos = [0.2*scrsz(3),0.2*scrsz(4),0.8*scrsz(3),0.8*scrsz(4)];
figure(...
    'OuterPosition', outerpos,...
    'Name', 'HGF trajectories');

% Time axis
if size(r.u,2) > 1 && ~isempty(find(strcmp(fieldnames(r.c_prc),'irregular_intervals'))) && r.c_prc.irregular_intervals
    t = r.u(:,end)';
else
    t = ones(1,size(r.u,1));
end

ts = cumsum(t);
ts = [0, ts];

% Do we know the generative parameters?
if size(r.u,2) > 2
    genpar = true;
    mean   = r.u(:,2);
    sd     = r.u(:,3);
else
    genpar = false;
end

% Number of levels
try
    l = r.c_prc.n_levels;
catch
    l = length(r.p_prc.p)/8;
end


% Input level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Left subplot (x)                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2, 1, 1);

if plotsd == true
    upperprior = r.p_prc.mux_0(1) +1.96*sqrt(r.p_prc.sax_0(1));
    lowerprior = r.p_prc.mux_0(1) -1.96*sqrt(r.p_prc.sax_0(1));
    upper = [upperprior; r.traj.mux(:,1)+1.96*sqrt(r.traj.sax(:,1))];
    lower = [lowerprior; r.traj.mux(:,1)-1.96*sqrt(r.traj.sax(:,1))];
    
    plot(0, upperprior, 'or', 'LineWidth', 1);
    hold all;
    plot(0, lowerprior, 'or', 'LineWidth', 1);
    fill([ts, fliplr(ts)], [(upper)', fliplr((lower)')], ...
         'r', 'EdgeAlpha', 0, 'FaceAlpha', 0.15);
end
plot(ts, [r.p_prc.mux_0(1); r.traj.mux(:,1)], 'r', 'LineWidth', 1.5);
hold all;
plot(0, r.p_prc.mux_0(1), 'or', 'LineWidth', 1.5); % prior
plot(ts(2:end), r.u(:,1), '.', 'Color', [0 0.6 0]); % inputs
if genpar
    plot(ts(2:end), mean, '-', 'Color', 'k', 'LineWidth', 1); % mean of input distribution
    plot(ts(2:end), mean +1.96.*sd, '--', 'Color', 'k', 'LineWidth', 1); % 95% interval of input distribution
    plot(ts(2:end), mean -1.96.*sd, '--', 'Color', 'k', 'LineWidth', 1); % 95% interval of input distribution
end
xlim([0 ts(end)]);
title(['Input u (green) and posterior expectation of x_1 (red) for \kappa_x=', ...
       num2str(r.p_prc.kax), ', \omega_x=', num2str(r.p_prc.omx)], 'FontWeight', 'bold');
ylabel('u, \mu x_1');
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Right subplot (alpha)                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2, 1, 2);

if plotsd == true
    upperprior = r.p_prc.mua_0(1) +1.96*sqrt(r.p_prc.saa_0(1));
    lowerprior = r.p_prc.mua_0(1) -1.96*sqrt(r.p_prc.saa_0(1));
    upper = [upperprior; r.traj.mua(:,1)+1.96*sqrt(r.traj.saa(:,1))];
    lower = [lowerprior; r.traj.mua(:,1)-1.96*sqrt(r.traj.saa(:,1))];

    transupperprior = sqrt(exp(r.p_prc.kau *upperprior +r.p_prc.omu));
    translowerprior = sqrt(exp(r.p_prc.kau *lowerprior +r.p_prc.omu));
    transupper = sqrt(exp(r.p_prc.kau *upper +r.p_prc.omu));
    translower = sqrt(exp(r.p_prc.kau *lower +r.p_prc.omu));

    plot(0, transupperprior, 'or', 'LineWidth', 1);
    hold all;
    plot(0, translowerprior, 'or', 'LineWidth', 1);
    fill([ts, fliplr(ts)], [(transupper)', fliplr((translower)')], ...
         'r', 'EdgeAlpha', 0, 'FaceAlpha', 0.15);
end
transmuaprior = sqrt(exp(r.p_prc.kau *r.p_prc.mua_0(1) +r.p_prc.omu));
plot(ts, [transmuaprior; sqrt(exp(r.p_prc.kau *r.traj.mua(:,1) +r.p_prc.omu))], 'r', 'LineWidth', 1.5);
hold all;
plot(0, transmuaprior, 'or', 'LineWidth', 1.5); % prior
if genpar
    plot(ts(2:end), sd, '--', 'Color', 'k', 'LineWidth', 1);
end
xlim([0 ts(end)]);
title(['Belief on noise (red) for \kappa_\alpha=', ...
       num2str(r.p_prc.kaa), ', \omega_\alpha=', num2str(r.p_prc.oma)], 'FontWeight', 'bold');
ylabel('\mu \alpha_1');
hold off;


end

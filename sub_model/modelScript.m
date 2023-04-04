% Simulate some HGFs
addpath('/home/lil/sfw/tapas/tapas-master/HGF')
iBlock = 2;

laser = session.blocks(iBlock).stim.valueVector;
trueMean = session.blocks(iBlock).stim.meanValueVector;
trueSD = session.blocks(iBlock).stim.stdValueVector;

switch session.blocks(iBlock).blockType
    case 'lo'
        condition = 'stable';
    case 'hi'
        condition = 'volatile';
end

figure; 
subplot(2, 1, 1)
plot(laser);
hold on
plot(trueMean, 'linewidth', 2);
title(['Laser trajectory for block ' num2str(iBlock) ', ' condition]);
subplot(2, 1, 2)
plot(trueSD);
ylim([0 40])
title('True noise levels');

clear u

cp = [1; find(diff(laser)~=0)];
u(:, 1) = laser(cp);
u(:, 2) = trueMean(cp);
u(:, 3) = trueSD(cp);

c = set_sim_parameters(u);
sim = tapas_simModel(u, 'tapas_ehgf_jget', c.priormus, 'tapas_gaussian_obs', 0.005);
tapas_ehgf_jget_plotTraj(sim);
plot_ehgf_jget_traj(sim);
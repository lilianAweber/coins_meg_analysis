for iSess = 1:4
    for iBl = 1: 4
        blockData = subData(subData.sessID == iSess & subData.blockID == iBl, :);
        figure;
        shield = unwrap(blockData.shieldRotation*pi/180); 
        laser = unwrap(blockData.laserRotation*pi/180);
        trueMean = unwrap(blockData.trueMean*pi/180);
        plot(shield)
        %yline(2*pi)
        %yline(0)
        %hold on; plot(subData.blockID)
        %hold on; plot(unwrap(mod(subData.shieldRotation,360)*pi/180))
        hold on; plot(laser)
        hold on; plot(trueMean, 'linewidth', 2, 'color', [0 0.5 0])
        title({['laser start = ' num2str(laser(1))], ...
            ['diff start = ' num2str(shield(1)-laser(1))]});
        
        if sum(abs(shield-laser)) > sum(abs(shield-(laser+2*pi)))
            laser = laser + 2*pi;
            trueMean = trueMean + 2*pi;
            figure;
            plot(shield)
            hold on; plot(laser)
            hold on; plot(trueMean, 'linewidth', 2, 'color', [0 0.5 0])
            title('Corrected laser');
        end
    end
end
function [ h, p ] = coins_plot_rt_subplots( group, data, flag )

%cols = coins_colours;
%markerSize = 4;
jitter = 0.1;

h = notBoxPlot(data, group, 'jitter', jitter, 'markMedian', true);
xlim([0.05 1.15]);
%xticklabels({''})
%yticklabels({''});
ax = gca;
ax.TickLength = [0.02 0.05];
ax.LineWidth = 1.5;
box off

if flag
    hold on; 
    p = plot(unique(group), unique(group), '^', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'w');
end
%title('Hit rates')
%{
%h1(1).data.Color = [1 1 1];
h(1).data.MarkerSize = markerSize;
h(1).data.MarkerFaceColor = cols.lowVarLowCoh;
h(1).mu.Color = [0 0 0];
h(1).med.Color = [1 1 1];
h(1).med.LineStyle = '-';
h(1).semPtch.FaceColor = cols.lowVarLowCoh;
h(1).semPtch.EdgeColor = cols.lowVarLowCoh;
h(1).sdPtch.FaceColor = cols.lowVarLowCoh;
h(1).sdPtch.FaceAlpha = 0.5;
h(1).sdPtch.EdgeColor = cols.lowVarLowCoh;

%h1(2).data.Color = [1 1 1];
h(2).data.MarkerSize = markerSize;
h(2).data.MarkerFaceColor = cols.lowVar;
h(2).mu.Color = [0 0 0];
h(2).med.Color = [1 1 1];
h(2).med.LineStyle = '-';
h(2).semPtch.FaceColor = cols.lowVar;
h(2).semPtch.EdgeColor = cols.lowVar;
h(2).sdPtch.FaceColor = cols.lowVar;
h(2).sdPtch.FaceAlpha = 0.5;
h(2).sdPtch.EdgeColor = cols.lowVar;

%h1(3).data.Color = [1 1 1];
h(3).data.MarkerSize = markerSize;
h(3).data.MarkerFaceColor = cols.highVarLowCoh;
h(3).mu.Color = [0 0 0];
h(3).med.Color = [1 1 1];
h(3).med.LineStyle = '-';
h(3).semPtch.FaceColor = cols.highVarLowCoh;
h(3).semPtch.EdgeColor = cols.highVarLowCoh;
h(3).sdPtch.FaceColor = cols.highVarLowCoh;
h(3).sdPtch.FaceAlpha = 0.5;
h(3).sdPtch.EdgeColor = cols.highVarLowCoh;

%h1(4).data.Color = [1 1 1];
h(4).data.MarkerSize = markerSize;
h(4).data.MarkerFaceColor = cols.highVar;
h(4).mu.Color = [0 0 0];
h(4).med.Color = [1 1 1];
h(4).med.LineStyle = '-';
h(4).semPtch.FaceColor = cols.highVar;
h(4).semPtch.EdgeColor = cols.highVar;
h(4).sdPtch.FaceColor = cols.highVar;
h(4).sdPtch.FaceAlpha = 0.5;
h(4).sdPtch.EdgeColor = cols.highVar;
%}

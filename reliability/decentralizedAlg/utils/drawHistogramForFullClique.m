function drawHistogramForFullClique(figPrefix, cliques) 
    figure3 = figure;

    weightDistribution = [];
    maxEdgeDistribution = [];
    averageEdgeDistribution = [];

    averageTemplate = "Average: %f";

    for i = 1:size(cliques, 2)
        clique = cliques{i};
        weightDistribution = [weightDistribution, clique(3)];
        maxEdgeDistribution = [maxEdgeDistribution, clique(5)];
        averageEdgeDistribution = [averageEdgeDistribution, clique(6)];
    end

    subplot(1, 3, 1)
    h1 = histogram(weightDistribution);
    meanForWeight = mean(weightDistribution(:));

    yl = ylim;
    text(meanForWeight, 0.9*yl(2), sprintf(averageTemplate, meanForWeight), 'Color', 'k', ...
	'FontWeight', 'bold', 'FontSize', 8, ...
	'EdgeColor', 'b');

    xlabel('weight of cliques')
    ylabel('number of cliques')
    title('Group Weight')


    subplot(1, 3, 2)
    h2 = histogram(maxEdgeDistribution);
    meanForMaxEdge = mean(maxEdgeDistribution(:));

    yl = ylim;
    text(meanForMaxEdge, 0.9*yl(2), sprintf(averageTemplate, meanForMaxEdge), 'Color', 'k', ...
	'FontWeight', 'bold', 'FontSize', 8, ...
	'EdgeColor', 'b');

    xlabel('weight of max edges')
    % ylabel('number of cliques')
    title('Max Edge')

    subplot(1, 3, 3)
    h3 = histogram(averageEdgeDistribution);
    meanForAvgEdge = mean(averageEdgeDistribution(:));

    yl = ylim;
    text(meanForAvgEdge, 0.9*yl(2), sprintf(averageTemplate, meanForAvgEdge), 'Color', 'k', ...
	'FontWeight', 'bold', 'FontSize', 8, ...
	'EdgeColor', 'b');
    xlabel('weight of average edges')
    % ylabel('number of cliques')
    title('Average Edge')
    

    filename = sprintf("%s-%s.jpg", figPrefix, "hist-StatForFinalRound");
    saveas(figure3, filename);
end
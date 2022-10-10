
function drawHistogramForEdgeWeight(figPrefix, minWeights, maxWeights, averageWeights) 
    figure3 = figure;

    subplot(1, 3, 1)
    h1 = histogram(minWeights);
    % xlabel('weight of edges')
    ylabel('number of cliques')
    title('Minimum Edge')


    subplot(1, 3, 2)
    h2 = histogram(maxWeights);
    xlabel('weight of edges')
    % ylabel('number of cliques')
    title('Max Edge')

    subplot(1, 3, 3)
    h3 = histogram(averageWeights);
    % xlabel('weight of edges')
    % ylabel('number of cliques')
    title('Average Edge')

    filename = sprintf("%s-%s.jpg", figPrefix, "hist-EdgeWeight");
    saveas(figure3, filename);
end
function drawHistogramForWeightDistribution(figPrefix, weightsForFirstRound, weightsForMiddleRound, weightsForLastRound) 
    figure3 = figure;

    subplot(1, 3, 1)
    h1 = histogram(weightsForFirstRound);
    % xlabel('weight of edges')
    ylabel('number of cliques')
    title('First Round')


    subplot(1, 3, 2)
    h2 = histogram(weightsForMiddleRound);
    xlabel('weight of cliques')
    % ylabel('number of cliques')
    title('Middle Round')

    subplot(1, 3, 3)
    h3 = histogram(weightsForLastRound);
    % xlabel('weight of edges')
    % ylabel('number of cliques')
    title('Last Round')

    filename = sprintf("%s-%s.jpg", figPrefix, "hist-WeightDistribution");
    saveas(figure3, filename);
end
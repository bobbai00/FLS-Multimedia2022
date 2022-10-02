function drawHistogram(minWeights, maxWeights, averageWeights)
    subplot(1, 3, 1)
    h1 = histogram(minWeights)
    xlabel('weight of edges')
    ylabel('number of cliques')
    title('Distribution of minimum edge weight for each clique')


    subplot(1, 3, 2)
    h2 = histogram(maxWeights)
    xlabel('weight of edges')
    ylabel('number of cliques')
    title('Distribution of maximum edge weight for each clique')

    subplot(1, 3, 3)
    h3 = histogram(averageWeights);
    xlabel('weight of edges')
    ylabel('number of cliques')
    title('Distribution of average edge weight for each clique')

end
function reportDecentralizedStats(figPrefix, cliqueStatByRounds, G)
    numberOfFlsInGroupForRounds = {};
    weightOfCliquesForRounds = {};
    portionOfFullCliquesForRounds = [];
    minWeightCliquesForRounds = [];
    averageWeightCliquesForRounds = [];
    maxWeightCliquesForRounds = [];

    for i = 1:size(cliqueStatByRounds, 2)
        cliqueStats = cliqueStatByRounds{i};
        numOfFullCliques = 0;
        numOfFlsOfCliques = [];
        weightOfCliques = [];
        for j = 1:size(cliqueStats, 2)
            clique = cliqueStats{j};
            numFLSs = clique(2);
            weight = clique(3);
            if numFLSs >= G
                numOfFullCliques = numOfFullCliques + 1;
            end
            numOfFlsOfCliques(j) = numFLSs;
            weightOfCliques(j) = weight;
        end
        portionOfFullCliquesForRounds(i) = numOfFullCliques * 100.0 / (size(cliqueStats, 2) * 1.0);
        numberOfFlsInGroupForRounds{i} = numOfFlsOfCliques;
        weightOfCliquesForRounds{i} = weightOfCliques;
    end

    cliqueIDsForFinalRound = cliqueStatByRounds{end};
    for i = 1:size(cliqueIDsForFinalRound, 2)
        clique = cliqueStats{i};
        minWeightCliquesForRounds(i) = clique(4);
        maxWeightCliquesForRounds(i) = clique(5);
        averageWeightCliquesForRounds(i) = clique(6);
    end

    firstRoundNumFlsInClique = numberOfFlsInGroupForRounds{1};
    midRoundNumFlsInClique = numberOfFlsInGroupForRounds{floor(size(cliqueStatByRounds, 2) / 2)};
    lastRoundNumFlsInClique = numberOfFlsInGroupForRounds{end};
    
    firstRoundWeightsInClique = weightOfCliquesForRounds{1};
    midRoundWeightsInClique = weightOfCliquesForRounds{floor(size(cliqueStatByRounds, 2) / 2)};
    lastRoundWeightsInClique = weightOfCliquesForRounds{end};

    filename = sprintf("%s/var.mat", figPrefix);
    save(filename);
    
    graphPrefix = sprintf("%s/graph-", figPrefix);
    drawLineGraphForPortionOfFLSsInClique(graphPrefix, 1, size(cliqueStatByRounds, 2), 5, portionOfFullCliquesForRounds)
    drawHistogramForNumFLS(graphPrefix, firstRoundNumFlsInClique, midRoundNumFlsInClique, lastRoundNumFlsInClique);
    drawHistogramForEdgeWeight(graphPrefix, minWeightCliquesForRounds, maxWeightCliquesForRounds, averageWeightCliquesForRounds);
    drawHistogramForWeightDistribution(graphPrefix, firstRoundWeightsInClique, midRoundWeightsInClique, lastRoundWeightsInClique);
end
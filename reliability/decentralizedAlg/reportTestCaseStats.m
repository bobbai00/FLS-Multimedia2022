function reportTestCaseStats(figPrefix, cliqueStatByRounds, G, cliqueList)
    numberOfFlsInGroupForRounds = {};
    weightOfCliquesForRounds = {};
    portionOfFullCliquesForRounds = [];
    minWeightCliquesForRounds = [];
    averageWeightCliquesForRounds = [];
    maxWeightCliquesForRounds = [];

    maxEdgeOfCliqueOfDifferentCard = cell(1, G);
    weightOfCliqueOfDifferentCard = cell(1, G);

    for i = 1:size(cliqueStatByRounds, 2)
        cliqueStats = cliqueStatByRounds{i};
        numOfFullCliques = 0;
        numOfFlsOfCliques = [];
        weightOfCliques = [];
        for j = 1:size(cliqueStats, 2)
            clique = cliqueStats{j};
            numFLSs = clique(2);
            weight = clique(3);
            if clique(end)
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
        numOfFls = clique(2);
        weightOfClique = clique(3);
        minWeightCliquesForRounds(i) = clique(4);
        maxWeightCliquesForRounds(i) = clique(5);
        averageWeightCliquesForRounds(i) = clique(6);

        maxEVect = maxEdgeOfCliqueOfDifferentCard{numOfFls};
        maxEVect = [maxEVect, maxWeightCliquesForRounds(i)];
        maxEdgeOfCliqueOfDifferentCard{numOfFls} = maxEVect;

        weightVect = weightOfCliqueOfDifferentCard{numOfFls};
        weightVect = [weightVect, weightOfClique];
        weightOfCliqueOfDifferentCard{numOfFls} = weightVect;
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
    if G==5
        w2 = weightOfCliqueOfDifferentCard{2}
        w3 = weightOfCliqueOfDifferentCard{3}
        w4 = weightOfCliqueOfDifferentCard{4}
        w5 = weightOfCliqueOfDifferentCard{5}
        drawWeightHistFor4CliqueSize(figPrefix, w2, w3, w4, w5);

        e2 = maxEdgeOfCliqueOfDifferentCard{2}
        e3 = maxEdgeOfCliqueOfDifferentCard{3}
        e4 = maxEdgeOfCliqueOfDifferentCard{4}
        e5 = maxEdgeOfCliqueOfDifferentCard{5}
        drawMaxEdgeHistFor4CliqueSize(figPrefix, e2, e3, e4, e5);
    elseif G==3
        w2 = weightOfCliqueOfDifferentCard{2}
        w3 = weightOfCliqueOfDifferentCard{3}
        drawWeightHistFor2CliqueSize(figPrefix, w2, w3);

        e2 = maxEdgeOfCliqueOfDifferentCard{2}
        e3 = maxEdgeOfCliqueOfDifferentCard{3}
        drawMaxEdgeHistFor2CliqueSize(figPrefix, e2, e3);
    end
end
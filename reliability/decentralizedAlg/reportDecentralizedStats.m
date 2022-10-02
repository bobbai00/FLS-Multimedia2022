function reportDecentralizedStats(cliqueIDsByRounds, numOfFls, G, cliqueList)
    numberOfFlsInGroupForRounds = {};
    numberOfFullCliquesForRounds = [];
    minWeightCliquesForRounds = [];
    averageWeightCliquesForRounds = [];
    maxWeightCliquesForRounds = [];

    for i = 1:size(cliqueIDsByRounds, 2)
        cliqueIDs = cliqueIDsByRounds{i};
        numOfFullCliques = 0;
        numOfFlsOfCliques = [];
        for j = 1:size(cliqueIDs, 2)
            clique = cliqueList(j);
            if clique.isCliqueFull()
                numOfFullCliques = numOfFullCliques + 1;
            end
            numOfFlsOfCliques = [numOfFlsOfCliques, clique.numFLSs]
        end
        numberOfFullCliquesForRounds = [numberOFFullCliquesForRounds, numOfFullCliques];
        numberOfFlsInGroupForRounds{i} = numOfFlsOfCliques;
    end

    cliqueIDsForFinalRound = cliqueIDsByRounds{end};
    for i = 1:size(cliqueIDsForFinalRound, 2)
        cid = cliqueIDsForFinalRound(i);
        clique = cliqueList(cid);
        minWeightCliquesForRounds(i) = clique.getMinWeightEdge();
        maxWeightCliquesForRounds(i) = clique.getMaxWeightEdge();
        averageWeightCliquesForRounds(i) = clique.getAverageWeightEdge();
    end
end
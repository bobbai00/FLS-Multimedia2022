function [reliabilityGroups, verticesHaveNoGroup] = gfGroupFirstBruteForce(cube, G, vertexList)

reliabilityGroups = [];
verticesHaveNoGroup = [];

assignedVertices = cube.assignedVertices;
numberOfVerticesToChoose = G;

if cube.parentID == -1
    numberOfVerticesToChoose = size(assignedVertices, 2);
    if numberOfVerticesToChoose == 0
        return;
    end
end

allPossibleCombinations = nchoosek(assignedVertices, numberOfVerticesToChoose);

minWeight = intmax;

for i = 1:size(allPossibleCombinations, 1)
    subset = allPossibleCombinations(i,:);
    rg = reliabilityGroup(cube.identity, G, subset, vertexList);
    rg.regardCenterAsStandbyFls(vertexList)
    
    if rg.weight < minWeight
        reliabilityGroups = rg;
        minSubset = subset;
    end
end

verticesHaveNoGroup = setxor(minSubset, assignedVertices);


end


function reportReliabilityGroupStats(reliabilityGroups, vertexList, G, mttfForFlsInMinute, mttrForFlsInMinute)

fprintf("Reliability Group Statistics\n")

minStandbyFlsFlyingDistances = intmax;
maxStandbyFlsFlyingDistances = 0;
minStandbyFlsGroupIndex = 0;
maxStandbyFlsGroupIndex = 0;

minGroupWeight = intmax;
maxGroupWeight = 0;
minGroupWeightIndex = 0;
maxGroupWeightIndex = 0;

minGroupVerticesNum = intmax;
maxGroupVerticesNum = 0;
minGroupVerticesNumIndex = 0;
maxGroupVerticesNumIndex = 0;

minReliabilityGroupVerticesNumber = intmax;
maxReliabilityGroupVerticesNumber = 0;

totalStandbyFlsFlyingDistances = 0.0;
totalGroupWeight = 0.0;
totalPoints = 0;

minMTTFForGroupInMinute = intmax;
maxMTTFForGroupInMinute = 0;
totalMTTFofGroups = 0.0;

for i=1:size(reliabilityGroups, 2)
    group = reliabilityGroups(i);
    group.calculateTotalStandbyFlsFlyingDistance(vertexList);
    

    mttfForGroup = group.getMTTFInMinute(mttfForFlsInMinute, mttrForFlsInMinute);
    maxStandbyFlyingDist = group.getMaxStandbyFlsFlyingDistance(vertexList);
    minStandbyFlyingDist = group.getMinStandbyFlsFlyingDistance(vertexList);

    totalPoints = totalPoints + size(group.assignedFLSs, 2);
    totalMTTFofGroups = totalMTTFofGroups + mttfForGroup;
    totalStandbyFlsFlyingDistances = group.getAvgStandbyFlsFlyingDistance(vertexList) + totalStandbyFlsFlyingDistances;
    totalGroupWeight = totalGroupWeight + group.weight;

    if size(group.assignedFLSs, 2) > maxReliabilityGroupVerticesNumber
        maxReliabilityGroupVerticesNumber = size(group.assignedFLSs, 2);
    end
    
    if size(group.assignedFLSs, 2) < minReliabilityGroupVerticesNumber
        minReliabilityGroupVerticesNumber = size(group.assignedFLSs, 2);
    end

    if maxStandbyFlyingDist > maxStandbyFlsFlyingDistances
        maxStandbyFlsFlyingDistances = maxStandbyFlyingDist;
        maxStandbyFlsGroupIndex = i;
    end

    if minStandbyFlyingDist < minStandbyFlsFlyingDistances
        minStandbyFlsFlyingDistances = minStandbyFlyingDist;
        minStandbyFlsGroupIndex = i;
    end

    if group.weight > maxGroupWeight
        maxGroupWeightIndex = i;
        maxGroupWeight = group.weight;
    end
    
    if group.weight < minGroupWeight
        minGroupWeightIndex = i;
        minGroupWeight = group.weight;
    end
    
    if mttfForGroup > maxMTTFForGroupInMinute
        maxMTTFForGroupInMinute = mttfForGroup;
    end

    if mttfForGroup < minMTTFForGroupInMinute
        minMTTFForGroupInMinute = mttfForGroup;
    end

    if group.getNumberOfVertices() < minGroupVerticesNum
        minGroupVerticesNumIndex = i;
        minGroupVerticesNum = group.getNumberOfVertices();
    end

    if group.getNumberOfVertices() > maxGroupVerticesNum
        maxGroupVerticesNumIndex = i;
        maxGroupVerticesNum = group.getNumberOfVertices();
    end
end

fprintf("Total Reliability Group Number = %d, G: %d\n", size(reliabilityGroups, 2), G);

fprintf("Total Points = %d\n", totalPoints);
fprintf("Min Reliability Group Vertices Number = %d, Group Index: %d\n", minGroupVerticesNum, minGroupVerticesNumIndex);
fprintf("Max Reliability Group Vertices Number = %d, Group Index: %d\n", maxGroupVerticesNum, maxGroupVerticesNumIndex);

fprintf("Min Standby FLS Flying Distance = %f, Group Index = %d\n", minStandbyFlsFlyingDistances, minStandbyFlsGroupIndex);
fprintf("Max Standby FLS Flying Distance = %f, Group Index = %d\n", maxStandbyFlsFlyingDistances, maxStandbyFlsGroupIndex);
fprintf("Average Standby FLS Flying Distance = %f\n", totalStandbyFlsFlyingDistances / size(reliabilityGroups, 2));

fprintf("Min Group Weight = %f, Group Index = %d\n", minGroupWeight, minGroupWeightIndex);
fprintf("Max Group Weight = %f, Group Index = %d\n", maxGroupWeight, maxGroupWeightIndex);
fprintf("Average Group Weight Distance = %f\n", totalGroupWeight / size(reliabilityGroups, 2));


fprintf("Min MTTFgroup = %f minutes\n", minMTTFForGroupInMinute);
fprintf("Max MTTFgroup = %f minutes\n", maxMTTFForGroupInMinute);
fprintf("Average MTTFgroup = %f minutes\n", totalMTTFofGroups / size(reliabilityGroups, 2));

end


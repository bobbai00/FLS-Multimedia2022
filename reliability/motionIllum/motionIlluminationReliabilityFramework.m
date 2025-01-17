function [reliabilityGroups] = motionIlluminationReliabilityFramework(numFiles, cubeCapacity, doReset)

    silent = false;

    TravelPaths={};
    totalIntraTravelDistance=[];
    totalInterTravelDistance=[];
    totalIntraFlights=[];
    totalInterFlights=[];
    ColorChanges={};
    
    % reliability
    rcubeByPointClouds={};

    % pathToCloudPointFiles='/Users/baijiadong/Desktop/shaharam-lab/FLS-Multimedia2022/TestClip/';
    pathToCloudPointFiles='/Users/baijiadong/Desktop/shaharam-lab/FLS-Multimedia2022/RoseClip/';
    
    % Read the cubes in memory
    cpa=inMemoryCP(pathToCloudPointFiles,numFiles);
    
    % Use Motill to construct the grids on the first point cloud
    cpa{1}.createGrid(doReset, silent, cubeCapacity, 0, 0, 0, 0);
    
    % Use the grid of the first cloud point for the subsequent point clouds
    % and compute travel paths
    if numFiles > 1
        for i=2:numFiles
            cpa{i}.createGrid(doReset, silent, cubeCapacity, cpa{1}.llArray, cpa{1}.hlArray, cpa{1}.dlArray,cpa{1}.cubes);
            
            originalVertexList = copy(cpa{i-1}.vertexList);
            originalCubes = copy(cpa{i-1}.cubes);

            diffTbl=utilCubeCmpTwoPCs(cpa{i-1}, cpa{i});
            [ TravelPaths{i-1}, totalIntraTravelDistance(i-1), totalInterTravelDistance(i-1), totalIntraFlights(i-1), totalInterFlights(i-1), ColorChanges{i-1} ] = algCubeChangeIntRAFirst(diffTbl, cpa{i-1}, cpa{i}, false, false)
            
        end
    end



end

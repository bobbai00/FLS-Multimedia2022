function [reliabilityGroups, verticesHaveNoGroup] = gfGroupFirstMultilevelMatching(pointCloud, cubeList, currentCubeID, G, Delta)
    vertexList = pointCloud.vertexList;
    cube = cubeList(currentCubeID);

    verticesHaveNoGroup = cube.assignedVertices;
    reliabilityGroups = [];

    if (cube.hasChildren())
        childrenIDs = cube.childrenIDs;
        
        for i = 1:size(childrenIDs, 2)
            cid = childrenIDs(i);
            [rg, uv] = centralizedGroupFormation(pointCloud, cubeList, cid, G);
            reliabilityGroups = [reliabilityGroups, rg];
            verticesHaveNoGroup = [verticesHaveNoGroup, uv];
        end
    end

    % update cube
    cube = cube.updateVerticesFromChildren(verticesHaveNoGroup, vertexList);

    if (cube.numVertices < G-Delta && cube.parentID ~= -1)
        return;
    end

    if size(cube.assignedVertices, 2) == 0
        return;
    end

    isEnd = 0;

    edgeSet = [];
    graphVertexSet = [];


    for i = 1:numVertices
        vid = cube.assignedVertices(i)
        v = vertexList{vid};
        gv = graphVertex(i, v);
        graphVertexSet(i) = gv;
    end

    while ~isEnd
        edgeSet = [];
        
        numOfEdge = 0;
        numOfVertices = size(graphVertexSet, 2);
        % compute the edge set
        for i = 1:size(graphVertexSet, 2)
            gv1 = graphVertexSet(i);
            for j = i+1 : size(graphVertexSet, 2)
                gv2 = graphVertexSet(j);
                numOfEdge = numOfEdge + 1;
                edgeSet(numOfEdge) = [i;j;gv1.distance(gv2, vertexList)];
            end
        end
        
        g = graph();
        g.initWithEdges(edgeSet, numOfVertices);

        m = matching(g, G);
        [matchedEdges, o] = m.solveMinimumWeightPerfectMatching();

        
        for i = 1:size(matchedEdges, 2)
            e = matchedEdges(i);

        end
    end

end


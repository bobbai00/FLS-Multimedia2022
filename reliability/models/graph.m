classdef graph < handle
    
    properties
        graphVertexList;
        edges
        edgeIndex
        numberOfVertices {mustBeInteger} = 0;
        numberOfEdges {mustBeInteger} = 0;
        adjMat;
        costOfEdges = [];
    end
    
    methods

        function r = getCostOfEdges(obj)
            r = obj.costOfEdges;
            
        end
        function obj = initGraphWithVertices(obj, vertices, vertexList)
            for i=1:size(vertices, 2)
                v = vertices(i);
                gv = graphVertex(v);
                gv.identity = i;
                obj.graphVertexList(i) = gv;
            end
            obj.numberOfVertices = size(vertices, 2);
            
            obj.adjMat = zeros(obj.numberOfVertices, obj.numberOfVertices);
            obj.edgeIndex = zeros(obj.numberOfVertices, obj.numberOfVertices);

            obj.numberOfEdges = 0;
            
            
            for i=1:obj.numberOfVertices
                for j=1:obj.numberOfVertices
                    if i ~= j 
                        u = obj.graphVertexList(i);
                        v = obj.graphVertexList(j);
                        dist = u.distance(v, vertexList);
                        obj.adjMat(i, j) = dist;
                        obj.adjMat(j, i) = dist;
                    end
                end
            end

            for i = 1:obj.numberOfVertices
                for j = i:obj.numberOfVertices
                    obj.edges(obj.numberOfEdges + 1) = [i;j;obj.adjMat(i,j)];
                    obj.numberOfEdges = obj.numberOfEdges + 1;

                    obj.edgeIndex(i,j) = obj.numberOfEdges;
                    obj.edgeIndex(j,i) = obj.numberOfEdges;
                end
            end
        end

        function obj = initWithEdges(obj, edges, numOfVertices)
            obj.adjMat = {};
            obj.numberOfEdges = 0;
            obj.edgeIndex = zeros(size(edges, 2), size(edges, 2));
            obj.costOfEdges = [];
            obj.edges = edges;

            maxNodeIndex = 0;
            for i = 1:numOfVertices
                obj.adjMat{i} = [];
            end
            for i = 1:size(edges, 2)
                e = edges(:, i);
                u = e(1);
                v = e(2);
                cost = e(3);
                
                obj.adjMat{u} = [obj.adjMat{u}, v];
                obj.adjMat{v} = [obj.adjMat{v}, u];

                obj.edgeIndex(u, v) = i;
                obj.edgeIndex(v, u) = i;
                obj.costOfEdges(i) = cost;
            end

            obj.numberOfVertices = numOfVertices;
            obj.numberOfEdges = size(edges, 2);
        end

        function idx = getEdgeIndex(obj, u, v)
            n = obj.numberOfVertices;
            if u > n || v > n
                error("vertex does not exist");
            end

            if obj.edgeIndex(u, v) == -1
                error("edge does not exist");
            end

            idx = obj.edgeIndex(u, v);
            if idx == 0
                error("Error: edge should not be equal to 0");
            end
        end

        function e = getEdge(obj, edgeIndex)
            if edgeIndex > obj.numberOfEdges
                error("Error: edge index exceeds the maximum edge number");
            end
            
            e = obj.edges(:, edgeIndex);
        end

        function r = getAdjList(obj, nodeIndex)
            if nodeIndex > obj.numberOfVertices
                error("Error node index exceeds the maximum vertex number");
            end

            r = obj.adjMat{nodeIndex};
        end

        
    end
end


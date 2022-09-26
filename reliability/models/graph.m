classdef graph < handle
    
    properties
        graphVertexList;
        edges
        edgeIndex
        numberOfVertices {mustBeInteger} = 0;
        numberOfEdges {mustBeInteger} = 0;
        adjMat;
    end
    
    methods
        function obj = graph(vertices, vertexList)
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
                        u = graphVertexList(i);
                        v = graphVertexList(j);
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

        
    end
end


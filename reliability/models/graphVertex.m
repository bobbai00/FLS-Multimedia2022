classdef graphVertex < handle
    
    properties
        identity {mustBeInteger} = -1;
        vertices {mustBeInteger} = []
        numVertices {mustBeInteger} = 0
    end
    
    methods
        function obj = graphVertex(vertices)
            obj.vertices = vertices;
            obj.numVertices = size(vertices, 2);
        end

        function dist = distance(obj, anotherGraphVertix, vertexList)
            vertices1 = obj.vertices;
            vertices2 = anotherGraphVertix.vertices;

            CombOfVertices = combvec(vertices1, vertices2);

            dist = 0.0;

            for i=1:size(CombOfVertices, 2)
                v1 = vertexList{CombOfVertices(1, i)};
                v2 = vertexList{CombOfVertices(2, i)};
                coor1 = [v1(1), v1(2), v1(3)];
                coor2 = [v2(1), v2(2), v2(3)];
                

                dist = dist + pdist([coor1;coor2]);
            end

            dist = dist / size(CombOfVertices, 2);
        end
    end
end


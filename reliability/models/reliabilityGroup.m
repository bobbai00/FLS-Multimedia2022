classdef reliabilityGroup < handle
    
    properties
        identity {mustBeNumeric} = -1
        G {mustBeInteger} = 0

        % 1 for replication, 2 for parity
        dataRedundancyTechnique = 1
        assignedFLSs
        weight = 0.0
        cubeID {mustBeInteger} = -1
        
        widthLineSegment {mustBeNumeric} = []
        heightLineSegment {mustBeNumeric} = []
        depthLineSegment {mustBeNumeric} = []

        standbyFLSCoordinate
        distanceBetweenStandby = 0.0

    end
    
    methods
        function obj = reliabilityGroup(cubeID, G, verticesToAssign, vertexList)
            obj.cubeID = cubeID;
            obj.G = G;
            
            maxW = 0.0;
            maxH = 0.0;
            maxD = 0.0;
            minW = realmax;
            minH = realmax;
            minD = realmax;
            multiplier=1.0;

            for i = 1:size(verticesToAssign, 2)

                gv = graphVertex(verticesToAssign(i));
                
                assignedFLSs(i) = gv;

                vertexCoor = vertexList{verticesToAssign(i)};
                
                % find the maximum W, H, D coordinates
                if vertexCoor(1)*multiplier > maxW
                    maxW = vertexCoor(1)*multiplier;
                end
                if vertexCoor(2)*multiplier > maxH
                    maxH = vertexCoor(2)*multiplier;
                end
                if vertexCoor(3)*multiplier > maxD
                    maxD = vertexCoor(3)*multiplier;
                end
            
                % find the minimum W, H, D coordinates
                if vertexCoor(1)*multiplier < minW
                    minW = vertexCoor(1)*multiplier;
                end
                if vertexCoor(2)*multiplier < minH
                    minH = vertexCoor(2)*multiplier;
                end
                if vertexCoor(3)*multiplier < minD
                    minD = vertexCoor(3)*multiplier;
                end
            end
            obj.assignedFLSs = assignedFLSs;
            obj.widthLineSegment = [minW, maxW];
            obj.heightLineSegment = [minH, maxH];
            obj.depthLineSegment = [minD, maxD];

            obj.weight = calculateWeight(obj.assignedFLSs, vertexList);
        end
        
        function locationOfStandby = getLocationOfStandby(obj)
            locationOfStandby = [obj.standbyFLSCoordinate(1), obj.standbyFLSCoordinate(2), obj.standbyFLSCoordinate(3)];
        end

        function obj = calculateDistanceBetweenStandby(obj, vertexList)
            
            tolerance = 0.000000000001;
            if (abs(obj.distanceBetweenStandby - 0.0) > tolerance)
                return;
            end
            
            locationOfStandby = obj.getLocationOfStandby();
            
            dist = 0.0;
            for i=1:size(obj.assignedFLSs, 2)
                af = obj.assignedFLSs(i);
                if (size(af.vertices, 2) > 1)
                    error("Graph Vertex in reliability should not contains more than 1 vertex");
                end

                vid = af.vertices(1);
                coordinateOfV = vertexList{vid};
                locationOfV = [coordinateOfV(1), coordinateOfV(2), coordinateOfV(3)];
                
                dist = dist + pdist([locationOfStandby; locationOfV]);
            end

            obj.distanceBetweenStandby = dist;
            obj.weight = obj.weight + dist;
        end
        
        function num = getNumberOfVertices(obj)
            num = size(obj.assignedFLSs, 2);
        end

        function obj = regardCenterAsStandbyFls(obj, vertexList)
            standbyFlsCoordinate = findCenterCoordinate(obj.widthLineSegment, obj.heightLineSegment, obj.depthLineSegment);
            obj.standbyFLSCoordinate = standbyFlsCoordinate;
            obj.calculateDistanceBetweenStandby(vertexList);
        end
    end
end


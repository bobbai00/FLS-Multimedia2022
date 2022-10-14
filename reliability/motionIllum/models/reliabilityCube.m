classdef reliabilityCube < handle
    properties
        identity
        cubeID
        verticesTransformation
        
        verticesIDs
        numVertices = 0

        neighborRCubeIDs
        numNeighbor = 0

        vidMap
        isMotionCube = 0

        widthLineSegment {mustBeNumeric} = []
        heightLineSegment {mustBeNumeric} = []
        depthLineSegment {mustBeNumeric} = []
    end

    methods
        function obj = reliabilityCube(identity, cubeList, cubeID, isMotionCube, travelPaths, vertices)
            cube = cubeList(cubeID);
            
            obj.identity = identity;
            obj.verticesIDs = [];
            obj.cubeID = cubeID;
            obj.vidMap = containers.Map('KeyType','int32','ValueType','int8');
            obj.isMotionCube = isMotionCube;
            obj.neighborRCubeIDs = [];
            obj.widthLineSegment = cube.widthLineSegment;
            obj.heightLineSegment = cube.heightLineSegment;
            obj.depthLineSegment = cube.depthLineSegment;        

            if obj.isMotionCube
                for i = 1:size(travelPaths, 2)
                    tp = travelPaths{i};
    
                    srcCid = tp(1);
                    srcVid = tp(2);
                    if srcCid == cubeID
                        obj.numVertices = obj.numVertices + 1;
                        obj.verticesIDs(obj.numVertices) = srcVid;
                        obj.vidMap(srcVid) = 1;
                    end
                end
            else
                obj.verticesIDs = vertices;
                obj.numVertices = size(vertices, 2);

            end
            
        end

        function r = getStaticPoint(obj, cubeList)
            originalCube = cubeList(obj.cubeID);
            index = 1;

            for i = 1:size(originalCube.assignedVertices, 2)
                vid = originalCube.assignedVertices(i);

                if ~isKey(obj.vidMap, vid)
                    r(index) = vid;
                    index = index + 1;
                end
            end
        end

        function rc = getStaticReliabilityCube(obj, identity, cubeList)
            if ~obj.isMotionCube
                error("ERROR: this cube is not motionRCube")
            end
            staticPoints = obj.getStaticPoint(cubeList);

            rc = reliabilityCube(identity, cubeList, obj.cubeID, 0, {}, staticPoints);
        end

        function obj = addNeighbor(obj, rcude)
            if rcube.isMotionCube ~= obj.isMotionCube
                error("neighbor rcube should be in the same type with the current cube");
            end
            
            rcubeID = rcube.identity;
            obj.numNeighbor = obj.numNeighbor + 1;
            obj.neighborRCubeIDs(obj.numNeighbor) = rcubeID; 
        end

        function obj = calculateLineSegment(obj, vertexList)
            maxW = 0.0;
            maxH = 0.0;
            maxD = 0.0;
            minW = realmax;
            minH = realmax;
            minD = realmax;
            multiplier=1.0;

            for i = 1:size(obj.verticesIDs, 2)
                vid = obj.verticesIDs(i);
                vertexCoor = vertexList{vid};

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

        end

    end
end
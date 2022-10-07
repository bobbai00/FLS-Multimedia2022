classdef clique < handle
    %CLIQUE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        identity
        numFLSs = 0
        flsIDs
        weight = 0.0
        G
        Delta
        flsIdToIndex
        minEdgeWeight = realmax
        maxEdgeWeight = 0.0
        standbyCoordinate
        
        widthLineSegment {mustBeNumeric} = []
        heightLineSegment {mustBeNumeric} = []
        depthLineSegment {mustBeNumeric} = []
    end
    
    methods
        function obj = clique(identity, G, Delta)
            obj.identity = identity;
            obj.G = G;
            obj.Delta = Delta;
            obj.flsIdToIndex = containers.Map('KeyType','int32','ValueType','int32');
        end
        
        function r = addFls(obj, flsID, flsList)
            nextFlsID = obj.numFLSs + 1;
            obj.numFLSs = nextFlsID;
            obj.flsIDs(nextFlsID) = flsID;
            r = nextFlsID;
            obj.flsIdToIndex(flsID) = nextFlsID;
            
%             if obj.numFLSs > obj.G
%                 error("number of FLSs should not exceed to G");
%             end

            [totalIncreasingWeight, minEdge, maxEdge] = obj.distanceBetweenOneFlsToOthers(flsID, flsList);
            obj.weight = obj.weight + totalIncreasingWeight;
            if minEdge < obj.minEdgeWeight
                obj.minEdgeWeight = minEdge;
            end

            if maxEdge > obj.maxEdgeWeight
                obj.maxEdgeWeight = maxEdge;
            end
        end

        function obj = clear(obj)
            obj.numFLSs = 0;
            obj.flsIDs = [];
            obj.weight = 0;
            obj.minEdgeWeight = realmax;
            obj.maxEdgeWeight = 0.0;
            remove(obj.flsIdToIndex, keys(obj.flsIdToIndex));
        end

        function obj = reassignFLSs(obj, flsIDs, flsList)
            obj.clear();
            for i = 1:size(flsIDs, 2)
                flsID = flsIDs(i);
                obj.addFls(flsID, flsList);
            end
        end
       
        function [selectedFlsIDs, prunedFlsIDs] = setStandbyAndRuleOutNodes(obj, flsList)
            selectedFlsIDs = obj.flsIDs;
            prunedFlsIDs = [];
            if obj.numFLSs <= obj.G
                return;
            end
            
            maxW = 0.0;
            maxH = 0.0;
            maxD = 0.0;
            minW = realmax;
            minH = realmax;
            minD = realmax;
            multiplier = 1.0;
            for i = 1:obj.numFLSs
                fid = obj.flsIDs(i);
                fls = flsList(fid);
                
                fCoor = fls.coordinate{1};
                % find the maximum W, H, D coordinates
                if fCoor(1)*multiplier > maxW
                    maxW = fCoor(1)*multiplier;
                end
                if fCoor(2)*multiplier > maxH
                    maxH = fCoor(2)*multiplier;
                end
                if fCoor(3)*multiplier > maxD
                    maxD = fCoor(3)*multiplier;
                end
            
                % find the minimum W, H, D coordinates
                if fCoor(1)*multiplier < minW
                    minW = fCoor(1)*multiplier;
                end
                if fCoor(2)*multiplier < minH
                    minH = fCoor(2)*multiplier;
                end
                if fCoor(3)*multiplier < minD
                    minD = fCoor(3)*multiplier;
                end
            end

            obj.widthLineSegment = [minW, maxW];
            obj.heightLineSegment = [minH, maxH];
            obj.depthLineSegment = [minD, maxD];

            obj.standbyCoordinate = findCenterCoordinate(obj.widthLineSegment, obj.heightLineSegment, obj.depthLineSegment);
            standbyLocCoor = [obj.standbyCoordinate(1), obj.standbyCoordinate(2), obj.standbyCoordinate(3)];
            
            coorWithDistance = [];
            for i = 1:obj.numFLSs
                fid = obj.flsIDs(i);
                coordinate = flsList(fid).coordinate{1};
                locCoor = [coordinate(1), coordinate(2), coordinate(3)];
                distBetweenStandby = pdist([locCoor;standbyLocCoor]);
                coorWithDistance = [coorWithDistance, [fid;distBetweenStandby]];
            end

            sortedCoorWithDistance = sortrows(coorWithDistance', 2)';
            
            selectedFlsIDs = [];

            for i = 1:obj.numFLSs
                id = sortedCoorWithDistance(1, i);
                if i <= obj.G
                    selectedFlsIDs = [selectedFlsIDs, id];
                else
                    prunedFlsIDs = [prunedFlsIDs, id];
                end
            end

            obj.reassignFLSs(selectedFlsIDs, flsList);
        end

        function [sumOfDist, minEdge, maxEdge] = distanceBetweenOneFlsToOthers(obj, flsID, flsList)            
            f = flsList(flsID);
            sumOfDist = 0.0;
            minEdge = realmax;
            maxEdge = 0.0;
            for i = 1:obj.numFLSs
                fid = obj.flsIDs(i);
                tf = flsList(fid);
                if fid ~= flsID
                    dist = f.calculateDistance(tf);
                    if dist > maxEdge
                        maxEdge = dist;
                    end

                    if dist < minEdge
                        minEdge = dist;
                    end
                    sumOfDist = sumOfDist + dist;
                end
            end
            
        end
        
        function r = getNumberOfFls(obj)
            r = obj.numFLSs;
%             if r > obj.G
%                 error("number of FLSs should not exceed to G");
%             end
        end

        function r = isCliqueFull(obj)
            r = 0;
            if obj.getNumberOfFls() >= obj.G-obj.Delta && obj.getNumberOfFls() <= obj.G+obj.Delta
                r = 1;
            end
        end

        function r = removeFlsOfGivenIndex(obj, flsId, flsList)
            flsWithinIndex = obj.getIndexByFlsID(flsId);

            fidToDelete = obj.flsIDs(flsWithinIndex);
            if fidToDelete ~= flsId
                error("Verification failed, id is not identical");
            end

            [removalDist, minEdge, maxEdge] = obj.distanceBetweenOneFlsToOthers(flsID, flsList);
            
           
            obj.weight = obj.weight - removalDist;

            obj.flsIDs(flsWithinIndex) = [];
            obj.flsIdToIndex(flsId) = [];
               
            obj.numFLSs = obj.numFLSs - 1;
            r = obj.numFLSs;

            flsList(flsId).currentCliqueID = 0;
            remove(obj.flsIdToIndex, flsId);

            if minEdge == obj.minEdgeWeight || maxEdge == obj.maxEdgeWeight
                obj.recalculateMinMaxEdge(flsList);
            end
        end

        
        
        function obj = recalculateMinMaxEdge(obj, flsList)
            minWeightEdge = realmax;
            maxWeightEdge = 0.0;

            for i = 1:obj.numFLSs
                flsId = obj.flsIDs(i);
                [~, minw, maxw] = obj.distanceBetweenOneFlsToOthers(flsId, flsList);
                if minw < minWeightEdge
                    minWeightEdge = minw;
                end

                if maxw > maxWeightEdge
                    maxWeightEdge = maxw;
                end
            end

            obj.minEdgeWeight = minWeightEdge;
            obj.maxEdgeWeight = maxWeightEdge;
        end

        function r = getIndexByFlsID(obj, flsID)
            r = obj.flsIdToIndex(flsID);
        end

        function r = isGivenFlsInIt(obj, flsID)
            r = isKey(obj.flsIdToIndex, flsID);
        end

        function r = flsIdSetWithoutSpecificOne(obj, exclusiveFlsID)
            index = obj.flsIdToIndex(exclusiveFlsID);
            r = copy(obj.flsIDs);
            r(index) = [];
        end

        function r = getMinWeightEdge(obj)
            r = obj.minEdgeWeight;
        end

        function r = getMaxWeightEdge(obj)
            r = obj.maxEdgeWeight;
        end

        function r = getAverageWeightEdge(obj)
            if obj.numFLSs <= 1
                r = 0.0;
                return
            end
            r = obj.weight / (obj.numFLSs * (obj.numFLSs - 1) / 2.0);
        end
    end
end


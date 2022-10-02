classdef clique < handle
    %CLIQUE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        identity
        numFLSs = 0
        flsIDs
        weight = 0.0
        G
        flsIdToIndex
        minEdgeWeight = realmax
        maxEdgeWeight = 0.0
    end
    
    methods
        function obj = clique(identity, G)
            obj.identity = identity;
            obj.G = G;
            obj.flsIdToIndex = containers.Map('KeyType','int32','ValueType','int32');
        end
        
        function r = addFls(obj, flsID, flsList)
            nextFlsID = obj.numFLSs + 1;
            obj.numFLSs = nextFlsID;
            obj.flsIDs(nextFlsID) = flsID;
            r = nextFlsID;
            obj.flsIdToIndex(flsID) = nextFlsID;
            
            if obj.numFLSs > obj.G
                error("number of FLSs should not exceed to G");
            end

            [totalIncreasingWeight, minEdge, maxEdge] = obj.distanceBetweenOneFlsToOthers(flsID, flsList);
            obj.weight = obj.weight + totalIncreasingWeight;
            if minEdge < obj.minEdgeWeight
                obj.minEdgeWeight = minEdge;
            end

            if maxEdge > obj.maxEdgeWeight
                obj.maxEdgeWeight = maxEdge;
            end
            
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
            if r > obj.G
                error("number of FLSs should not exceed to G");
            end
        end

        function r = isCliqueFull(obj)
            r = 0;
            if obj.getNumberOfFls() == obj.G
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
               
            obj.weight = obj.weight - totalRemoval;
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
            r = obj.weight / (obj.numFLSs * 1.0);
        end
    end
end


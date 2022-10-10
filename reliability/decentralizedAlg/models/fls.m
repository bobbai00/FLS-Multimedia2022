classdef fls < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        identity
        shard
        flsScheduler
        coordinate
        G
        Delta
        neighborFlsIds
        cubeID
        randomStreamForFlsID
        numberOfNeighbors
        isUsingHeuristic

        cliqueID
        cliqueFLSs

        % for cube priority
        isEnableCubePriority = 0
        alpha = 0
        counter = 0
        M

        neighborIndex = 0;

    end
    
    methods
        function obj = fls(identity, isUsingHeuristic, flsScheduler, shard, G, Delta, coordinate)
            obj.randomStreamForFlsID = RandStream('dsfmt19937');
            obj.identity = identity;
            obj.flsScheduler = flsScheduler;
            obj.shard = shard;
            obj.coordinate = coordinate;
            obj.G = G;
            obj.Delta = Delta;
            obj.isUsingHeuristic = isUsingHeuristic;
        end

        function obj = enableCubePriority(obj, M)
            obj.isEnableCubePriority = 1;
            obj.M = M;
        end
        
        function r = nextNeighborFlsID(obj)
            r = randi(obj.randomStreamForFlsID, obj.numberOfNeighbors);
        end

        function obj = initNeighbor(obj, cubeID, neighborIdList)            
            % flsIdList = currentCube.assignedVertices;
%             for i = 1:size(currentCube.neighbors)
%                 c = cubeList(currentCube.neighbors(i));
%                 if ~c.isDisabled()
%                     flsIdList = [flsIdList, c.assignedVertices];
%                 end
%             end
            if size(neighborIdList, 2) == 0
                error("error")
            end
            obj.cubeID = cubeID;
            obj.neighborFlsIds = neighborIdList;
            obj.numberOfNeighbors = size(neighborIdList, 2);
        end

        function obj = start(obj)
            if obj.isEnableCubePriority
                obj.startWithCubePriority();
            else
                obj.startWithOtherHeuristic();
            end
        end

        function obj = startWithOtherHeuristic(obj)
           latestCliqueID = obj.flsScheduler.getLatestCliqueForGivenFls(obj.identity);
           if latestCliqueID == 0
               % not in a clique yet
               % apply a new clique
               obj.cliqueID = obj.flsScheduler.applyNewClique(obj.identity);
           else
               obj.cliqueID = latestCliqueID;
           end
           
           currentCliqueID = obj.cliqueID; 
           currentClique = obj.flsScheduler.updateClique(currentCliqueID);            
           fid = 0;
           for times = 1:obj.shard
               while fid == obj.identity || fid == 0
                    if obj.isUsingHeuristic
                        fid = obj.neighborFlsIds(obj.nextNeighborFlsID());
                    else
                        fid = obj.flsScheduler.nextFlsID();
                    end
               end

               % fprintf("currentID: %d, targetID %d\n", obj.identity, fid);
               if ~obj.flsScheduler.isFlsInAnyCliques(fid)
                   obj.flsScheduler.addFlsToClique(currentCliqueID, fid);
               else
                   targetCliqueID = obj.flsScheduler.getLatestCliqueForGivenFls(fid);
                   targetClique = obj.flsScheduler.updateClique(targetCliqueID);
                   
                   if targetCliqueID == currentCliqueID
                        continue;
                   end
                   % merge two cliques if they are not full after
                   % combining
                   newFLSsList = [currentClique.flsIDs, targetClique.flsIDs];
                   
                   newFLSsList = unique(newFLSsList(:).');
                   tempClique = clique(0, obj.G, obj.Delta);
                   
                   for i = 1:size(newFLSsList, 2)
                       fid = newFLSsList(i);
                       tempClique.addFls(fid, obj.flsScheduler.flsList);
                   end
                   
                   [~, prunedIDs] = tempClique.setStandbyAndRuleOutNodes(obj.flsScheduler.flsList);
                   
                   currentKeptIdList = [];
                   targetKeptIdList = [];
                    
                   for i = 1:size(prunedIDs, 2)
                       
                        fid = prunedIDs(i);
                        if ismember(fid, currentClique.flsIDs)
                            currentKeptIdList = [currentKeptIdList, fid];
                        else
                            targetKeptIdList = [targetKeptIdList, fid];
                        end
                   end

                   if ~tempClique.isCliqueFull() || (~currentClique.isCliqueFull() && ~targetClique.isCliqueFull())
                       obj.flsScheduler.reassignFlsForClique(currentCliqueID, currentKeptIdList);
                       obj.flsScheduler.reassignFlsForClique(targetCliqueID, targetKeptIdList);
                       obj.flsScheduler.addClique(tempClique);

                   elseif (~targetClique.isCliqueFull() || tempClique.weight < targetClique.weight) && (~currentClique.isCliqueFull() || tempClique.weight < currentClique.weight)
                       obj.flsScheduler.reassignFlsForClique(currentCliqueID, currentKeptIdList);
                       obj.flsScheduler.reassignFlsForClique(targetCliqueID, targetKeptIdList);
                       obj.flsScheduler.addClique(tempClique);
                   end
               end
           end
        end

        function r = isTwoFlsIDsEqual(obj, flsIDs1, flsIDs2)
            
            if size(flsIDs1, 2) ~= size(flsIDs2, 2)
                r = 0;
                return;
            end
            
            flsIDs1 = sort(flsIDs1, 2);
            flsIDs2 = sort(flsIDs2, 2);

            r = isequal(flsIDs1, flsIDs2);
        end

        function obj = startWithCubePriority(obj)
           latestCliqueID = obj.flsScheduler.getLatestCliqueForGivenFls(obj.identity);
           if latestCliqueID == 0
               % not in a clique yet
               % apply a new clique
               obj.cliqueID = obj.flsScheduler.applyNewClique(obj.identity);
               currentCliqueID = obj.cliqueID; 
               currentClique = obj.flsScheduler.updateClique(currentCliqueID);
               obj.cliqueFLSs = currentClique.flsIDs;
               obj.counter = 0;
           else
               currentCliqueID = latestCliqueID; 
               currentClique = obj.flsScheduler.updateClique(currentCliqueID);
               isIdsNotChanged = obj.isTwoFlsIDsEqual(obj.cliqueFLSs, currentClique.flsIDs);
               if isequal(obj.cliqueID, latestCliqueID) && isIdsNotChanged && ~currentClique.isCliqueFull()
                   % clique not change, increase the counter
                   obj.counter = obj.counter + 1;
                   if obj.counter >= obj.M
                       obj.alpha = obj.alpha + 1;
                       obj.flsScheduler.addNextHopNeighbor(obj.identity);
                       obj.counter = 0;
                   end
               else
                   obj.counter = 0;
                   obj.cliqueID = latestCliqueID;
                   obj.cliqueFLSs = currentClique.flsIDs;
               end
           end
                       
           fid = 0;
           for times = 1:obj.shard
               while fid == obj.identity || fid == 0
                    if obj.isUsingHeuristic
                        fid = obj.neighborFlsIds(obj.nextNeighborFlsID());
                    else
                        fid = obj.flsScheduler.nextFlsID();
                    end
               end

               % fprintf("currentID: %d, targetID %d\n", obj.identity, fid);
               if ~obj.flsScheduler.isFlsInAnyCliques(fid)
                   obj.flsScheduler.addFlsToClique(currentCliqueID, fid);
               else
                   targetCliqueID = obj.flsScheduler.getLatestCliqueForGivenFls(fid);
                   targetClique = obj.flsScheduler.updateClique(targetCliqueID);
                   
                   if targetCliqueID == currentCliqueID
                        continue;
                   end
                   % merge two cliques if they are not full after
                   % combining
                   newFLSsList = [currentClique.flsIDs, targetClique.flsIDs];
                   
                   newFLSsList = unique(newFLSsList(:).');
                   tempClique = clique(0, obj.G, obj.Delta);
                   
                   for i = 1:size(newFLSsList, 2)
                       fid = newFLSsList(i);
                       tempClique.addFls(fid, obj.flsScheduler.flsList);
                   end
                   
                   [~, prunedIDs] = tempClique.setStandbyAndRuleOutNodes(obj.flsScheduler.flsList);
                   
                   currentKeptIdList = [];
                   targetKeptIdList = [];
                    
                   for i = 1:size(prunedIDs, 2)
                       
                        fid = prunedIDs(i);
                        if ismember(fid, currentClique.flsIDs)
                            currentKeptIdList = [currentKeptIdList, fid];
                        else
                            targetKeptIdList = [targetKeptIdList, fid];
                        end
                   end

                   if ~tempClique.isCliqueFull() || (~currentClique.isCliqueFull() && ~targetClique.isCliqueFull())
                       obj.flsScheduler.reassignFlsForClique(currentCliqueID, currentKeptIdList);
                       obj.flsScheduler.reassignFlsForClique(targetCliqueID, targetKeptIdList);
                       obj.flsScheduler.addClique(tempClique);

                   elseif (~targetClique.isCliqueFull() || tempClique.weight < targetClique.weight) && (~currentClique.isCliqueFull() || tempClique.weight < currentClique.weight)
                       obj.flsScheduler.reassignFlsForClique(currentCliqueID, currentKeptIdList);
                       obj.flsScheduler.reassignFlsForClique(targetCliqueID, targetKeptIdList);
                       obj.flsScheduler.addClique(tempClique);
                   end
               end
           end
        end

        function r = calculateDistance(obj, f)
            v1 = obj.coordinate{1};
            v2 = f.coordinate{1};
            
            coor1 = [v1(1), v1(2), v1(3)];
            coor2 = [v2(1), v2(2), v2(3)];

            r = pdist([coor1;coor2]);
        end

    end
end


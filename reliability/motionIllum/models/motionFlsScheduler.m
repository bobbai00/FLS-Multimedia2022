classdef motionFlsScheduler < handle
    
    properties
        numFLSs {mustBeInteger} = 0
       
        vertexList
        staticCubeList
        motionCubeList
        numProcessors {mustBeInteger} = 1
        maxRounds {mustBeInteger}
        randomStreamForFlsID 
        shardForSingleFLS

        % weight storage
        weightOfClique
        numOfClique = 0
        flsToCliques = {}
        flsList = []
        cliqueList = []
        
        vidToFid
        % configuration
        G1
        Delta1
        G2
        Delta2

        % metrics
        filePrefix
        sampleInterval
        latestCliqueAtEachRound = {}

        motionFlsMap

    end
    
    methods
        function obj = motionFlsScheduler(numFLSs, maxRounds, shardForSingleFLS, G1, Delta1, G2, Delta2, vertexList, staticCubeList, motionCubeList)
            obj.randomStreamForFlsID = RandStream('dsfmt19937');
            obj.numFLSs = numFLSs;
            obj.maxRounds = maxRounds;
            obj.shardForSingleFLS = shardForSingleFLS;
            obj.vertexList = vertexList;
            
            obj.G1 = G1;
            obj.Delta1 = Delta1;
            obj.G2 = G2;
            obj.Delta2 = Delta2;

            obj.staticCubeList = staticCubeList;
            obj.motionCubeList = motionCubeList;
            obj.vidToFid = containers.Map('KeyType','int32','ValueType','int32');
            obj.motionFlsMap = containers.Map('KeyType','int32','ValueType','int8');

            indexOfFls = 1;

            % init neighbors for static cubes
            for i = 1:size(staticCubeList, 2)
                cubeID = staticCubeList(i).identity;
                if staticCubeList(i).isDisabled() || staticCubeList(i).numVertices == 0
                    continue;
                end
                assignedVertices = staticCubeList(i).assignedVertices;
                cubeFlsIdList = [];
                for j = 1:size(assignedVertices, 2)
                    v = assignedVertices(j);
                    obj.flsToCliques{indexOfFls} = [];
                    
                    newFls = fls(indexOfFls, 1, obj, obj.shardForSingleFLS, obj.G, obj.Delta, obj.vertexList(v));
                    newFls.initNeighbor(cubeID, assignedVertices);

                    cubeFlsIdList = [cubeFlsIdList, indexOfFls];

                    obj.flsList = [obj.flsList, newFls];

                    obj.vidToFid(v) = indexOfFls;

                    indexOfFls = indexOfFls + 1;
                end

                if indexOfFls > obj.numFLSs
                    obj.numFLSs = indexOfFls-1;
                    break;
                end
            end

            % init neighbors for motion FLSs
            motionVerticesIDs = [];
            for i = 1:size(motionCubeList, 2)
                cubeID = motionCubeList(i).identity;
                if motionCubeList(i).isDisabled() || motionCubeList(i).numVertices == 0
                    continue;
                end
                
                assignedVertices = motionCubeList(i).assignedVertices;
                motionVerticesIDs = [motionVerticesIDs, assignedVertices];
                for j = 1:size(assignedVertices, 2)
                    v = assignedVertices(j);
                    obj.flsToCliques{indexOfFls} = [];
                    
                    newFls = fls(indexOfFls, 1, obj, obj.shardForSingleFLS, obj.G, obj.Delta, obj.vertexList(v));
                    cubeFlsIdList = [cubeFlsIdList, indexOfFls];

                    obj.flsList = [obj.flsList, newFls];
                    obj.vidToFid(v) = indexOfFls;

                    indexOfFls = indexOfFls + 1;
                end

                if indexOfFls > obj.numFLSs
                    obj.numFLSs = indexOfFls-1;
                    break;
                end
            end

            for i = 1:size(motionVerticesIDs, 2)
                vid = motionVerticesIDs(i);
                fid = obj.vidToFid(vid);
                obj.motionFlsMap(fid) = 1;
            end

            motionFlsIDs = keys(obj.motionFlsMap);
            for i = 1:size(motionFlsIDs, 2)
                obj.flsList(fid).initNeighbor(0, motionFlsIDs);
            end            
        end

        function start(obj)
            currentId = 1;
            rounds = 0;
            
            while currentId < obj.numFLSs
                
                currentFls = obj.flsList(currentId);
                currentFls.start();

                currentId = currentId + 1;
                if currentId >= obj.numFLSs
                    currentId = 1;
                    rounds = rounds + 1;
                    
                    % end of the round, record the latest cliques
                    latestCliqueIDs = obj.getAllLatestCubeIDs();
                    
                    cliqueFlsIDs = {};
                    for i = 1:size(latestCliqueIDs, 2)
                        cid = latestCliqueIDs(i);
                        clique = obj.cliqueList(cid);
                        cliqueFlsIDs{i} = [clique.identity, clique.numFLSs, clique.weight, clique.minEdgeWeight, clique.maxEdgeWeight, clique.getAverageWeightEdge(), clique.isCliqueFull()];
                    end
                    obj.latestCliqueAtEachRound{rounds} = cliqueFlsIDs;
                    
                    fprintf("end of round #%d\n", rounds);
                    
                    if mod(rounds, obj.sampleInterval) == 0
                        % report the statistics
                        reportDecentralizedStatsForSample(obj.filePrefix, rounds - obj.sampleInterval + 1, rounds, obj.latestCliqueAtEachRound, obj.G);
                    end
                    if rounds >= obj.maxRounds
                        break;
                    end
                end
            end
        end
        
        function r = nextFlsID(obj)
            r = randi(obj.randomStreamForFlsID, obj.numFLSs);
        end
        
        function r = getFlsBelongingClique(obj, flsID)
            r = obj.flsList(flsID);
        end
        
        function c = updateClique(obj, cliqueID)
            clique = obj.cliqueList(cliqueID);

            prevFlsIDs = clique.flsIDs;
            newFlsIDs = [];
            index = 0;
            for i = 1:size(prevFlsIDs, 2)
                fid = prevFlsIDs(i);
                latestCid = obj.getLatestCliqueForGivenFls(fid);
                if latestCid == cliqueID
                    newFlsIDs(index+1) = fid;
                    index = index + 1;
                end
            end

            if index ~= clique.numFLSs
                clique.reassignFLSs(newFlsIDs, obj.flsList);
                obj.cliqueList(cliqueID) = clique;
            end
            
            c = clique;
        end
        
        function obj = setStandbyForCliqueAndRuleOutNodes(obj, cliqueID)
            newClique = obj.cliqueList(cliqueID);
            [~, prunedFlsIDs] = newClique.setStandbyAndRuleOutNodes(obj.flsList);
            for i = 1:size(prunedFlsIDs, 2)
               fid = prunedFlsIDs(i);
               obj.flsToCliques{fid} = [];
            end
        end

        function obj = reassignFlsForClique(obj, cliqueID, flsIDs)
            clique = obj.cliqueList(cliqueID);
            clique.reassignFLSs(flsIDs, obj.flsList);
        end

        function r = nextCliqueID(obj)
            obj.numOfClique = obj.numOfClique + 1;
            r = obj.numOfClique;
        end
        function cid = applyNewClique(obj, flsIDs)
            cliqueID = obj.nextCliqueID();
            c = clique(cliqueID, obj.G, obj.Delta);
            obj.cliqueList = [obj.cliqueList, c];
            obj.addFlsToClique(cliqueID, flsIDs);
            cid = cliqueID;
        end

        function obj = addClique(obj, clique)
            clique.identity = obj.nextCliqueID();
            obj.cliqueList = [obj.cliqueList, clique];

            for i = 1:clique.numFLSs
                flsID = clique.flsIDs(i);
                obj.flsToCliques{flsID} = [obj.flsToCliques{flsID}, clique.identity];
            end
        end

        function r = addFlsToClique(obj, cliqueID, flsIDs)
            c = obj.cliqueList(cliqueID);
            for i = 1:size(flsIDs, 2)
                flsID = flsIDs(i);
                r = c.addFls(flsID, obj.flsList);
                obj.flsToCliques{flsID} = [obj.flsToCliques{flsID}, cliqueID];
            end
        end

        function removeFlsFromClique(obj, cliqueID, flsID)
            clique = obj.cliqueList(cliqueID);
            clique.removeFlsOfGivenIndex(flsID, obj.flsList);
            
            obj.flsToCliques{flsID} = {};
        end

        function isolateFlss(obj, flsIDs)
            for i = 1:size(flsIDs, 2)
                fid = flsIDs(i);
                obj.flsToCliques{fid} = [];
                obj.applyNewClique(fid);
            end
        end

        function r = getAllLatestCubeIDs(obj)
            r = [];
            for i = 1:obj.numFLSs
                cid = obj.getLatestCliqueForGivenFls(i);
                if cid ~= 0
                    r = [r, cid];
                end
            end
            r = unique(r(:).');
        end

        function r = getLatestCliqueForGivenFls(obj, flsID)
            r = 0;
            cliques = obj.flsToCliques{flsID};
            if size(cliques, 2) > 0
                r = cliques(end);
            end
        end

        function r = isFlsInAnyCliques(obj, fid)
            r = 1;
            cids = obj.flsToCliques{fid};
            if size(cids, 2) == 0
                r = 0;
            end
        end
    end
end


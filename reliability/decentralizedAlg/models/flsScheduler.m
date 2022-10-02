classdef flsScheduler < handle
    
    properties
        numFLSs {mustBeInteger} = 0
       
        vertexList
        cubeList
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

        % configuration
        G
    end
    
    methods
        function obj = flsScheduler(numFLSs, maxRounds, shardForSingleFLS, G, cubeList, vertexList)
            obj.randomStreamForFlsID = RandStream('dsfmt19937');
            obj.numFLSs = numFLSs;
            obj.maxRounds = maxRounds;
            obj.shardForSingleFLS = shardForSingleFLS;
            obj.vertexList = vertexList;
            
            obj.G = G;
            obj.cubeList = cubeList;
            
            indexOfFls = 1;
            for i = 1:size(cubeList, 2)
                if cubeList(i).isDisabled()
                    continue;
                end
                assignedVertices = cubeList(i).assignedVertices;
                for j = 1:size(assignedVertices, 2)
                    v = assignedVertices(j);
                    obj.flsToCliques{indexOfFls} = [];
                    obj.flsList = [obj.flsList, fls(indexOfFls, obj, obj.shardForSingleFLS, obj.G, obj.vertexList(v), cubeList(i))];
                    indexOfFls = indexOfFls + 1;
                end
                if indexOfFls > obj.numFLSs
                    break;
                end
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

                    if rounds >= obj.maxRounds
                        break;
                    end
                end
            end
        end
        
        function r = nextFlsID(obj)
            r = randi(obj.randomStreamForFlsID, obj.numFLSs);
        end


        function obj = singleProcessorSchedule(obj)
            for i = 1:obj.maxRounds
                
            end
        end
        
        function r = getFlsBelongingClique(obj, flsID)
            r = obj.flsList(flsID);
        end

        

        function r = nextCliqueID(obj)
            obj.numOfClique = obj.numOfClique + 1;
            r = obj.numOfClique;
        end
        function cid = applyNewClique(obj, firstFlsID)
            cliqueID = obj.nextCliqueID();
            c = clique(cliqueID, obj.G);
            obj.cliqueList = [obj.cliqueList, c];
            obj.addFlsToClique(cliqueID, firstFlsID);
            cid = cliqueID;
        end

        function r = addFlsToClique(obj, cliqueID, flsID)
            c = obj.cliqueList(cliqueID);
            r = c.addFls(flsID, obj.flsList);
            obj.flsToCliques{flsID} = [obj.flsToCliques{flsID}, cliqueID];
        end

        function r = getAllLatestCubeIDs(obj)
            r = [];
            for i = 1:obj.numFLSs
                cliqueIds = obj.flsToCliques{i};
                if size(cliqueIds, 2) > 0
                    r = [cliqueIds(end), r];
                end
            end
        end

        function removeFlsFromClique(obj, cliqueID, flsID)
            clique = obj.cliqueList(cliqueID);
            clique.removeFlsOfGivenIndex(flsID, obj.flsList);

            cliques = obj.flsToCliques{flsID};
            for i = 1:size(cliques, 2)
                if cliques(i) == cliqueID
                    obj.flsToCliques{flsID}(:, i) = [];
                    break;
                end
            end
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


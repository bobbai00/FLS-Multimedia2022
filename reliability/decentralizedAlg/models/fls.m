classdef fls < handle
    %FLS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        identity
        shard
        flsScheduler
        coordinate
        G
        neighbors
        cubeID
        cliqueID
    end
    
    methods
        function obj = fls(identity, flsScheduler, shard, G, coordinate, cube)
           obj.identity = identity;
           obj.flsScheduler = flsScheduler;
           obj.shard = shard;
           obj.coordinate = coordinate;
           obj.G = G;
           obj.cubeID = cube.identity;
        end
        
        function obj = start(obj)
           latestCliqueID = obj.flsScheduler.getLatestCliqueForGivenFls(obj.identity);
           if latestCliqueID == 0
               % not in a clique yet
               % apply a new clique
               obj.cliqueID = obj.flsScheduler.applyNewClique(obj.identity);
           else
               obj.cliqueID = latestCliqueID;
           end
           
           currentCliqueID = obj.cliqueID; 
           currentClique = obj.flsScheduler.cliqueList(currentCliqueID);
           i = 0;
            
           while i < obj.shard
               fid = obj.flsScheduler.nextFlsID();
               while fid == obj.identity
                    fid = obj.flsScheduler.nextFlsID();
               end
               % targetFls = obj.flsScheduler.flsList(fid);
               if ~currentClique.isCliqueFull()
                   if ~obj.flsScheduler.isFlsInAnyCliques(fid)
                       obj.flsScheduler.addFlsToClique(currentCliqueID, fid);
                   end
               else
                   break;
               end
               i = i+1;
           end
        end
        
        function r = calculateDistance(obj, f)
            v1 = obj.coordinate{1};
            v2 = f.coordinate{1};
            
            coor1 = [v1(1), v1(2), v1(3)];
            coor2 = [v2(1), v2(2), v2(3)];

            r = pdist([coor1;coor2]);
        end

        function obj = pauseAndSave(obj)
            
        end
    end
end


function obj = heuristicCubePriority(obj)

    C = obj.counter;
    M = obj.counterMThershold;
    a = obj.alpha;

    latestCliqueID = obj.flsScheduler.getLatestCliqueForGivenFls(obj.identity);
    isCliqueChange = 0;
    if latestCliqueID == 0
        % not in a clique yet
        % apply a new clique
        obj.cliqueID = obj.flsScheduler.applyNewClique(obj.identity);
        isCliqueChange = 1;
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
                isCliqueChange = 1;

            elseif (~targetClique.isCliqueFull() || tempClique.weight < targetClique.weight) && (~currentClique.isCliqueFull() || tempClique.weight < currentClique.weight)
                obj.flsScheduler.reassignFlsForClique(currentCliqueID, currentKeptIdList);
                obj.flsScheduler.reassignFlsForClique(targetCliqueID, targetKeptIdList);
                obj.flsScheduler.addClique(tempClique);
                isCliqueChange = 1;
            end
        end
    end

    latestCliqueID = obj.flsScheduler.getLatestCliqueForGivenFls(obj.identity);
    if ~isCliqueChange
        counter = counter + 1;
        if counter >= M
            % extend the selection pool
            % TODO: let scheduler maintain a hop for each cube
        end
    end

    obj.counter = counter;
    obj.alpha = a;
 end
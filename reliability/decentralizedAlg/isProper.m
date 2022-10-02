function [r, newWeight] = isProper(v,flsIDsToForm, flsScheduler)
    r = 1;

    tempClique = clique(0, 1000);
    for i = 1:size(flsIDsToForm, 2)
        fid = flsIDsToForm(i);
        tempClique.addFls(fid, flsScheduler.flsList);
    end
    tempClique.addFls(v, flsScheduler.flsList);

    newWeight = tempClique.weight;
    for i = 1:size(flsIDsToForm, 2)
        fid = tempClique.flsIDs(i);
        c = flsScheduler.getCliqueByFlsId(fid);
        if c.weight < newWeight
            r = 0;
            break;
        end
    end
end


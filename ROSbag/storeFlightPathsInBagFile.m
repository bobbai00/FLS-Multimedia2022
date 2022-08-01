function output = storeFlightPathsInBagFile(bagfilename, numPtClds, TravelPathArray, CldPtArray)
% Process the TravelPaths and ColorChanges to generate a bag file by:
% 1. Read point cloud i into a hash table HT
% 2. Enumerate entries in TravelPaths{i}
% 3. Probe HT with TravelPaths{i}.source.  If found then add
% TravelPaths{i}.destination to the hash table entry.  Add
% TravelPaths{i}.destination to the

% create a hash table on the first point cloud and populate it
hashMapOnFirstCldPt = containers.Map('KeyType','char', 'ValueType','any');
srcCloudPoint = CldPtArray{1};
for i=1:size( srcCloudPoint.vertexList, 2 )
    a1 = srcCloudPoint.vertexList(i);
    b1 = a1{1};
    hval=utilHashFunction(b1);
    % create a bag element and add it to the hash index
    coord1 = coordClass(b1(1), b1(2), b1(3));
    color1 = colorClass(b1(4), b1(5), b1(6), b1(7));
    duration1 = durationClass(0);

    hashMapOnFirstCldPt(hval)=msgElt(coord1, color1, duration1);
end

hashMapArrays={};
hashMapArrays{1}=hashMapOnFirstCldPt;

% Enumerate the flight paths for each point cloud and probe the hash tables
% in reverse order
for ptcldidx=2:numPtClds
    newHashMap = containers.Map('KeyType','char', 'ValueType','any');
    tgtTrvlPath = TravelPathArray(ptcldidx-1);

    startTS = (ptcldidx-1) * 1000/24;

    % Enumerate the flight paths
    for k=1:size(tgtTrvlPath{1},2)
        b1=tgtTrvlPath{1}{k}{3};
        probeKey=utilHashFunction(b1);
        if hashMapOnFirstCldPt.isKey(probeKey)
            % Close the interval for the current element
            tgtElt = hashMapOnFirstCldPt(probeKey);
            tgtElt.dursElt.endTS = startTS;
            % Put the destination in the new hash map
            coord1 = coordClass(b1(1), b1(2), b1(3));
            color1 = colorClass(b1(4), b1(5), b1(6), b1(7));
            duration1 = durationClass(startTS);
            newHashMap(hval)=msgElt(coord1, color1, duration1);
        else
            outputT= sprintf('Error in storeFlightPathsInBagFile, flight path %d has no target FLS device.',k);
            disp(outputT);
            %error('Exiting, cannot continue.')
        end
    end
end

end
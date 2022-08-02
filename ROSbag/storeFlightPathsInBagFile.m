function output = storeFlightPathsInBagFile(bagfilename, numPtClds, TravelPathArray, ColorChange, PtCldArray)
% Process the TravelPaths and ColorChanges to generate a bag file by:
% 1. Read point cloud i into a hash table HT
% 2. Enumerate entries in TravelPaths{i}
% 3. Probe HT with TravelPaths{i}.source.  If found then add
% TravelPaths{i}.destination to the hash table entry.  Add
% TravelPaths{i}.destination to the

% create a hash table on the first point cloud and populate it
hashMapOnFirstCldPt = containers.Map('KeyType','char', 'ValueType','any');
srcCloudPoint = PtCldArray{1};

% We use the backupVertexList because it is the original AND this code
% only reads coordinates of points without changing them.
for i=1:size( srcCloudPoint.backupVertexList, 2 )
    a1 = srcCloudPoint.backupVertexList(i);
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
    outputT= ['Processing coordinate changes for point cloud ', num2str(ptcldidx-1), ' with ', num2str(size( TravelPathArray{ptcldidx-1}, 2)), ' flight paths.' ];
    disp(outputT);

    newHashMap = containers.Map('KeyType','char', 'ValueType','any');
    hashMapArrays{ptcldidx}=newHashMap;
    tgtTrvlPath = TravelPathArray(ptcldidx-1);

    % start time stamp for duration interval in milliseconds
    startTS = (ptcldidx-1) * 1000/24; 

    % Enumerate the flight paths for change of position
    for k=1:size(tgtTrvlPath{1},2)
        b1=tgtTrvlPath{1}{k}{3};
        probeKey=utilHashFunction(b1);
        hashMapIdx=ptcldidx-1;
        foundProbeKey=false;
        for hidx=hashMapIdx:-1:1
            if foundProbeKey == false && hashMapArrays{hidx}.isKey(probeKey)
                % Close the interval for the current element
                tgtElt = hashMapArrays{hidx}(probeKey);
                tgtElt.dursElt.endTS = startTS;
                % Put the destination in the new hash map
                b1=tgtTrvlPath{1}{k}{6};
                coord1 = coordClass(b1(1), b1(2), b1(3));
                % color1 = colorClass(b1(4), b1(5), b1(6), b1(7));
                duration1 = durationClass(startTS);
                hval=utilHashFunction(b1);
                % colors is zero because travel paths are
                newHashMap(hval)=msgElt(coord1, 0, duration1);

                foundProbeKey = true;
            end
        end
        if ~foundProbeKey
            outputT= sprintf('Error in storeFlightPathsInBagFile, flight path %d has no target FLS device.',k);
            disp(outputT);
            %error('Exiting, cannot continue.')
        end
    end


end

end
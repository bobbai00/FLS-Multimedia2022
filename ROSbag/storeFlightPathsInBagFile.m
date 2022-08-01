function output = storeFlightPathsInBagFile(bagfilename, numPtClds, TravelPathArray, CldPtArray)
% Process the TravelPaths and ColorChanges to generate a bag file by:
% 1. Read point cloud i into a hash table HT
% 2. Enumerate entries in TravelPaths{i}
% 3. Probe HT with TravelPaths{i}.source.  If found then add
% TravelPaths{i}.destination to the hash table entry.  Add
% TravelPaths{i}.destination to the 

% create a hash table on the first point cloud and populate it 
hashMapOnLeadFrame = containers.Map('KeyType','char', 'ValueType','any');
srcCloudPoint = CldPtArray{1};
for i=1:size( srcCloudPoint.cubes(tgtCubeID).assignedVertices, 2 )
    a1 = leadVL( srcCloudPoint.cubes(tgtCubeID).assignedVertices(i) );
    b1 = a1{1};
    hval=utilHashFunction(b1);
    % create a bag element and add it to the hash index
    hashMapOnLeadFrame(hval)=srcCloudPoint.cubes(tgtCubeID).assignedVertices(i);
end

for ptcldidx=2:numPtClds
end

end
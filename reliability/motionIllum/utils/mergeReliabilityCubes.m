function vertices = mergeCubes(cubes, cubeIds, vertexList)
    vertices = [];

    for i = 1:size(cubeIds, 2)
        cid = cubeIds(i);
        cube = cubes(cid);
        if cube.isDisabled()
            error("cube shouldn't be disabled");
        end
        
        vertices = [vertices, cube.assignedVertices];
        cubes(cid).disable();
    end
    vertices = unique(vertices(:).');
end
function testMatching()
    edges = [
        1,2,10
        1,3,4
        2,3,3
        2,6,2
        2,7,2
        3,4,1
        3,5,2
        4,5,5
        5,7,4
        5,8,1
        5,9,3
        6,7,1
        7,8,2
        8,9,3
        8,10,2
        9,10,1
    ]

    g = graph();
    g.initWithEdges(edges.', 10);
    G = 20;

    m = matching(g, 20);

    r = m.solveMinimumWeightPerfectMatching()
    
end


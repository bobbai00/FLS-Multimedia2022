function drawMaxEdgeHistFor2CliqueSize(figPrefix, maxEdgeOf2, maxEdgeOf3, maxEdgeOf4, maxEdgeOf5) 
    figure3 = figure;

    subplot(1, 4, 1)
    h1 = histogram(maxEdgeOf2);
    xlabel('max edge weight')
    ylabel('number of cliques')
    title('2-Cique')


    subplot(1, 4, 2)
    h2 = histogram(maxEdgeOf3);
    xlabel('max edge weight')
    ylabel('number of cliques')
    title('3-Clique')

    subplot(1, 4, 3)
    h2 = histogram(maxEdgeOf4);
    xlabel('max edge weight')
    ylabel('number of cliques')
    title('4-Clique')

    subplot(1, 4, 4)
    h2 = histogram(maxEdgeOf5);
    xlabel('max edge weight')
    ylabel('number of cliques')
    title('5-Clique')

    filename = sprintf("%s-%s.jpg", figPrefix, "hist-MaxEdgeFor4CliqueSize");
    saveas(figure3, filename);
end
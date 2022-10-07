function drawMaxEdgeHistFor2CliqueSize(figPrefix, maxEdgeOf2, maxEdgeOf3) 
    figure3 = figure;

    subplot(1, 2, 1)
    h1 = histogram(maxEdgeOf2);
    xlabel('max edge weight')
    ylabel('number of cliques')
    title('2-Cique')


    subplot(1, 2, 2)
    h2 = histogram(maxEdgeOf3);
    xlabel('max edge weight')
    ylabel('number of cliques')
    title('3-Clique')

    filename = sprintf("%s-%s.jpg", figPrefix, "hist-MaxEdgeFor2CliqueSize");
    saveas(figure3, filename);
end